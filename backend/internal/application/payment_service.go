package application

import (
	"errors"
	"time"

	"bike-rental/internal/domain"
	"github.com/google/uuid"
)

type paymentService struct {
	repo    domain.PaymentRepository
	gateway domain.PaymentGateway
}

func NewPaymentService(repo domain.PaymentRepository, gateway domain.PaymentGateway) domain.PaymentService {
	return &paymentService{repo: repo, gateway: gateway}
}

func (s *paymentService) CreateOrder(bookingID string, amount float64) (*domain.Payment, error) {
	receiptID := "rcpt_" + uuid.New().String()[:8]
	// Call to external gateway (mocked here if gateway is nil, but we assume it's injected)
	var txID string
	var err error
	if s.gateway != nil {
		txID, err = s.gateway.CreateOrder(amount, "INR", receiptID)
		if err != nil {
			return nil, err
		}
	} else {
		txID = "mock_tx_" + uuid.New().String()[:8]
	}

	payment := &domain.Payment{
		ID:            uuid.New().String(),
		BookingID:     bookingID,
		Gateway:       "Razorpay",
		TransactionID: txID,
		Amount:        amount,
		Status:        domain.PaymentStatusPending,
		Method:        "UPI",
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}
	if err := s.repo.Create(payment); err != nil {
		return nil, err
	}
	return payment, nil
}

func (s *paymentService) VerifyPayment(paymentID, transactionID, signature string) error {
	payment, err := s.repo.GetByID(paymentID)
	if err != nil {
		return err
	}
	if payment.Status != domain.PaymentStatusPending {
		return errors.New("payment already processed")
	}

	// Verify signature logic would go here
	payment.Status = domain.PaymentStatusCaptured
	payment.UpdatedAt = time.Now()
	
	return s.repo.Update(payment)
}

func (s *paymentService) HandleWebhook(payload []byte, signature string) error {
	if s.gateway != nil && !s.gateway.VerifyWebhookSignature(payload, signature) {
		return errors.New("invalid webhook signature")
	}
	// Business logic for webhook event
	return nil
}

func (s *paymentService) GetPaymentDetails(id string) (*domain.Payment, error) {
	return s.repo.GetByID(id)
}

func (s *paymentService) GetPaymentHistory(offset, limit int) ([]domain.Payment, error) {
	return s.repo.ListAll(offset, limit)
}

func (s *paymentService) ProcessRefund(paymentID string, amount float64) error {
	payment, err := s.repo.GetByID(paymentID)
	if err != nil {
		return err
	}
	if payment.Status != domain.PaymentStatusCaptured {
		return errors.New("cannot refund uncaptured payment")
	}

	// Gateway refund logic here...
	
	payment.Status = domain.PaymentStatusRefunded
	payment.UpdatedAt = time.Now()
	return s.repo.Update(payment)
}
