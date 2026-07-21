package domain

import (
	"time"
)

// Booking Statuses
const (
	BookingStatusPending   = "PENDING"
	BookingStatusConfirmed = "CONFIRMED"
	BookingStatusRejected  = "REJECTED"
	BookingStatusCancelled = "CANCELLED"
	BookingStatusActive    = "ACTIVE"
	BookingStatusReturned  = "RETURNED"
	BookingStatusCompleted = "COMPLETED"
	BookingStatusExpired   = "EXPIRED"
)

type Booking struct {
	ID            string    `json:"id"`
	BookingNumber string    `json:"booking_number"`
	CustomerID    string    `json:"customer_id"`
	BikeID        string    `json:"bike_id"`
	PickupDate    time.Time `json:"pickup_date"`
	ReturnDate    time.Time `json:"return_date"`
	DurationDays  int       `json:"duration_days"`
	Price         float64   `json:"price"`
	Deposit       float64   `json:"deposit"`
	Taxes         float64   `json:"taxes"`
	Discount      float64   `json:"discount"`
	FinalAmount   float64   `json:"final_amount"`
	BookingStatus string    `json:"booking_status"`
	PaymentStatus string    `json:"payment_status"` // PENDING, PAID, REFUNDED
	CouponID      string    `json:"coupon_id,omitempty"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`

	// Timeline
	ApprovedAt  *time.Time `json:"approved_at,omitempty"`
	PickedUpAt  *time.Time `json:"picked_up_at,omitempty"`
	ReturnedAt  *time.Time `json:"returned_at,omitempty"`
	CompletedAt *time.Time `json:"completed_at,omitempty"`
	CancelledAt *time.Time `json:"cancelled_at,omitempty"`
}

type BookingRepository interface {
	Create(booking *Booking) error
	Update(booking *Booking) error
	GetByID(id string) (*Booking, error)
	ListByCustomer(customerID string, offset, limit int) ([]Booking, error)
	ListAll(offset, limit int) ([]Booking, error)
	HasOverlap(bikeID string, pickup, returnDate time.Time) (bool, error)
}

type BookingService interface {
	CreateBooking(customerID, bikeID string, pickupDate, returnDate time.Time) (*Booking, error)
	GetBooking(id string) (*Booking, error)
	GetCustomerBookings(customerID string, offset, limit int) ([]Booking, error)
	GetAdminBookings(offset, limit int) ([]Booking, error)
	CancelBooking(id, customerID string) error

	// Admin Actions
	ApproveBooking(id string) error
	RejectBooking(id string) error
	MarkPickedUp(id string) error
	MarkReturned(id string) error
	CompleteBooking(id string) error
}
