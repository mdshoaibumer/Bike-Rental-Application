package handler

import (
	"strconv"

	"bike-rental/internal/domain"

	"github.com/gofiber/fiber/v2"
)

type BikeHandler struct {
	service domain.BikeService
}

func NewBikeHandler(service domain.BikeService) *BikeHandler {
	return &BikeHandler{service: service}
}

// Admin handlers
func (h *BikeHandler) AddBike(c *fiber.Ctx) error {
	var bike domain.Bike
	if err := c.BodyParser(&bike); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if err := h.service.AddBike(&bike); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(bike)
}

func (h *BikeHandler) EditBike(c *fiber.Ctx) error {
	var bike domain.Bike
	if err := c.BodyParser(&bike); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	bike.ID = c.Params("id")
	if bike.ID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "bike id is required"})
	}
	if err := h.service.EditBike(&bike); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(bike)
}

func (h *BikeHandler) RemoveBike(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "bike id is required"})
	}
	if err := h.service.RemoveBike(id); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Bike deleted successfully"})
}

func (h *BikeHandler) UpdateAvailability(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "bike id is required"})
	}
	type Request struct {
		Status string `json:"status"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request"})
	}
	if err := h.service.UpdateBikeAvailability(id, req.Status); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Availability updated successfully"})
}

// Customer / Public handlers
func (h *BikeHandler) GetBikes(c *fiber.Ctx) error {
	offset, limit := parsePagination(c)
	bikes, err := h.service.GetBikes(offset, limit)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if bikes == nil {
		bikes = []domain.Bike{}
	}
	return c.JSON(fiber.Map{
		"data":   bikes,
		"offset": offset,
		"limit":  limit,
	})
}

func (h *BikeHandler) GetBikeDetails(c *fiber.Ctx) error {
	id := c.Params("id")
	if id == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "bike id is required"})
	}
	bike, err := h.service.GetBikeDetails(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "bike not found"})
	}
	return c.JSON(bike)
}

func (h *BikeHandler) SearchBikes(c *fiber.Ctx) error {
	query := c.Query("q")
	if query == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "search query 'q' is required"})
	}
	offset, limit := parsePagination(c)
	bikes, err := h.service.SearchBikes(query, offset, limit)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	if bikes == nil {
		bikes = []domain.Bike{}
	}
	return c.JSON(fiber.Map{
		"data":   bikes,
		"offset": offset,
		"limit":  limit,
	})
}

func (h *BikeHandler) GetCategories(c *fiber.Ctx) error {
	cats, err := h.service.GetCategories()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(cats)
}

// parsePagination extracts offset and limit from query parameters with safe defaults
func parsePagination(c *fiber.Ctx) (int, int) {
	offset := 0
	limit := 20

	if v := c.Query("offset"); v != "" {
		if parsed, err := strconv.Atoi(v); err == nil && parsed >= 0 {
			offset = parsed
		}
	}
	if v := c.Query("limit"); v != "" {
		if parsed, err := strconv.Atoi(v); err == nil && parsed > 0 && parsed <= 100 {
			limit = parsed
		}
	}
	return offset, limit
}
