package application

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"regexp"
	"time"

	"bike-rental/internal/config"
	"bike-rental/internal/domain"
	"bike-rental/internal/middleware"
	"bike-rental/internal/repository"
)

var mobileRegex = regexp.MustCompile(`^\+?[1-9]\d{9,14}$`)

type authService struct {
	userRepo domain.UserRepository
	cfg      *config.Config
}

func NewAuthService(userRepo domain.UserRepository, cfg *config.Config) domain.AuthService {
	return &authService{
		userRepo: userRepo,
		cfg:      cfg,
	}
}

func (s *authService) SendOTP(mobile string) error {
	if !mobileRegex.MatchString(mobile) {
		return fmt.Errorf("invalid mobile number format")
	}

	otpCode, err := generateOTP(6)
	if err != nil {
		return fmt.Errorf("failed to generate OTP: %w", err)
	}

	expiresAt := time.Now().Add(5 * time.Minute)

	if err := s.userRepo.SaveOTP(mobile, otpCode, expiresAt); err != nil {
		return fmt.Errorf("failed to save OTP: %w", err)
	}

	// In production, send OTP via SMS provider (Twilio/MSG91)
	// For now, log it (will be replaced with real SMS provider)
	// TODO: Integrate SMS gateway
	_ = otpCode

	return nil
}

func (s *authService) VerifyOTP(mobile, code string) (*domain.TokenPair, error) {
	user, err := s.userRepo.VerifyOTP(mobile, code)
	if err != nil {
		return nil, err
	}

	if user.Status != "ACTIVE" {
		return nil, fmt.Errorf("account is suspended or inactive")
	}

	// Generate access token
	accessToken, err := middleware.GenerateToken(
		s.cfg.JWTSecret, user.ID, user.Role, user.Mobile, s.cfg.JWTExpiry,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to generate access token: %w", err)
	}

	// Generate refresh token
	refreshToken, err := generateSecureToken(64)
	if err != nil {
		return nil, fmt.Errorf("failed to generate refresh token: %w", err)
	}

	// Store hashed refresh token
	tokenHash := repository.HashToken(refreshToken)
	expiresAt := time.Now().Add(s.cfg.RefreshTokenExpiry)
	if err := s.userRepo.SaveRefreshToken(user.ID, tokenHash, expiresAt); err != nil {
		return nil, fmt.Errorf("failed to save refresh token: %w", err)
	}

	return &domain.TokenPair{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int64(s.cfg.JWTExpiry.Seconds()),
		Role:         user.Role,
	}, nil
}

func (s *authService) RefreshToken(refreshToken string) (*domain.TokenPair, error) {
	tokenHash := repository.HashToken(refreshToken)

	user, err := s.userRepo.ValidateRefreshToken(tokenHash)
	if err != nil {
		return nil, fmt.Errorf("invalid or expired refresh token")
	}

	// Revoke old refresh token (rotation)
	_ = s.userRepo.RevokeRefreshToken(tokenHash)

	// Generate new tokens
	accessToken, err := middleware.GenerateToken(
		s.cfg.JWTSecret, user.ID, user.Role, user.Mobile, s.cfg.JWTExpiry,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to generate access token: %w", err)
	}

	newRefreshToken, err := generateSecureToken(64)
	if err != nil {
		return nil, fmt.Errorf("failed to generate refresh token: %w", err)
	}

	newTokenHash := repository.HashToken(newRefreshToken)
	expiresAt := time.Now().Add(s.cfg.RefreshTokenExpiry)
	if err := s.userRepo.SaveRefreshToken(user.ID, newTokenHash, expiresAt); err != nil {
		return nil, fmt.Errorf("failed to save refresh token: %w", err)
	}

	return &domain.TokenPair{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
		ExpiresIn:    int64(s.cfg.JWTExpiry.Seconds()),
		Role:         user.Role,
	}, nil
}

func (s *authService) Logout(refreshToken string) error {
	tokenHash := repository.HashToken(refreshToken)
	return s.userRepo.RevokeRefreshToken(tokenHash)
}

func (s *authService) GetProfile(userID string) (*domain.User, error) {
	return s.userRepo.GetByID(userID)
}

func (s *authService) UpdateProfile(userID, fullName string, email *string) error {
	user, err := s.userRepo.GetByID(userID)
	if err != nil {
		return err
	}

	if fullName != "" {
		user.FullName = fullName
	}
	if email != nil {
		user.Email = email
	}

	return s.userRepo.Update(user)
}

func (s *authService) DeleteProfile(userID string) error {
	// Revoke all tokens first
	_ = s.userRepo.RevokeAllUserTokens(userID)
	return s.userRepo.SoftDelete(userID)
}

// generateOTP generates a cryptographically secure numeric OTP
func generateOTP(length int) (string, error) {
	otp := ""
	for i := 0; i < length; i++ {
		n, err := rand.Int(rand.Reader, big.NewInt(10))
		if err != nil {
			return "", err
		}
		otp += fmt.Sprintf("%d", n.Int64())
	}
	return otp, nil
}

// generateSecureToken generates a cryptographically secure random token
func generateSecureToken(length int) (string, error) {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	result := make([]byte, length)
	for i := range result {
		n, err := rand.Int(rand.Reader, big.NewInt(int64(len(charset))))
		if err != nil {
			return "", err
		}
		result[i] = charset[n.Int64()]
	}
	return string(result), nil
}
