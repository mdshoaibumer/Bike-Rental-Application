package application

import (
	"errors"
	"time"

	"bike-rental/internal/domain"
	"github.com/google/uuid"
)

type bookingService struct {
	bookingRepo domain.BookingRepository
	bikeRepo    domain.BikeRepository
}

func NewBookingService(bookingRepo domain.BookingRepository, bikeRepo domain.BikeRepository) domain.BookingService {
	return &bookingService{
		bookingRepo: bookingRepo,
		bikeRepo:    bikeRepo,
	}
}

func (s *bookingService) CreateBooking(customerID, bikeID string, pickupDate, returnDate time.Time) (*domain.Booking, error) {
	if pickupDate.Before(time.Now()) {
		return nil, errors.New("pickup date cannot be in the past")
	}
	if returnDate.Before(pickupDate) {
		return nil, errors.New("return date must be after pickup date")
	}

	durationHours := returnDate.Sub(pickupDate).Hours()
	if durationHours < 24 {
		return nil, errors.New("minimum rental duration is 1 day")
	}

	bike, err := s.bikeRepo.GetByID(bikeID)
	if err != nil {
		return nil, errors.New("bike not found")
	}

	if bike.AvailabilityStatus != "Available" {
		return nil, errors.New("bike is not available for booking")
	}

	overlap, err := s.bookingRepo.HasOverlap(bikeID, pickupDate, returnDate)
	if err != nil {
		return nil, err
	}
	if overlap {
		return nil, errors.New("bike is already booked for the selected dates")
	}

	days := int(durationHours / 24)
	if int(durationHours)%24 > 0 {
		days++
	}

	price := float64(days) * bike.RentalPrice
	deposit := bike.SecurityDeposit
	taxes := price * 0.18 // 18% tax example
	finalAmount := price + deposit + taxes

	booking := &domain.Booking{
		ID:            uuid.New().String(),
		BookingNumber: "BKG-" + uuid.New().String()[:8],
		CustomerID:    customerID,
		BikeID:        bikeID,
		PickupDate:    pickupDate,
		ReturnDate:    returnDate,
		DurationDays:  days,
		Price:         price,
		Deposit:       deposit,
		Taxes:         taxes,
		Discount:      0,
		FinalAmount:   finalAmount,
		BookingStatus: domain.BookingStatusPending,
		PaymentStatus: "PENDING",
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}

	if err := s.bookingRepo.Create(booking); err != nil {
		return nil, err
	}

	return booking, nil
}

func (s *bookingService) GetBooking(id string) (*domain.Booking, error) {
	return s.bookingRepo.GetByID(id)
}

func (s *bookingService) GetCustomerBookings(customerID string, offset, limit int) ([]domain.Booking, error) {
	return s.bookingRepo.ListByCustomer(customerID, offset, limit)
}

func (s *bookingService) GetAdminBookings(offset, limit int) ([]domain.Booking, error) {
	return s.bookingRepo.ListAll(offset, limit)
}

func (s *bookingService) CancelBooking(id, customerID string) error {
	booking, err := s.bookingRepo.GetByID(id)
	if err != nil {
		return err
	}
	if booking.CustomerID != customerID {
		return errors.New("unauthorized to cancel this booking")
	}
	if booking.BookingStatus != domain.BookingStatusPending && booking.BookingStatus != domain.BookingStatusConfirmed {
		return errors.New("booking cannot be cancelled at this stage")
	}

	now := time.Now()
	booking.BookingStatus = domain.BookingStatusCancelled
	booking.CancelledAt = &now
	booking.UpdatedAt = now

	return s.bookingRepo.Update(booking)
}

func (s *bookingService) ApproveBooking(id string) error {
	return s.updateStatus(id, domain.BookingStatusPending, domain.BookingStatusConfirmed, func(b *domain.Booking, t time.Time) {
		b.ApprovedAt = &t
	})
}

func (s *bookingService) RejectBooking(id string) error {
	return s.updateStatus(id, domain.BookingStatusPending, domain.BookingStatusRejected, nil)
}

func (s *bookingService) MarkPickedUp(id string) error {
	return s.updateStatus(id, domain.BookingStatusConfirmed, domain.BookingStatusActive, func(b *domain.Booking, t time.Time) {
		b.PickedUpAt = &t
	})
}

func (s *bookingService) MarkReturned(id string) error {
	return s.updateStatus(id, domain.BookingStatusActive, domain.BookingStatusPending, func(b *domain.Booking, t time.Time) {
		b.ReturnedAt = &t
	})
}

func (s *bookingService) CompleteBooking(id string) error {
	// Typically completed after returned and payment/deposit settled
	return s.updateStatus(id, domain.BookingStatusPending, domain.BookingStatusCompleted, func(b *domain.Booking, t time.Time) {
		b.CompletedAt = &t
	})
}

func (s *bookingService) updateStatus(id, fromStatus, toStatus string, hook func(*domain.Booking, time.Time)) error {
	booking, err := s.bookingRepo.GetByID(id)
	if err != nil {
		return err
	}
	if booking.BookingStatus != fromStatus {
		return errors.New("invalid state transition")
	}

	now := time.Now()
	booking.BookingStatus = toStatus
	booking.UpdatedAt = now
	if hook != nil {
		hook(booking, now)
	}

	return s.bookingRepo.Update(booking)
}
