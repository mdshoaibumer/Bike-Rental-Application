package domain

import "time"

type User struct {
	ID        string    `json:"id"`
	FullName  string    `json:"full_name"`
	Mobile    string    `json:"mobile"`
	Email     *string   `json:"email,omitempty"`
	Role      string    `json:"role"`
	Status    string    `json:"status"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type UserRepository interface {
	Create(user *User) error
	GetByID(id string) (*User, error)
	GetByMobile(mobile string) (*User, error)
	Update(user *User) error
	SoftDelete(id string) error
	SaveOTP(mobile, otpCode string, expiresAt time.Time) error
	VerifyOTP(mobile, otpCode string) (*User, error)
	SaveRefreshToken(userID, tokenHash string, expiresAt time.Time) error
	ValidateRefreshToken(tokenHash string) (*User, error)
	RevokeRefreshToken(tokenHash string) error
	RevokeAllUserTokens(userID string) error
}

type AuthService interface {
	SendOTP(mobile string) error
	VerifyOTP(mobile, code string) (*TokenPair, error)
	RefreshToken(refreshToken string) (*TokenPair, error)
	Logout(refreshToken string) error
	GetProfile(userID string) (*User, error)
	UpdateProfile(userID, fullName string, email *string) error
	DeleteProfile(userID string) error
}

type TokenPair struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int64  `json:"expires_in"`
	Role         string `json:"role"`
}
