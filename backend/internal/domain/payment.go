package domain

import "time"

const (
	PaymentStatusPending    = "PENDING"
	PaymentStatusAuthorized = "AUTHORIZED"
	PaymentStatusCaptured   = "CAPTURED"
	PaymentStatusFailed     = "FAILED"
	PaymentStatusRefunded   = "REFUNDED"
	PaymentStatusCancelled  = "CANCELLED"
)

type Payment struct {
	ID            string    `json:"id"`
	BookingID     string    `json:"booking_id"`
	Gateway       string    `json:"gateway"`
	TransactionID string    `json:"transaction_id"`
	Amount        float64   `json:"amount"`
	Status        string    `json:"status"`
	Method        string    `json:"method"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type PaymentRepository interface {
	Create(payment *Payment) error
	Update(payment *Payment) error
	GetByID(id string) (*Payment, error)
	GetByBookingID(bookingID string) ([]Payment, error)
	ListAll(offset, limit int) ([]Payment, error)
}

type PaymentGateway interface {
	CreateOrder(amount float64, currency string, receiptID string) (string, error)
	VerifyWebhookSignature(payload []byte, signature string) bool
	ProcessRefund(transactionID string, amount float64) (string, error)
}

type PaymentService interface {
	CreateOrder(bookingID string, amount float64) (*Payment, error)
	VerifyPayment(paymentID, transactionID, signature string) error
	HandleWebhook(payload []byte, signature string) error
	GetPaymentDetails(id string) (*Payment, error)
	GetPaymentHistory(offset, limit int) ([]Payment, error)
	ProcessRefund(paymentID string, amount float64) error
}
