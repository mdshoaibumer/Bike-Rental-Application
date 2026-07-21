package application

import (
	"testing"

	"bike-rental/internal/domain"
)

// Mock payment repository
type mockPaymentRepo struct {
	payments map[string]*domain.Payment
}

func newMockPaymentRepo() *mockPaymentRepo {
	return &mockPaymentRepo{payments: make(map[string]*domain.Payment)}
}

func (m *mockPaymentRepo) Create(p *domain.Payment) error {
	m.payments[p.ID] = p
	return nil
}

func (m *mockPaymentRepo) Update(p *domain.Payment) error {
	m.payments[p.ID] = p
	return nil
}

func (m *mockPaymentRepo) GetByID(id string) (*domain.Payment, error) {
	if p, ok := m.payments[id]; ok {
		return p, nil
	}
	return nil, domain.ErrNotFound
}

func (m *mockPaymentRepo) GetByBookingID(bookingID string) ([]domain.Payment, error) {
	var result []domain.Payment
	for _, p := range m.payments {
		if p.BookingID == bookingID {
			result = append(result, *p)
		}
	}
	return result, nil
}

func (m *mockPaymentRepo) ListAll(offset, limit int) ([]domain.Payment, error) {
	var result []domain.Payment
	for _, p := range m.payments {
		result = append(result, *p)
	}
	return result, nil
}

// Mock payment gateway
type mockPaymentGateway struct {
	shouldFail bool
}

func (m *mockPaymentGateway) CreateOrder(amount float64, currency string, receiptID string) (string, error) {
	if m.shouldFail {
		return "", domain.ErrValidation
	}
	return "txn_mock_12345", nil
}

func (m *mockPaymentGateway) VerifyWebhookSignature(payload []byte, signature string) bool {
	return signature == "valid-signature"
}

func (m *mockPaymentGateway) ProcessRefund(transactionID string, amount float64) (string, error) {
	if m.shouldFail {
		return "", domain.ErrValidation
	}
	return "refund_mock_12345", nil
}

func TestPaymentService_CreateOrder(t *testing.T) {
	repo := newMockPaymentRepo()
	gateway := &mockPaymentGateway{}
	service := NewPaymentService(repo, gateway)

	payment, err := service.CreateOrder("booking-1", 5000.0)
	if err != nil {
		t.Fatalf("CreateOrder() unexpected error: %v", err)
	}
	if payment == nil {
		t.Fatal("CreateOrder() returned nil payment")
	}
	if payment.BookingID != "booking-1" {
		t.Errorf("expected booking_id 'booking-1', got %q", payment.BookingID)
	}
	if payment.Amount != 5000.0 {
		t.Errorf("expected amount 5000.0, got %f", payment.Amount)
	}
	if payment.Status != domain.PaymentStatusPending {
		t.Errorf("expected status PENDING, got %q", payment.Status)
	}
	if payment.TransactionID != "txn_mock_12345" {
		t.Errorf("expected transaction_id from gateway, got %q", payment.TransactionID)
	}
}

func TestPaymentService_CreateOrder_NilGateway(t *testing.T) {
	repo := newMockPaymentRepo()
	service := NewPaymentService(repo, nil) // nil gateway = mock mode

	payment, err := service.CreateOrder("booking-1", 3000.0)
	if err != nil {
		t.Fatalf("CreateOrder() with nil gateway unexpected error: %v", err)
	}
	if payment == nil {
		t.Fatal("CreateOrder() returned nil payment")
	}
	if payment.TransactionID == "" {
		t.Error("expected mock transaction ID")
	}
}

func TestPaymentService_VerifyPayment(t *testing.T) {
	repo := newMockPaymentRepo()
	gateway := &mockPaymentGateway{}
	service := NewPaymentService(repo, gateway)

	// Create a payment first
	payment, _ := service.CreateOrder("booking-1", 5000.0)

	// Verify it
	err := service.VerifyPayment(payment.ID, "txn_mock_12345", "sig_valid")
	if err != nil {
		t.Fatalf("VerifyPayment() unexpected error: %v", err)
	}

	// Check status changed
	updated, _ := service.GetPaymentDetails(payment.ID)
	if updated.Status != domain.PaymentStatusCaptured {
		t.Errorf("expected status CAPTURED, got %q", updated.Status)
	}
}

func TestPaymentService_VerifyPayment_AlreadyProcessed(t *testing.T) {
	repo := newMockPaymentRepo()
	gateway := &mockPaymentGateway{}
	service := NewPaymentService(repo, gateway)

	payment, _ := service.CreateOrder("booking-1", 5000.0)
	_ = service.VerifyPayment(payment.ID, "txn_mock_12345", "sig_valid")

	// Try to verify again — should fail
	err := service.VerifyPayment(payment.ID, "txn_mock_12345", "sig_valid")
	if err == nil {
		t.Error("expected error for already processed payment")
	}
}

func TestPaymentService_ProcessRefund(t *testing.T) {
	repo := newMockPaymentRepo()
	gateway := &mockPaymentGateway{}
	service := NewPaymentService(repo, gateway)

	// Create and capture payment
	payment, _ := service.CreateOrder("booking-1", 5000.0)
	_ = service.VerifyPayment(payment.ID, "txn_mock_12345", "sig_valid")

	// Refund
	err := service.ProcessRefund(payment.ID, 5000.0)
	if err != nil {
		t.Fatalf("ProcessRefund() unexpected error: %v", err)
	}

	updated, _ := service.GetPaymentDetails(payment.ID)
	if updated.Status != domain.PaymentStatusRefunded {
		t.Errorf("expected status REFUNDED, got %q", updated.Status)
	}
}

func TestPaymentService_ProcessRefund_NotCaptured(t *testing.T) {
	repo := newMockPaymentRepo()
	gateway := &mockPaymentGateway{}
	service := NewPaymentService(repo, gateway)

	// Create payment but don't capture
	payment, _ := service.CreateOrder("booking-1", 5000.0)

	// Try to refund pending payment — should fail
	err := service.ProcessRefund(payment.ID, 5000.0)
	if err == nil {
		t.Error("expected error for refunding uncaptured payment")
	}
}

func TestPaymentService_HandleWebhook_ValidSignature(t *testing.T) {
	repo := newMockPaymentRepo()
	gateway := &mockPaymentGateway{}
	service := NewPaymentService(repo, gateway)

	err := service.HandleWebhook([]byte(`{"event":"payment.captured"}`), "valid-signature")
	if err != nil {
		t.Fatalf("HandleWebhook() with valid signature unexpected error: %v", err)
	}
}

func TestPaymentService_HandleWebhook_InvalidSignature(t *testing.T) {
	repo := newMockPaymentRepo()
	gateway := &mockPaymentGateway{}
	service := NewPaymentService(repo, gateway)

	err := service.HandleWebhook([]byte(`{"event":"payment.captured"}`), "invalid-signature")
	if err == nil {
		t.Error("expected error for invalid webhook signature")
	}
}

func TestPaymentService_GetPaymentDetails_NotFound(t *testing.T) {
	repo := newMockPaymentRepo()
	service := NewPaymentService(repo, nil)

	_, err := service.GetPaymentDetails("nonexistent")
	if err == nil {
		t.Error("expected error for nonexistent payment")
	}
}

func TestPaymentService_GetPaymentHistory(t *testing.T) {
	repo := newMockPaymentRepo()
	service := NewPaymentService(repo, nil)

	// Create a few payments
	_, _ = service.CreateOrder("booking-1", 1000.0)
	_, _ = service.CreateOrder("booking-2", 2000.0)

	payments, err := service.GetPaymentHistory(0, 10)
	if err != nil {
		t.Fatalf("GetPaymentHistory() unexpected error: %v", err)
	}
	if len(payments) != 2 {
		t.Errorf("expected 2 payments, got %d", len(payments))
	}
}
