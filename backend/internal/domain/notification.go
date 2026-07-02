package domain

import "time"

type Notification struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Title     string    `json:"title"`
	Message   string    `json:"message"`
	Type      string    `json:"type"` // SMS, EMAIL, PUSH
	Read      bool      `json:"read"`
	CreatedAt time.Time `json:"created_at"`
}

type NotificationRepository interface {
	Save(notification *Notification) error
	GetByUser(userID string, offset, limit int) ([]Notification, error)
	MarkAsRead(id string) error
}

type NotificationProvider interface {
	SendPush(token, title, body string) error
	SendSMS(phone, message string) error
	SendEmail(to, subject, body string) error
}

type NotificationService interface {
	NotifyBookingCreated(userID, bookingID string) error
	NotifyPaymentSuccess(userID, paymentID string) error
	NotifyKYCApproved(userID string) error
	GetNotifications(userID string, offset, limit int) ([]Notification, error)
	MarkAsRead(id string) error
}
