package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"bike-rental/internal/domain"
)

type notificationRepository struct {
	pool *pgxpool.Pool
}

func NewNotificationRepository(pool *pgxpool.Pool) domain.NotificationRepository {
	return &notificationRepository{pool: pool}
}

func (r *notificationRepository) Save(notification *domain.Notification) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `INSERT INTO notifications (id, user_id, title, message, type, read, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`

	_, err := r.pool.Exec(ctx, query,
		notification.ID, notification.UserID, notification.Title,
		notification.Message, notification.Type, notification.Read, notification.CreatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to save notification: %w", err)
	}
	return nil
}

func (r *notificationRepository) GetByUser(userID string, offset, limit int) ([]domain.Notification, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if limit <= 0 {
		limit = 20
	}

	query := `SELECT id, user_id, title, message, type, read, created_at
		FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`

	rows, err := r.pool.Query(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to get notifications: %w", err)
	}
	defer rows.Close()

	var notifications []domain.Notification
	for rows.Next() {
		var n domain.Notification
		if err := rows.Scan(&n.ID, &n.UserID, &n.Title, &n.Message, &n.Type, &n.Read, &n.CreatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan notification: %w", err)
		}
		notifications = append(notifications, n)
	}
	return notifications, nil
}

func (r *notificationRepository) MarkAsRead(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `UPDATE notifications SET read = true WHERE id = $1`
	result, err := r.pool.Exec(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to mark notification as read: %w", err)
	}
	if result.RowsAffected() == 0 {
		return fmt.Errorf("notification not found")
	}
	return nil
}
