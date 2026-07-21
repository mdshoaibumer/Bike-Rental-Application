package application

import (
	"testing"
	"time"

	"bike-rental/internal/config"
	"bike-rental/internal/domain"
)

// Mock user repository for auth testing
type mockUserRepo struct {
	users         map[string]*domain.User
	otpStore      map[string]string // mobile -> otp hash
	otpExpiry     map[string]time.Time
	otpAttempts   map[string]int
	refreshTokens map[string]*domain.User
}

func newMockUserRepo() *mockUserRepo {
	return &mockUserRepo{
		users:         make(map[string]*domain.User),
		otpStore:      make(map[string]string),
		otpExpiry:     make(map[string]time.Time),
		otpAttempts:   make(map[string]int),
		refreshTokens: make(map[string]*domain.User),
	}
}

func (m *mockUserRepo) Create(user *domain.User) error {
	m.users[user.ID] = user
	return nil
}

func (m *mockUserRepo) GetByID(id string) (*domain.User, error) {
	if u, ok := m.users[id]; ok {
		return u, nil
	}
	return nil, domain.ErrNotFound
}

func (m *mockUserRepo) GetByMobile(mobile string) (*domain.User, error) {
	for _, u := range m.users {
		if u.Mobile == mobile {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockUserRepo) Update(user *domain.User) error {
	m.users[user.ID] = user
	return nil
}

func (m *mockUserRepo) SoftDelete(id string) error {
	delete(m.users, id)
	return nil
}

func (m *mockUserRepo) SaveOTP(mobile, otpCode string, expiresAt time.Time) error {
	m.otpStore[mobile] = otpCode
	m.otpExpiry[mobile] = expiresAt
	m.otpAttempts[mobile] = 0
	// Auto-create user if doesn't exist
	found := false
	for _, u := range m.users {
		if u.Mobile == mobile {
			found = true
			break
		}
	}
	if !found {
		m.users["user-"+mobile] = &domain.User{
			ID:     "user-" + mobile,
			Mobile: mobile,
			Role:   "CUSTOMER",
			Status: "ACTIVE",
		}
	}
	return nil
}

func (m *mockUserRepo) VerifyOTP(mobile, otpCode string) (*domain.User, error) {
	attempts := m.otpAttempts[mobile]
	if attempts >= 5 {
		return nil, domain.ErrForbidden
	}
	m.otpAttempts[mobile]++

	stored, ok := m.otpStore[mobile]
	if !ok || stored != otpCode {
		return nil, domain.ErrUnauthorized
	}
	expiry, ok := m.otpExpiry[mobile]
	if !ok || time.Now().After(expiry) {
		return nil, domain.ErrUnauthorized
	}
	// Clear OTP
	delete(m.otpStore, mobile)
	delete(m.otpExpiry, mobile)

	for _, u := range m.users {
		if u.Mobile == mobile {
			return u, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockUserRepo) SaveRefreshToken(userID, tokenHash string, expiresAt time.Time) error {
	if u, ok := m.users[userID]; ok {
		m.refreshTokens[tokenHash] = u
	}
	return nil
}

func (m *mockUserRepo) ValidateRefreshToken(tokenHash string) (*domain.User, error) {
	if u, ok := m.refreshTokens[tokenHash]; ok {
		return u, nil
	}
	return nil, domain.ErrUnauthorized
}

func (m *mockUserRepo) RevokeRefreshToken(tokenHash string) error {
	delete(m.refreshTokens, tokenHash)
	return nil
}

func (m *mockUserRepo) RevokeAllUserTokens(userID string) error {
	for k, u := range m.refreshTokens {
		if u.ID == userID {
			delete(m.refreshTokens, k)
		}
	}
	return nil
}

func TestAuthService_SendOTP_ValidMobile(t *testing.T) {
	repo := newMockUserRepo()
	cfg := &config.Config{
		JWTSecret:          "test-secret-key-at-least-32-chars-long",
		JWTExpiry:          1 * time.Hour,
		RefreshTokenExpiry: 168 * time.Hour,
	}
	service := NewAuthService(repo, cfg)

	tests := []struct {
		name    string
		mobile  string
		wantErr bool
	}{
		{"valid 10 digit", "9876543210", false}, // + prefix optional, 10 digits valid
		{"valid with +91", "+919876543210", false},
		{"valid with +1", "+14155551234", false},
		{"too short", "+1234", true},
		{"empty", "", true},
		{"with letters", "+91abc", true},
		{"with spaces", "+91 987 654", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := service.SendOTP(tt.mobile)
			if (err != nil) != tt.wantErr {
				t.Errorf("SendOTP(%q) error = %v, wantErr %v", tt.mobile, err, tt.wantErr)
			}
		})
	}
}

func TestAuthService_GetProfile(t *testing.T) {
	repo := newMockUserRepo()
	cfg := &config.Config{
		JWTSecret:          "test-secret-key-at-least-32-chars-long",
		JWTExpiry:          1 * time.Hour,
		RefreshTokenExpiry: 168 * time.Hour,
	}
	service := NewAuthService(repo, cfg)

	// Setup user
	repo.users["user-1"] = &domain.User{
		ID:       "user-1",
		FullName: "Test User",
		Mobile:   "+919876543210",
		Role:     "CUSTOMER",
		Status:   "ACTIVE",
	}

	// Get existing profile
	user, err := service.GetProfile("user-1")
	if err != nil {
		t.Fatalf("GetProfile() unexpected error: %v", err)
	}
	if user.FullName != "Test User" {
		t.Errorf("expected FullName 'Test User', got %q", user.FullName)
	}

	// Get non-existent profile
	_, err = service.GetProfile("nonexistent")
	if err == nil {
		t.Error("GetProfile() expected error for non-existent user")
	}
}

func TestAuthService_UpdateProfile(t *testing.T) {
	repo := newMockUserRepo()
	cfg := &config.Config{
		JWTSecret:          "test-secret-key-at-least-32-chars-long",
		JWTExpiry:          1 * time.Hour,
		RefreshTokenExpiry: 168 * time.Hour,
	}
	service := NewAuthService(repo, cfg)

	repo.users["user-1"] = &domain.User{
		ID:       "user-1",
		FullName: "Old Name",
		Mobile:   "+919876543210",
		Role:     "CUSTOMER",
		Status:   "ACTIVE",
	}

	// Update name
	err := service.UpdateProfile("user-1", "New Name", nil)
	if err != nil {
		t.Fatalf("UpdateProfile() unexpected error: %v", err)
	}
	if repo.users["user-1"].FullName != "New Name" {
		t.Errorf("expected FullName 'New Name', got %q", repo.users["user-1"].FullName)
	}

	// Update with email
	email := "test@example.com"
	err = service.UpdateProfile("user-1", "", &email)
	if err != nil {
		t.Fatalf("UpdateProfile() with email error: %v", err)
	}
	if repo.users["user-1"].Email == nil || *repo.users["user-1"].Email != email {
		t.Error("expected email to be updated")
	}
}

func TestAuthService_DeleteProfile(t *testing.T) {
	repo := newMockUserRepo()
	cfg := &config.Config{
		JWTSecret:          "test-secret-key-at-least-32-chars-long",
		JWTExpiry:          1 * time.Hour,
		RefreshTokenExpiry: 168 * time.Hour,
	}
	service := NewAuthService(repo, cfg)

	repo.users["user-1"] = &domain.User{
		ID:     "user-1",
		Mobile: "+919876543210",
		Role:   "CUSTOMER",
		Status: "ACTIVE",
	}

	err := service.DeleteProfile("user-1")
	if err != nil {
		t.Fatalf("DeleteProfile() unexpected error: %v", err)
	}

	// User should be gone
	_, err = service.GetProfile("user-1")
	if err == nil {
		t.Error("expected error after deletion")
	}
}

func TestGenerateOTP(t *testing.T) {
	otp, err := generateOTP(6)
	if err != nil {
		t.Fatalf("generateOTP failed: %v", err)
	}
	if len(otp) != 6 {
		t.Errorf("expected OTP length 6, got %d", len(otp))
	}
	// Verify all characters are digits
	for _, ch := range otp {
		if ch < '0' || ch > '9' {
			t.Errorf("OTP contains non-digit character: %c", ch)
		}
	}

	// Generate multiple to verify randomness
	otps := make(map[string]bool)
	for i := 0; i < 100; i++ {
		o, _ := generateOTP(6)
		otps[o] = true
	}
	if len(otps) < 50 {
		t.Error("OTP generation not sufficiently random")
	}
}

func TestGenerateSecureToken(t *testing.T) {
	token, err := generateSecureToken(64)
	if err != nil {
		t.Fatalf("generateSecureToken failed: %v", err)
	}
	if len(token) != 64 {
		t.Errorf("expected token length 64, got %d", len(token))
	}

	// Verify uniqueness
	token2, _ := generateSecureToken(64)
	if token == token2 {
		t.Error("consecutive tokens should not be identical")
	}
}

func TestMobileRegex(t *testing.T) {
	tests := []struct {
		mobile string
		valid  bool
	}{
		{"+919876543210", true},
		{"+14155551234", true},
		{"+442071234567", true},
		{"919876543210", true},
		{"+1234567890", true},
		{"+0123456789", false}, // starts with 0 after +
		{"", false},
		{"abc", false},
		{"+91 987", false}, // contains space
		{"12345", false},   // too short
	}

	for _, tt := range tests {
		t.Run(tt.mobile, func(t *testing.T) {
			result := mobileRegex.MatchString(tt.mobile)
			if result != tt.valid {
				t.Errorf("mobileRegex.MatchString(%q) = %v, want %v", tt.mobile, result, tt.valid)
			}
		})
	}
}
