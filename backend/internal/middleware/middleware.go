package middleware

import (
	"github.com/gofiber/fiber/v2"
)

// CentralErrorHandler handles all generic errors thrown in the app
func CentralErrorHandler(c *fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	if e, ok := err.(*fiber.Error); ok {
		code = e.Code
	}
	return c.Status(code).JSON(fiber.Map{
		"error":   true,
		"message": err.Error(),
	})
}

// JWTMiddleware mocks a JWT verification middleware
func JWTMiddleware(secret string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Mock token validation
		token := c.Get("Authorization")
		if token == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Unauthorized",
			})
		}
		// In production, validate JWT here
		return c.Next()
	}
}

// RoleMiddleware checks if the user has the required roles
func RoleMiddleware(allowedRoles ...string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Mock role extraction from context
		userRole := "CUSTOMER" 
		
		for _, role := range allowedRoles {
			if userRole == role {
				return c.Next()
			}
		}
		
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "Forbidden: Insufficient privileges",
		})
	}
}
