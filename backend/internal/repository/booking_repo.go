package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"bike-rental/internal/domain"
)

type bookingRepository struct {
	pool *pgxpool.Pool
}

func NewBookingRepository(pool *pgxpool.Pool) domain.BookingRepository {
	return &bookingRepository{pool: pool}
}

func (r *bookingRepository) Create(booking *domain.Booking) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		INSERT INTO bookings (id, booking_number, customer_id, bike_id, pickup_date, return_date,
			duration_days, price, deposit, taxes, discount, final_amount, booking_status,
			payment_status, coupon_id, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)`

	var couponID *string
	if booking.CouponID != "" {
		couponID = &booking.CouponID
	}

	_, err := r.pool.Exec(ctx, query,
		booking.ID, booking.BookingNumber, booking.CustomerID, booking.BikeID,
		booking.PickupDate, booking.ReturnDate, booking.DurationDays, booking.Price,
		booking.Deposit, booking.Taxes, booking.Discount, booking.FinalAmount,
		booking.BookingStatus, booking.PaymentStatus, couponID,
		booking.CreatedAt, booking.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to create booking: %w", err)
	}
	return nil
}

func (r *bookingRepository) Update(booking *domain.Booking) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		UPDATE bookings SET booking_status=$1, payment_status=$2, approved_at=$3,
			picked_up_at=$4, returned_at=$5, completed_at=$6, cancelled_at=$7, updated_at=$8
		WHERE id=$9`

	_, err := r.pool.Exec(ctx, query,
		booking.BookingStatus, booking.PaymentStatus, booking.ApprovedAt,
		booking.PickedUpAt, booking.ReturnedAt, booking.CompletedAt,
		booking.CancelledAt, time.Now(), booking.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to update booking: %w", err)
	}
	return nil
}

func (r *bookingRepository) GetByID(id string) (*domain.Booking, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		SELECT id, booking_number, customer_id, bike_id, pickup_date, return_date,
			duration_days, price, deposit, taxes, discount, final_amount, booking_status,
			payment_status, coupon_id, approved_at, picked_up_at, returned_at,
			completed_at, cancelled_at, created_at, updated_at
		FROM bookings WHERE id = $1`

	booking := &domain.Booking{}
	var couponID *string
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&booking.ID, &booking.BookingNumber, &booking.CustomerID, &booking.BikeID,
		&booking.PickupDate, &booking.ReturnDate, &booking.DurationDays, &booking.Price,
		&booking.Deposit, &booking.Taxes, &booking.Discount, &booking.FinalAmount,
		&booking.BookingStatus, &booking.PaymentStatus, &couponID,
		&booking.ApprovedAt, &booking.PickedUpAt, &booking.ReturnedAt,
		&booking.CompletedAt, &booking.CancelledAt, &booking.CreatedAt, &booking.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("booking not found")
	}
	if couponID != nil {
		booking.CouponID = *couponID
	}
	return booking, nil
}

func (r *bookingRepository) ListByCustomer(customerID string, offset, limit int) ([]domain.Booking, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	query := `
		SELECT id, booking_number, customer_id, bike_id, pickup_date, return_date,
			duration_days, price, deposit, taxes, discount, final_amount, booking_status,
			payment_status, coupon_id, approved_at, picked_up_at, returned_at,
			completed_at, cancelled_at, created_at, updated_at
		FROM bookings WHERE customer_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`

	return r.scanBookings(ctx, query, customerID, limit, offset)
}

func (r *bookingRepository) ListAll(offset, limit int) ([]domain.Booking, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	query := `
		SELECT id, booking_number, customer_id, bike_id, pickup_date, return_date,
			duration_days, price, deposit, taxes, discount, final_amount, booking_status,
			payment_status, coupon_id, approved_at, picked_up_at, returned_at,
			completed_at, cancelled_at, created_at, updated_at
		FROM bookings
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2`

	return r.scanBookings(ctx, query, limit, offset)
}

func (r *bookingRepository) HasOverlap(bikeID string, pickup, returnDate time.Time) (bool, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		SELECT EXISTS(
			SELECT 1 FROM bookings
			WHERE bike_id = $1
				AND booking_status NOT IN ('CANCELLED', 'REJECTED', 'COMPLETED')
				AND pickup_date < $3
				AND return_date > $2
		)`

	var exists bool
	err := r.pool.QueryRow(ctx, query, bikeID, pickup, returnDate).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("failed to check booking overlap: %w", err)
	}
	return exists, nil
}

func (r *bookingRepository) scanBookings(ctx context.Context, query string, args ...interface{}) ([]domain.Booking, error) {
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to query bookings: %w", err)
	}
	defer rows.Close()

	var bookings []domain.Booking
	for rows.Next() {
		var booking domain.Booking
		var couponID *string
		if err := rows.Scan(
			&booking.ID, &booking.BookingNumber, &booking.CustomerID, &booking.BikeID,
			&booking.PickupDate, &booking.ReturnDate, &booking.DurationDays, &booking.Price,
			&booking.Deposit, &booking.Taxes, &booking.Discount, &booking.FinalAmount,
			&booking.BookingStatus, &booking.PaymentStatus, &couponID,
			&booking.ApprovedAt, &booking.PickedUpAt, &booking.ReturnedAt,
			&booking.CompletedAt, &booking.CancelledAt, &booking.CreatedAt, &booking.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan booking: %w", err)
		}
		if couponID != nil {
			booking.CouponID = *couponID
		}
		bookings = append(bookings, booking)
	}
	return bookings, nil
}
