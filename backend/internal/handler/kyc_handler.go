package handler

import (
	"bike-rental/internal/domain"
	"bike-rental/internal/middleware"

	"github.com/gofiber/fiber/v2"
)

type KYCHandler struct {
	service domain.KYCService
}

func NewKYCHandler(service domain.KYCService) *KYCHandler {
	return &KYCHandler{service: service}
}

func (h *KYCHandler) UploadDocuments(c *fiber.Ctx) error {
	customerID := middleware.GetUserID(c)
	if customerID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	type Request struct {
		DrivingLicenseURL string `json:"driving_license_url"`
		AadhaarURL        string `json:"aadhaar_url"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request"})
	}
	if req.DrivingLicenseURL == "" || req.AadhaarURL == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "both driving_license_url and aadhaar_url are required"})
	}

	doc, err := h.service.UploadDocuments(customerID, req.DrivingLicenseURL, req.AadhaarURL)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(doc)
}

func (h *KYCHandler) GetCustomerKYC(c *fiber.Ctx) error {
	customerID := middleware.GetUserID(c)
	if customerID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	doc, err := h.service.GetCustomerKYC(customerID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "kyc document not found"})
	}
	return c.JSON(doc)
}

// Admin Endpoints
func (h *KYCHandler) GetPendingKYC(c *fiber.Ctx) error {
	offset, limit := parsePagination(c)
	docs, err := h.service.GetPendingKYC(offset, limit)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if docs == nil {
		docs = []domain.KYCDocument{}
	}
	return c.JSON(fiber.Map{
		"data":   docs,
		"offset": offset,
		"limit":  limit,
	})
}

func (h *KYCHandler) ApproveKYC(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "kyc document id is required"})
	}
	if err := h.service.ApproveKYC(id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "KYC approved successfully"})
}

func (h *KYCHandler) RejectKYC(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "kyc document id is required"})
	}
	type Request struct {
		Reason string `json:"reason"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request"})
	}
	if req.Reason == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "rejection reason is required"})
	}

	if err := h.service.RejectKYC(id, req.Reason); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "KYC rejected successfully"})
}
