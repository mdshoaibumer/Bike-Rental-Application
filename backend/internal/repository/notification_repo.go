package repository

import (
	"errors"
	"bike-rental/internal/domain"
)

type notificationRepository struct {
	notifications map[string]*domain.Notification
}

func NewNotificationRepository() domain.NotificationRepository {
	return &notificationRepository{
		notifications: make(map[string]*domain.Notification),
	}
}

func (r *notificationRepository) Save(notification *domain.Notification) error {
	r.notifications[notification.ID] = notification
	return nil
}

func (r *notificationRepository) GetByUser(userID string, offset, limit int) ([]domain.Notification, error) {
	var list []domain.Notification
	for _, n := range r.notifications {
		if n.UserID == userID {
			list = append(list, *n)
		}
	}
	return list, nil
}

func (r *notificationRepository) MarkAsRead(id string) error {
	if n, exists := r.notifications[id]; exists {
		n.Read = true
		return nil
	}
	return errors.New("notification not found")
}
