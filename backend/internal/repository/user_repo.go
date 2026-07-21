package repository

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"bike-rental/internal/domain"
)

type userRepository struct {
	pool *pgxpool.Pool
}

func NewUserRepository(pool *pgxpool.Pool) domain.UserRepository {
	return &userRepository{pool: pool}
}

func (r *userRepository) Create(user *domain.User) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `INSERT INTO users (id, full_name, mobile, email, role, status, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`

	_, err := r.pool.Exec(ctx, query,
		user.ID, user.FullName, user.Mobile, user.Email,
		user.Role, user.Status, user.CreatedAt, user.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}
	return nil
}

func (r *userRepository) GetByID(id string) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `SELECT id, full_name, mobile, email, role, status, created_at, updated_at
		FROM users WHERE id = $1 AND deleted_at IS NULL`

	user := &domain.User{}
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&user.ID, &user.FullName, &user.Mobile, &user.Email,
		&user.Role, &user.Status, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("user not found")
	}
	return user, nil
}

func (r *userRepository) GetByMobile(mobile string) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `SELECT id, full_name, mobile, email, role, status, created_at, updated_at
		FROM users WHERE mobile = $1 AND deleted_at IS NULL`

	user := &domain.User{}
	err := r.pool.QueryRow(ctx, query, mobile).Scan(
		&user.ID, &user.FullName, &user.Mobile, &user.Email,
		&user.Role, &user.Status, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("user not found")
	}
	return user, nil
}

func (r *userRepository) Update(user *domain.User) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `UPDATE users SET full_name=$1, email=$2, status=$3, updated_at=$4
		WHERE id=$5 AND deleted_at IS NULL`

	_, err := r.pool.Exec(ctx, query, user.FullName, user.Email, user.Status, time.Now(), user.ID)
	if err != nil {
		return fmt.Errorf("failed to update user: %w", err)
	}
	return nil
}

func (r *userRepository) SoftDelete(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `UPDATE users SET deleted_at = NOW(), status = 'INACTIVE', updated_at = NOW()
		WHERE id = $1 AND deleted_at IS NULL`

	result, err := r.pool.Exec(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}
	if result.RowsAffected() == 0 {
		return fmt.Errorf("user not found")
	}
	return nil
}

func (r *userRepository) SaveOTP(mobile, otpCode string, expiresAt time.Time) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Hash OTP before storing for security
	otpHash := HashToken(otpCode)

	query := `UPDATE users SET otp_code = $1, otp_expires_at = $2, otp_attempts = 0, updated_at = NOW()
		WHERE mobile = $3 AND deleted_at IS NULL`

	result, err := r.pool.Exec(ctx, query, otpHash, expiresAt, mobile)
	if err != nil {
		return fmt.Errorf("failed to save OTP: %w", err)
	}
	if result.RowsAffected() == 0 {
		// User does not exist yet — create them
		return r.createWithOTP(mobile, otpHash, expiresAt)
	}
	return nil
}

func (r *userRepository) createWithOTP(mobile, otpCode string, expiresAt time.Time) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `INSERT INTO users (mobile, otp_code, otp_expires_at, role, status, created_at, updated_at)
		VALUES ($1, $2, $3, 'CUSTOMER', 'ACTIVE', NOW(), NOW())
		ON CONFLICT (mobile) DO UPDATE SET otp_code = $2, otp_expires_at = $3, updated_at = NOW()`

	_, err := r.pool.Exec(ctx, query, mobile, otpCode, expiresAt)
	if err != nil {
		return fmt.Errorf("failed to create user with OTP: %w", err)
	}
	return nil
}

func (r *userRepository) VerifyOTP(mobile, otpCode string) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `SELECT id, full_name, mobile, email, role, status, otp_code, otp_expires_at, COALESCE(otp_attempts, 0)
		FROM users WHERE mobile = $1 AND deleted_at IS NULL`

	user := &domain.User{}
	var storedOTPHash *string
	var otpExpiresAt *time.Time
	var otpAttempts int

	err := r.pool.QueryRow(ctx, query, mobile).Scan(
		&user.ID, &user.FullName, &user.Mobile, &user.Email,
		&user.Role, &user.Status, &storedOTPHash, &otpExpiresAt, &otpAttempts,
	)
	if err != nil {
		return nil, fmt.Errorf("user not found")
	}

	// Rate limit: max 5 OTP verification attempts
	if otpAttempts >= 5 {
		return nil, fmt.Errorf("too many verification attempts, request a new OTP")
	}

	// Increment attempt counter
	attemptQuery := `UPDATE users SET otp_attempts = otp_attempts + 1, updated_at = NOW() WHERE id = $1`
	_, _ = r.pool.Exec(ctx, attemptQuery, user.ID)

	// Compare hashed OTP
	otpHash := HashToken(otpCode)
	if storedOTPHash == nil || *storedOTPHash != otpHash {
		return nil, fmt.Errorf("invalid OTP")
	}
	if otpExpiresAt == nil || time.Now().After(*otpExpiresAt) {
		return nil, fmt.Errorf("OTP expired")
	}

	// Clear OTP after successful verification
	clearQuery := `UPDATE users SET otp_code = NULL, otp_expires_at = NULL, otp_attempts = 0, updated_at = NOW() WHERE id = $1`
	_, _ = r.pool.Exec(ctx, clearQuery, user.ID)

	return user, nil
}

func (r *userRepository) SaveRefreshToken(userID, tokenHash string, expiresAt time.Time) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `INSERT INTO refresh_tokens (user_id, token_hash, expires_at, created_at)
		VALUES ($1, $2, $3, NOW())`

	_, err := r.pool.Exec(ctx, query, userID, tokenHash, expiresAt)
	if err != nil {
		return fmt.Errorf("failed to save refresh token: %w", err)
	}
	return nil
}

func (r *userRepository) ValidateRefreshToken(tokenHash string) (*domain.User, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		SELECT u.id, u.full_name, u.mobile, u.email, u.role, u.status
		FROM refresh_tokens rt
		JOIN users u ON u.id = rt.user_id
		WHERE rt.token_hash = $1 AND rt.revoked = false AND rt.expires_at > NOW() AND u.deleted_at IS NULL`

	user := &domain.User{}
	err := r.pool.QueryRow(ctx, query, tokenHash).Scan(
		&user.ID, &user.FullName, &user.Mobile, &user.Email, &user.Role, &user.Status,
	)
	if err != nil {
		return nil, fmt.Errorf("invalid refresh token")
	}
	return user, nil
}

func (r *userRepository) RevokeRefreshToken(tokenHash string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `UPDATE refresh_tokens SET revoked = true WHERE token_hash = $1`
	_, err := r.pool.Exec(ctx, query, tokenHash)
	if err != nil {
		return fmt.Errorf("failed to revoke token: %w", err)
	}
	return nil
}

func (r *userRepository) RevokeAllUserTokens(userID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `UPDATE refresh_tokens SET revoked = true WHERE user_id = $1 AND revoked = false`
	_, err := r.pool.Exec(ctx, query, userID)
	if err != nil {
		return fmt.Errorf("failed to revoke user tokens: %w", err)
	}
	return nil
}

// HashToken creates a SHA-256 hash of a token for secure storage
func HashToken(token string) string {
	h := sha256.New()
	h.Write([]byte(token))
	return hex.EncodeToString(h.Sum(nil))
}
