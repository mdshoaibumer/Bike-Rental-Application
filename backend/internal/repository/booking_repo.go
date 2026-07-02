package repository

import (
	"errors"
	"time"

	"bike-rental/internal/domain"
)

type bookingRepository struct {
	bookings map[string]*domain.Booking
}

func NewBookingRepository() domain.BookingRepository {
	return &bookingRepository{
		bookings: make(map[string]*domain.Booking),
	}
}

func (r *bookingRepository) Create(booking *domain.Booking) error {
	if _, exists := r.bookings[booking.ID]; exists {
		return errors.New("booking already exists")
	}
	r.bookings[booking.ID] = booking
	return nil
}

func (r *bookingRepository) Update(booking *domain.Booking) error {
	if _, exists := r.bookings[booking.ID]; !exists {
		return errors.New("booking not found")
	}
	r.bookings[booking.ID] = booking
	return nil
}

func (r *bookingRepository) GetByID(id string) (*domain.Booking, error) {
	if booking, exists := r.bookings[id]; exists {
		return booking, nil
	}
	return nil, errors.New("booking not found")
}

func (r *bookingRepository) ListByCustomer(customerID string, offset, limit int) ([]domain.Booking, error) {
	var list []domain.Booking
	for _, b := range r.bookings {
		if b.CustomerID == customerID {
			list = append(list, *b)
		}
	}
	return list, nil
}

func (r *bookingRepository) ListAll(offset, limit int) ([]domain.Booking, error) {
	var list []domain.Booking
	for _, b := range r.bookings {
		list = append(list, *b)
	}
	return list, nil
}

func (r *bookingRepository) HasOverlap(bikeID string, pickup, returnDate time.Time) (bool, error) {
	for _, b := range r.bookings {
		if b.BikeID == bikeID && b.BookingStatus != domain.BookingStatusCancelled && b.BookingStatus != domain.BookingStatusRejected {
			// Check overlap
			if pickup.Before(b.ReturnDate) && returnDate.After(b.PickupDate) {
				return true, nil
			}
		}
	}
	return false, nil
}
