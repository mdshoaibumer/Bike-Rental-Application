package handler

import (
	"time"

	"bike-rental/internal/domain"
	"bike-rental/internal/middleware"

	"github.com/gofiber/fiber/v2"
)

type BookingHandler struct {
	service domain.BookingService
}

func NewBookingHandler(service domain.BookingService) *BookingHandler {
	return &BookingHandler{service: service}
}

// --- Customer Endpoints ---

func (h *BookingHandler) CreateBooking(c *fiber.Ctx) error {
	customerID := middleware.GetUserID(c)
	if customerID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	type Request struct {
		BikeID     string    `json:"bike_id"`
		PickupDate time.Time `json:"pickup_date"`
		ReturnDate time.Time `json:"return_date"`
	}

	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request format"})
	}
	if req.BikeID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "bike_id is required"})
	}

	booking, err := h.service.CreateBooking(customerID, req.BikeID, req.PickupDate, req.ReturnDate)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(booking)
}

func (h *BookingHandler) GetCustomerBookings(c *fiber.Ctx) error {
	customerID := middleware.GetUserID(c)
	if customerID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	offset, limit := parsePagination(c)
	bookings, err := h.service.GetCustomerBookings(customerID, offset, limit)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if bookings == nil {
		bookings = []domain.Booking{}
	}
	return c.JSON(fiber.Map{
		"data":   bookings,
		"offset": offset,
		"limit":  limit,
	})
}

func (h *BookingHandler) GetBookingDetails(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "booking id is required"})
	}
	booking, err := h.service.GetBooking(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "booking not found"})
	}

	// Authorization: verify ownership unless admin/owner
	userID := middleware.GetUserID(c)
	userRole := middleware.GetUserRole(c)
	if userRole != "ADMIN" && userRole != "OWNER" && booking.CustomerID != userID {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "access denied"})
	}

	return c.JSON(booking)
}

func (h *BookingHandler) CancelBooking(c *fiber.Ctx) error {
	id := c.Params("id")
	customerID := middleware.GetUserID(c)
	if customerID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}
	if err := h.service.CancelBooking(id, customerID); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Booking cancelled successfully"})
}

// --- Admin Endpoints ---

func (h *BookingHandler) GetAdminBookings(c *fiber.Ctx) error {
	offset, limit := parsePagination(c)
	bookings, err := h.service.GetAdminBookings(offset, limit)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if bookings == nil {
		bookings = []domain.Booking{}
	}
	return c.JSON(fiber.Map{
		"data":   bookings,
		"offset": offset,
		"limit":  limit,
	})
}

func (h *BookingHandler) ApproveBooking(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "booking id is required"})
	}
	if err := h.service.ApproveBooking(id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Booking approved successfully"})
}

func (h *BookingHandler) RejectBooking(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "booking id is required"})
	}
	if err := h.service.RejectBooking(id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Booking rejected successfully"})
}

func (h *BookingHandler) MarkPickedUp(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "booking id is required"})
	}
	if err := h.service.MarkPickedUp(id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Bike marked as picked up"})
}

func (h *BookingHandler) MarkReturned(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "booking id is required"})
	}
	if err := h.service.MarkReturned(id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Bike marked as returned"})
}

func (h *BookingHandler) CompleteBooking(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "booking id is required"})
	}
	if err := h.service.CompleteBooking(id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Booking marked as completed"})
}
