package middleware

import (
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

func TestGenerateToken(t *testing.T) {
	secret := "test-secret-key-at-least-32-chars-long"
	userID := "user-123"
	role := "CUSTOMER"
	mobile := "+919876543210"
	expiry := 1 * time.Hour

	token, err := GenerateToken(secret, userID, role, mobile, expiry)
	if err != nil {
		t.Fatalf("GenerateToken failed: %v", err)
	}
	if token == "" {
		t.Fatal("GenerateToken returned empty token")
	}

	// Parse and verify claims
	claims := &Claims{}
	parsed, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(secret), nil
	})
	if err != nil {
		t.Fatalf("Failed to parse token: %v", err)
	}
	if !parsed.Valid {
		t.Fatal("Token is not valid")
	}
	if claims.UserID != userID {
		t.Errorf("expected userID %s, got %s", userID, claims.UserID)
	}
	if claims.Role != role {
		t.Errorf("expected role %s, got %s", role, claims.Role)
	}
	if claims.Mobile != mobile {
		t.Errorf("expected mobile %s, got %s", mobile, claims.Mobile)
	}
}

func TestGenerateToken_WrongSecret(t *testing.T) {
	secret := "test-secret-key-at-least-32-chars-long"
	token, _ := GenerateToken(secret, "user-1", "ADMIN", "+91123", 1*time.Hour)

	// Parse with wrong secret should fail
	claims := &Claims{}
	_, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte("wrong-secret-key-at-least-32-chars"), nil
	})
	if err == nil {
		t.Fatal("expected error when parsing with wrong secret")
	}
}

func TestGenerateToken_Expired(t *testing.T) {
	secret := "test-secret-key-at-least-32-chars-long"
	token, _ := GenerateToken(secret, "user-1", "ADMIN", "+91123", -1*time.Hour)

	claims := &Claims{}
	_, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(secret), nil
	})
	if err == nil {
		t.Fatal("expected error for expired token")
	}
}

func TestJWTMiddleware_ValidToken(t *testing.T) {
	secret := "test-secret-key-at-least-32-chars-long"
	token, _ := GenerateToken(secret, "user-123", "CUSTOMER", "+919876543210", 1*time.Hour)

	app := fiber.New()
	app.Use(JWTMiddleware(secret))
	app.Get("/protected", func(c *fiber.Ctx) error {
		userID := GetUserID(c)
		role := GetUserRole(c)
		return c.JSON(fiber.Map{"user_id": userID, "role": role})
	})

	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 200 {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}
}

func TestJWTMiddleware_MissingHeader(t *testing.T) {
	app := fiber.New()
	app.Use(JWTMiddleware("secret"))
	app.Get("/protected", func(c *fiber.Ctx) error {
		return c.SendStatus(200)
	})

	req := httptest.NewRequest("GET", "/protected", nil)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 401 {
		t.Errorf("expected 401, got %d", resp.StatusCode)
	}
}

func TestJWTMiddleware_InvalidFormat(t *testing.T) {
	app := fiber.New()
	app.Use(JWTMiddleware("secret"))
	app.Get("/protected", func(c *fiber.Ctx) error {
		return c.SendStatus(200)
	})

	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("Authorization", "InvalidFormat")
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 401 {
		t.Errorf("expected 401, got %d", resp.StatusCode)
	}
}

func TestJWTMiddleware_ExpiredToken(t *testing.T) {
	secret := "test-secret-key-at-least-32-chars-long"
	token, _ := GenerateToken(secret, "user-1", "ADMIN", "+91123", -1*time.Hour)

	app := fiber.New()
	app.Use(JWTMiddleware(secret))
	app.Get("/protected", func(c *fiber.Ctx) error {
		return c.SendStatus(200)
	})

	req := httptest.NewRequest("GET", "/protected", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 401 {
		t.Errorf("expected 401, got %d", resp.StatusCode)
	}
}

func TestRoleMiddleware_Allowed(t *testing.T) {
	secret := "test-secret-key-at-least-32-chars-long"
	token, _ := GenerateToken(secret, "user-1", "ADMIN", "+91123", 1*time.Hour)

	app := fiber.New()
	app.Use(JWTMiddleware(secret))
	app.Use(RoleMiddleware("ADMIN", "OWNER"))
	app.Get("/admin", func(c *fiber.Ctx) error {
		return c.SendStatus(200)
	})

	req := httptest.NewRequest("GET", "/admin", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 200 {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}
}

func TestRoleMiddleware_Forbidden(t *testing.T) {
	secret := "test-secret-key-at-least-32-chars-long"
	token, _ := GenerateToken(secret, "user-1", "CUSTOMER", "+91123", 1*time.Hour)

	app := fiber.New()
	app.Use(JWTMiddleware(secret))
	app.Use(RoleMiddleware("ADMIN", "OWNER"))
	app.Get("/admin", func(c *fiber.Ctx) error {
		return c.SendStatus(200)
	})

	req := httptest.NewRequest("GET", "/admin", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 403 {
		t.Errorf("expected 403, got %d", resp.StatusCode)
	}
}

func TestSecurityHeaders(t *testing.T) {
	app := fiber.New()
	app.Use(SecurityHeaders())
	app.Get("/test", func(c *fiber.Ctx) error {
		return c.SendStatus(200)
	})

	req := httptest.NewRequest("GET", "/test", nil)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}

	headers := map[string]string{
		"X-Content-Type-Options": "nosniff",
		"X-Frame-Options":        "DENY",
		"X-Xss-Protection":       "1; mode=block",
		"Referrer-Policy":        "strict-origin-when-cross-origin",
		"Cache-Control":          "no-store",
	}

	for key, expected := range headers {
		got := resp.Header.Get(key)
		if got != expected {
			t.Errorf("header %q: expected %q, got %q", key, expected, got)
		}
	}
}

func TestGetUserID_Empty(t *testing.T) {
	app := fiber.New()
	var result string
	app.Get("/test", func(c *fiber.Ctx) error {
		result = GetUserID(c)
		return c.SendStatus(200)
	})

	req := httptest.NewRequest("GET", "/test", nil)
	_, _ = app.Test(req)
	if result != "" {
		t.Errorf("expected empty string, got %q", result)
	}
}

func TestGetUserRole_Empty(t *testing.T) {
	app := fiber.New()
	var result string
	app.Get("/test", func(c *fiber.Ctx) error {
		result = GetUserRole(c)
		return c.SendStatus(200)
	})

	req := httptest.NewRequest("GET", "/test", nil)
	_, _ = app.Test(req)
	if result != "" {
		t.Errorf("expected empty string, got %q", result)
	}
}
