package application

import (
	"testing"
	"time"

	"bike-rental/internal/domain"
)

// Mock bike repository for testing
type mockBikeRepo struct {
	bikes map[string]*domain.Bike
}

func newMockBikeRepo() *mockBikeRepo {
	return &mockBikeRepo{bikes: make(map[string]*domain.Bike)}
}

func (m *mockBikeRepo) Create(bike *domain.Bike) error { m.bikes[bike.ID] = bike; return nil }
func (m *mockBikeRepo) Update(bike *domain.Bike) error { m.bikes[bike.ID] = bike; return nil }
func (m *mockBikeRepo) Delete(id string) error         { delete(m.bikes, id); return nil }
func (m *mockBikeRepo) GetByID(id string) (*domain.Bike, error) {
	if b, ok := m.bikes[id]; ok {
		return b, nil
	}
	return nil, domain.ErrNotFound
}
func (m *mockBikeRepo) List(offset, limit int) ([]domain.Bike, error) { return nil, nil }
func (m *mockBikeRepo) Search(query string, offset, limit int) ([]domain.Bike, error) {
	return nil, nil
}
func (m *mockBikeRepo) UpdateAvailability(id, status string) error { return nil }
func (m *mockBikeRepo) GetCategories() ([]domain.BikeCategory, error) {
	return []domain.BikeCategory{{ID: "1", Name: "Sports"}}, nil
}

func TestBikeService_AddBike(t *testing.T) {
	repo := newMockBikeRepo()
	service := NewBikeService(repo)

	tests := []struct {
		name    string
		bike    *domain.Bike
		wantErr bool
	}{
		{
			name: "valid bike",
			bike: &domain.Bike{
				ID:                 "1",
				RegistrationNumber: "KA-01-AB-1234",
				RentalPrice:        500.0,
				BikeName:           "Test Bike",
			},
			wantErr: false,
		},
		{
			name: "missing registration number",
			bike: &domain.Bike{
				ID:          "2",
				RentalPrice: 500.0,
			},
			wantErr: true,
		},
		{
			name: "invalid rental price",
			bike: &domain.Bike{
				ID:                 "3",
				RegistrationNumber: "KA-01-AB-5678",
				RentalPrice:        0,
			},
			wantErr: true,
		},
		{
			name: "negative rental price",
			bike: &domain.Bike{
				ID:                 "4",
				RegistrationNumber: "KA-01-AB-9999",
				RentalPrice:        -100,
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := service.AddBike(tt.bike)
			if (err != nil) != tt.wantErr {
				t.Errorf("AddBike() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestBikeService_UpdateAvailability(t *testing.T) {
	repo := newMockBikeRepo()
	service := NewBikeService(repo)

	tests := []struct {
		name    string
		status  string
		wantErr bool
	}{
		{"valid - Available", "Available", false},
		{"valid - Booked", "Booked", false},
		{"valid - Maintenance", "Maintenance", false},
		{"invalid status", "INVALID", true},
		{"empty status", "", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := service.UpdateBikeAvailability("test-id", tt.status)
			if (err != nil) != tt.wantErr {
				t.Errorf("UpdateBikeAvailability() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

// Mock booking repository
type mockBookingRepo struct {
	bookings map[string]*domain.Booking
}

func newMockBookingRepo() *mockBookingRepo {
	return &mockBookingRepo{bookings: make(map[string]*domain.Booking)}
}

func (m *mockBookingRepo) Create(b *domain.Booking) error { m.bookings[b.ID] = b; return nil }
func (m *mockBookingRepo) Update(b *domain.Booking) error { m.bookings[b.ID] = b; return nil }
func (m *mockBookingRepo) GetByID(id string) (*domain.Booking, error) {
	if b, ok := m.bookings[id]; ok {
		return b, nil
	}
	return nil, domain.ErrNotFound
}
func (m *mockBookingRepo) ListByCustomer(cid string, o, l int) ([]domain.Booking, error) {
	return nil, nil
}
func (m *mockBookingRepo) ListAll(o, l int) ([]domain.Booking, error) { return nil, nil }
func (m *mockBookingRepo) HasOverlap(bikeID string, p, r time.Time) (bool, error) {
	return false, nil
}

func TestBookingService_CreateBooking(t *testing.T) {
	bikeRepo := newMockBikeRepo()
	bookingRepo := newMockBookingRepo()
	service := NewBookingService(bookingRepo, bikeRepo)

	// Add an available bike
	bikeRepo.bikes["bike-1"] = &domain.Bike{
		ID:                 "bike-1",
		RentalPrice:        1000,
		SecurityDeposit:    5000,
		AvailabilityStatus: "Available",
	}

	tests := []struct {
		name       string
		customerID string
		bikeID     string
		pickup     time.Time
		returnDate time.Time
		wantErr    bool
	}{
		{
			name:       "valid booking",
			customerID: "cust-1",
			bikeID:     "bike-1",
			pickup:     time.Now().Add(24 * time.Hour),
			returnDate: time.Now().Add(72 * time.Hour),
			wantErr:    false,
		},
		{
			name:       "pickup in past",
			customerID: "cust-1",
			bikeID:     "bike-1",
			pickup:     time.Now().Add(-24 * time.Hour),
			returnDate: time.Now().Add(24 * time.Hour),
			wantErr:    true,
		},
		{
			name:       "return before pickup",
			customerID: "cust-1",
			bikeID:     "bike-1",
			pickup:     time.Now().Add(48 * time.Hour),
			returnDate: time.Now().Add(24 * time.Hour),
			wantErr:    true,
		},
		{
			name:       "bike not found",
			customerID: "cust-1",
			bikeID:     "nonexistent",
			pickup:     time.Now().Add(24 * time.Hour),
			returnDate: time.Now().Add(72 * time.Hour),
			wantErr:    true,
		},
		{
			name:       "duration too short",
			customerID: "cust-1",
			bikeID:     "bike-1",
			pickup:     time.Now().Add(24 * time.Hour),
			returnDate: time.Now().Add(30 * time.Hour),
			wantErr:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			booking, err := service.CreateBooking(tt.customerID, tt.bikeID, tt.pickup, tt.returnDate)
			if (err != nil) != tt.wantErr {
				t.Errorf("CreateBooking() error = %v, wantErr %v", err, tt.wantErr)
			}
			if err == nil && booking == nil {
				t.Error("CreateBooking() returned nil booking without error")
			}
			if err == nil {
				if booking.CustomerID != tt.customerID {
					t.Errorf("expected customerID %s, got %s", tt.customerID, booking.CustomerID)
				}
				if booking.BookingStatus != domain.BookingStatusPending {
					t.Errorf("expected status PENDING, got %s", booking.BookingStatus)
				}
				if booking.FinalAmount <= 0 {
					t.Error("expected positive final amount")
				}
			}
		})
	}
}

func TestBookingService_StateTransitions(t *testing.T) {
	bikeRepo := newMockBikeRepo()
	bookingRepo := newMockBookingRepo()
	service := NewBookingService(bookingRepo, bikeRepo)

	// Setup a booking
	booking := &domain.Booking{
		ID:            "booking-1",
		CustomerID:    "cust-1",
		BookingStatus: domain.BookingStatusPending,
	}
	bookingRepo.bookings["booking-1"] = booking

	// Test: Approve
	if err := service.ApproveBooking("booking-1"); err != nil {
		t.Fatalf("ApproveBooking failed: %v", err)
	}
	if booking.BookingStatus != domain.BookingStatusConfirmed {
		t.Errorf("expected CONFIRMED, got %s", booking.BookingStatus)
	}

	// Test: MarkPickedUp
	if err := service.MarkPickedUp("booking-1"); err != nil {
		t.Fatalf("MarkPickedUp failed: %v", err)
	}
	if booking.BookingStatus != domain.BookingStatusActive {
		t.Errorf("expected ACTIVE, got %s", booking.BookingStatus)
	}

	// Test: MarkReturned
	if err := service.MarkReturned("booking-1"); err != nil {
		t.Fatalf("MarkReturned failed: %v", err)
	}
	if booking.BookingStatus != domain.BookingStatusReturned {
		t.Errorf("expected RETURNED, got %s", booking.BookingStatus)
	}

	// Test: CompleteBooking
	if err := service.CompleteBooking("booking-1"); err != nil {
		t.Fatalf("CompleteBooking failed: %v", err)
	}
	if booking.BookingStatus != domain.BookingStatusCompleted {
		t.Errorf("expected COMPLETED, got %s", booking.BookingStatus)
	}
}

func TestBookingService_CancelBooking(t *testing.T) {
	bikeRepo := newMockBikeRepo()
	bookingRepo := newMockBookingRepo()
	service := NewBookingService(bookingRepo, bikeRepo)

	booking := &domain.Booking{
		ID:            "booking-1",
		CustomerID:    "cust-1",
		BookingStatus: domain.BookingStatusPending,
	}
	bookingRepo.bookings["booking-1"] = booking

	// Wrong customer
	if err := service.CancelBooking("booking-1", "other-customer"); err == nil {
		t.Error("expected error for unauthorized cancellation")
	}

	// Correct customer
	if err := service.CancelBooking("booking-1", "cust-1"); err != nil {
		t.Fatalf("CancelBooking failed: %v", err)
	}
	if booking.BookingStatus != domain.BookingStatusCancelled {
		t.Errorf("expected CANCELLED, got %s", booking.BookingStatus)
	}

	// Cannot cancel already cancelled
	if err := service.CancelBooking("booking-1", "cust-1"); err == nil {
		t.Error("expected error for re-cancellation")
	}
}

func TestBookingService_InvalidStateTransition(t *testing.T) {
	bikeRepo := newMockBikeRepo()
	bookingRepo := newMockBookingRepo()
	service := NewBookingService(bookingRepo, bikeRepo)

	booking := &domain.Booking{
		ID:            "booking-1",
		CustomerID:    "cust-1",
		BookingStatus: domain.BookingStatusPending,
	}
	bookingRepo.bookings["booking-1"] = booking

	// Cannot mark picked up from PENDING (must be CONFIRMED first)
	if err := service.MarkPickedUp("booking-1"); err == nil {
		t.Error("expected error for invalid state transition")
	}

	// Cannot complete from PENDING
	if err := service.CompleteBooking("booking-1"); err == nil {
		t.Error("expected error for invalid state transition")
	}
}
