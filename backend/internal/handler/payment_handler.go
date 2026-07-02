package handler

import (
	"bike-rental/internal/domain"
	"github.com/gofiber/fiber/v2"
)

type PaymentHandler struct {
	service domain.PaymentService
}

func NewPaymentHandler(service domain.PaymentService) *PaymentHandler {
	return &PaymentHandler{service: service}
}

func (h *PaymentHandler) CreateOrder(c *fiber.Ctx) error {
	type Request struct {
		BookingID string  `json:"booking_id"`
		Amount    float64 `json:"amount"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request"})
	}

	payment, err := h.service.CreateOrder(req.BookingID, req.Amount)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(payment)
}

func (h *PaymentHandler) VerifyPayment(c *fiber.Ctx) error {
	type Request struct {
		PaymentID     string `json:"payment_id"`
		TransactionID string `json:"transaction_id"`
		Signature     string `json:"signature"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request"})
	}

	if err := h.service.VerifyPayment(req.PaymentID, req.TransactionID, req.Signature); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Payment verified successfully"})
}

func (h *PaymentHandler) HandleWebhook(c *fiber.Ctx) error {
	signature := c.Get("X-Webhook-Signature")
	payload := c.Body()

	if err := h.service.HandleWebhook(payload, signature); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.SendStatus(fiber.StatusOK)
}

func (h *PaymentHandler) GetPaymentDetails(c *fiber.Ctx) error {
	id := c.Params("id")
	payment, err := h.service.GetPaymentDetails(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "payment not found"})
	}
	return c.JSON(payment)
}

func (h *PaymentHandler) GetPaymentHistory(c *fiber.Ctx) error {
	payments, err := h.service.GetPaymentHistory(0, 10)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(payments)
}

func (h *PaymentHandler) ProcessRefund(c *fiber.Ctx) error {
	type Request struct {
		PaymentID string  `json:"payment_id"`
		Amount    float64 `json:"amount"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request"})
	}

	if err := h.service.ProcessRefund(req.PaymentID, req.Amount); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Refund processed successfully"})
}
