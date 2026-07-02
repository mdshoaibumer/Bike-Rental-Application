package handler

import (
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
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(bike)
}

func (h *BikeHandler) EditBike(c *fiber.Ctx) error {
	var bike domain.Bike
	if err := c.BodyParser(&bike); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	bike.ID = c.Params("id")
	if err := h.service.EditBike(&bike); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(bike)
}

func (h *BikeHandler) RemoveBike(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.service.RemoveBike(id); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Bike deleted successfully"})
}

func (h *BikeHandler) UpdateAvailability(c *fiber.Ctx) error {
	id := c.Params("id")
	type Request struct {
		Status string `json:"status"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request"})
	}
	if err := h.service.UpdateBikeAvailability(id, req.Status); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(fiber.Map{"message": "Availability updated successfully"})
}

// Customer / Public handlers
func (h *BikeHandler) GetBikes(c *fiber.Ctx) error {
	bikes, err := h.service.GetBikes(0, 10) // Mock pagination
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(bikes)
}

func (h *BikeHandler) GetBikeDetails(c *fiber.Ctx) error {
	id := c.Params("id")
	bike, err := h.service.GetBikeDetails(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "bike not found"})
	}
	return c.JSON(bike)
}

func (h *BikeHandler) SearchBikes(c *fiber.Ctx) error {
	query := c.Query("q")
	bikes, err := h.service.SearchBikes(query, 0, 10) // Mock pagination
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(bikes)
}

func (h *BikeHandler) GetCategories(c *fiber.Ctx) error {
	cats, err := h.service.GetCategories()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(cats)
}
