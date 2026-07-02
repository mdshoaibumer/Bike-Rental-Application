package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"bike-rental/internal/domain"
)

type paymentRepository struct {
	pool *pgxpool.Pool
}

func NewPaymentRepository(pool *pgxpool.Pool) domain.PaymentRepository {
	return &paymentRepository{pool: pool}
}

func (r *paymentRepository) Create(payment *domain.Payment) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		INSERT INTO payments (id, booking_id, gateway, transaction_id, amount, status, method, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`

	_, err := r.pool.Exec(ctx, query,
		payment.ID, payment.BookingID, payment.Gateway, payment.TransactionID,
		payment.Amount, payment.Status, payment.Method, payment.CreatedAt, payment.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to create payment: %w", err)
	}
	return nil
}

func (r *paymentRepository) Update(payment *domain.Payment) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `UPDATE payments SET status=$1, transaction_id=$2, updated_at=$3 WHERE id=$4`
	_, err := r.pool.Exec(ctx, query, payment.Status, payment.TransactionID, time.Now(), payment.ID)
	if err != nil {
		return fmt.Errorf("failed to update payment: %w", err)
	}
	return nil
}

func (r *paymentRepository) GetByID(id string) (*domain.Payment, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `SELECT id, booking_id, gateway, transaction_id, amount, status, method, created_at, updated_at
		FROM payments WHERE id = $1`

	payment := &domain.Payment{}
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&payment.ID, &payment.BookingID, &payment.Gateway, &payment.TransactionID,
		&payment.Amount, &payment.Status, &payment.Method, &payment.CreatedAt, &payment.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("payment not found")
	}
	return payment, nil
}

func (r *paymentRepository) GetByBookingID(bookingID string) ([]domain.Payment, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `SELECT id, booking_id, gateway, transaction_id, amount, status, method, created_at, updated_at
		FROM payments WHERE booking_id = $1 ORDER BY created_at DESC`

	rows, err := r.pool.Query(ctx, query, bookingID)
	if err != nil {
		return nil, fmt.Errorf("failed to get payments: %w", err)
	}
	defer rows.Close()

	var payments []domain.Payment
	for rows.Next() {
		var p domain.Payment
		if err := rows.Scan(
			&p.ID, &p.BookingID, &p.Gateway, &p.TransactionID,
			&p.Amount, &p.Status, &p.Method, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan payment: %w", err)
		}
		payments = append(payments, p)
	}
	return payments, nil
}

func (r *paymentRepository) ListAll(offset, limit int) ([]domain.Payment, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	query := `SELECT id, booking_id, gateway, transaction_id, amount, status, method, created_at, updated_at
		FROM payments ORDER BY created_at DESC LIMIT $1 OFFSET $2`

	rows, err := r.pool.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list payments: %w", err)
	}
	defer rows.Close()

	var payments []domain.Payment
	for rows.Next() {
		var p domain.Payment
		if err := rows.Scan(
			&p.ID, &p.BookingID, &p.Gateway, &p.TransactionID,
			&p.Amount, &p.Status, &p.Method, &p.CreatedAt, &p.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan payment: %w", err)
		}
		payments = append(payments, p)
	}
	return payments, nil
}
