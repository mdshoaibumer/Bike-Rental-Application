package application

import (
	"time"

	"bike-rental/internal/domain"
	"github.com/google/uuid"
)

type notificationService struct {
	repo     domain.NotificationRepository
	provider domain.NotificationProvider
}

func NewNotificationService(repo domain.NotificationRepository, provider domain.NotificationProvider) domain.NotificationService {
	return &notificationService{repo: repo, provider: provider}
}

func (s *notificationService) NotifyBookingCreated(userID, bookingID string) error {
	return s.saveNotification(userID, "Booking Created", "Your booking "+bookingID+" has been created successfully.", "PUSH")
}

func (s *notificationService) NotifyPaymentSuccess(userID, paymentID string) error {
	return s.saveNotification(userID, "Payment Successful", "Payment "+paymentID+" was successful.", "PUSH")
}

func (s *notificationService) NotifyKYCApproved(userID string) error {
	return s.saveNotification(userID, "KYC Approved", "Your KYC has been approved.", "PUSH")
}

func (s *notificationService) GetNotifications(userID string, offset, limit int) ([]domain.Notification, error) {
	return s.repo.GetByUser(userID, offset, limit)
}

func (s *notificationService) MarkAsRead(id string) error {
	return s.repo.MarkAsRead(id)
}

func (s *notificationService) saveNotification(userID, title, message, notifType string) error {
	n := &domain.Notification{
		ID:        uuid.New().String(),
		UserID:    userID,
		Title:     title,
		Message:   message,
		Type:      notifType,
		Read:      false,
		CreatedAt: time.Now(),
	}
	if s.provider != nil {
		// Mock triggering real provider
		_ = s.provider.SendPush("token", title, message)
	}
	return s.repo.Save(n)
}
