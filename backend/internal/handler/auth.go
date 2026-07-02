package handler

import (
	"github.com/gofiber/fiber/v2"
)

type AuthHandler struct {}

func NewAuthHandler() *AuthHandler {
	return &AuthHandler{}
}

func (h *AuthHandler) SendOTP(c *fiber.Ctx) error {
	// TODO: Integrate MSG91 / Twilio
	return c.JSON(fiber.Map{"message": "OTP sent successfully"})
}

func (h *AuthHandler) VerifyOTP(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"message": "OTP verified successfully"})
}

func (h *AuthHandler) Login(c *fiber.Ctx) error {
	// TODO: Issue JWT upon valid OTP/Password
	return c.JSON(fiber.Map{
		"access_token": "eyJhbGciOiJIUzI1NiIsInR5...",
		"refresh_token": "dGhpc2lzYXJlZnJlc2h0b2tlbjEyMzQ1Njc4OTA=",
	})
}

func (h *AuthHandler) RefreshToken(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"message": "Token refreshed"})
}

func (h *AuthHandler) Logout(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"message": "Successfully logged out"})
}

func (h *AuthHandler) GetProfile(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"profile": "User Profile Data"})
}

func (h *AuthHandler) UpdateProfile(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"message": "Profile updated"})
}

func (h *AuthHandler) DeleteProfile(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{"message": "Profile soft deleted"})
}
