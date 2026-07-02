package repository

import (
	"errors"
	"bike-rental/internal/domain"
)

type paymentRepository struct {
	payments map[string]*domain.Payment
}

func NewPaymentRepository() domain.PaymentRepository {
	return &paymentRepository{
		payments: make(map[string]*domain.Payment),
	}
}

func (r *paymentRepository) Create(payment *domain.Payment) error {
	if _, exists := r.payments[payment.ID]; exists {
		return errors.New("payment already exists")
	}
	r.payments[payment.ID] = payment
	return nil
}

func (r *paymentRepository) Update(payment *domain.Payment) error {
	if _, exists := r.payments[payment.ID]; !exists {
		return errors.New("payment not found")
	}
	r.payments[payment.ID] = payment
	return nil
}

func (r *paymentRepository) GetByID(id string) (*domain.Payment, error) {
	if payment, exists := r.payments[id]; exists {
		return payment, nil
	}
	return nil, errors.New("payment not found")
}

func (r *paymentRepository) GetByBookingID(bookingID string) ([]domain.Payment, error) {
	var list []domain.Payment
	for _, p := range r.payments {
		if p.BookingID == bookingID {
			list = append(list, *p)
		}
	}
	return list, nil
}

func (r *paymentRepository) ListAll(offset, limit int) ([]domain.Payment, error) {
	var list []domain.Payment
	for _, p := range r.payments {
		list = append(list, *p)
	}
	return list, nil
}
