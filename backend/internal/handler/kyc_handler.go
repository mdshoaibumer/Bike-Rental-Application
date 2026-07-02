package handler

import (
	"bike-rental/internal/domain"
	"github.com/gofiber/fiber/v2"
)

type KYCHandler struct {
	service domain.KYCService
}

func NewKYCHandler(service domain.KYCService) *KYCHandler {
	return &KYCHandler{service: service}
}

func (h *KYCHandler) UploadDocuments(c *fiber.Ctx) error {
	customerID := "mock-customer-id" // from JWT
	type Request struct {
		DrivingLicenseURL string `json:"driving_license_url"`
		AadhaarURL        string `json:"aadhaar_url"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request"})
	}

	doc, err := h.service.UploadDocuments(customerID, req.DrivingLicenseURL, req.AadhaarURL)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(doc)
}

func (h *KYCHandler) GetCustomerKYC(c *fiber.Ctx) error {
	customerID := "mock-customer-id"
	doc, err := h.service.GetCustomerKYC(customerID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "kyc document not found"})
	}
	return c.JSON(doc)
}

// Admin Endpoints
func (h *KYCHandler) GetPendingKYC(c *fiber.Ctx) error {
	docs, err := h.service.GetPendingKYC(0, 10)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(docs)
}

func (h *KYCHandler) ApproveKYC(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.service.ApproveKYC(id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "KYC approved successfully"})
}

func (h *KYCHandler) RejectKYC(c *fiber.Ctx) error {
	id := c.Params("id")
	type Request struct {
		Reason string `json:"reason"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request"})
	}

	if err := h.service.RejectKYC(id, req.Reason); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "KYC rejected successfully"})
}
