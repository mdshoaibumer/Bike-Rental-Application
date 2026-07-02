package main

import (
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"

	"bike-rental/internal/application"
	"bike-rental/internal/config"
	"bike-rental/internal/handler"
	"bike-rental/internal/middleware"
	"bike-rental/internal/repository"
)

func main() {
	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	app := fiber.New(fiber.Config{
		ErrorHandler: middleware.CentralErrorHandler,
	})

	// Middleware
	app.Use(recover.New())
	app.Use(logger.New())
	app.Use(cors.New())

	// Health Endpoints
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok"})
	})
	app.Get("/ready", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ready"})
	})

	// Setup API Version 1
	api := app.Group("/api/v1")

	// Auth Routes (Phase 5)
	authHandler := handler.NewAuthHandler()
	authGroup := api.Group("/auth")
	authGroup.Post("/send-otp", authHandler.SendOTP)
	authGroup.Post("/verify-otp", authHandler.VerifyOTP)
	authGroup.Post("/login", authHandler.Login)
	authGroup.Post("/refresh", authHandler.RefreshToken)
	authGroup.Post("/logout", authHandler.Logout)

	// Protected Profile Routes
	profileGroup := api.Group("/profile")
	profileGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	profileGroup.Get("/", authHandler.GetProfile)
	profileGroup.Put("/", authHandler.UpdateProfile)
	profileGroup.Delete("/", authHandler.DeleteProfile)

	// Bike Module (Phase 6)
	bikeRepo := repository.NewBikeRepository()
	bikeService := application.NewBikeService(bikeRepo)
	bikeHandler := handler.NewBikeHandler(bikeService)

	// Booking Module (Phase 7)
	bookingRepo := repository.NewBookingRepository()
	bookingService := application.NewBookingService(bookingRepo, bikeRepo)
	bookingHandler := handler.NewBookingHandler(bookingService)

	// Admin Bike Routes
	adminGroup := api.Group("/admin")
	adminGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	adminGroup.Use(middleware.RoleMiddleware("ADMIN", "OWNER"))
	
	adminBikeGroup := adminGroup.Group("/bikes")
	adminBikeGroup.Post("/", bikeHandler.AddBike)
	adminBikeGroup.Put("/:id", bikeHandler.EditBike)
	adminBikeGroup.Delete("/:id", bikeHandler.RemoveBike)
	adminBikeGroup.Get("/", bikeHandler.GetBikes)
	adminBikeGroup.Get("/:id", bikeHandler.GetBikeDetails)
	adminBikeGroup.Patch("/:id/availability", bikeHandler.UpdateAvailability)

	// Admin Booking Routes
	adminBookingGroup := adminGroup.Group("/bookings")
	adminBookingGroup.Get("/", bookingHandler.GetAdminBookings)
	adminBookingGroup.Get("/:id", bookingHandler.GetBookingDetails)
	adminBookingGroup.Patch("/:id/approve", bookingHandler.ApproveBooking)
	adminBookingGroup.Patch("/:id/reject", bookingHandler.RejectBooking)
	adminBookingGroup.Patch("/:id/pickup", bookingHandler.MarkPickedUp)
	adminBookingGroup.Patch("/:id/return", bookingHandler.MarkReturned)
	adminBookingGroup.Patch("/:id/complete", bookingHandler.CompleteBooking)

	// Customer/Public Bike Routes
	bikeGroup := api.Group("/bikes")
	bikeGroup.Get("/", bikeHandler.GetBikes)
	bikeGroup.Get("/search", bikeHandler.SearchBikes)
	bikeGroup.Get("/categories", bikeHandler.GetCategories)
	bikeGroup.Get("/:id", bikeHandler.GetBikeDetails)

	// Customer Booking Routes
	customerBookingGroup := api.Group("/bookings")
	customerBookingGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	customerBookingGroup.Post("/", bookingHandler.CreateBooking)
	customerBookingGroup.Get("/", bookingHandler.GetCustomerBookings)
	customerBookingGroup.Get("/history", bookingHandler.GetCustomerBookings)
	customerBookingGroup.Get("/:id", bookingHandler.GetBookingDetails)
	customerBookingGroup.Delete("/:id", bookingHandler.CancelBooking)

	// Payment Module (Phase 8)
	paymentRepo := repository.NewPaymentRepository()
	paymentService := application.NewPaymentService(paymentRepo, nil) // Mock Gateway for now
	paymentHandler := handler.NewPaymentHandler(paymentService)

	// KYC Module (Phase 8)
	kycRepo := repository.NewKYCRepository()
	kycService := application.NewKYCService(kycRepo)
	kycHandler := handler.NewKYCHandler(kycService)

	// Payment Routes
	paymentGroup := api.Group("/payments")
	paymentGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	paymentGroup.Post("/create-order", paymentHandler.CreateOrder)
	paymentGroup.Post("/verify", paymentHandler.VerifyPayment)
	paymentGroup.Post("/refund", paymentHandler.ProcessRefund)
	paymentGroup.Get("/history", paymentHandler.GetPaymentHistory)
	paymentGroup.Get("/:id", paymentHandler.GetPaymentDetails)
	// Webhook is typically public
	api.Post("/payments/webhook", paymentHandler.HandleWebhook)

	// KYC Routes (Customer)
	kycGroup := api.Group("/kyc")
	kycGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	kycGroup.Post("/", kycHandler.UploadDocuments)
	kycGroup.Get("/", kycHandler.GetCustomerKYC)

	// KYC Admin Routes
	adminKYCGroup := adminGroup.Group("/kyc")
	adminKYCGroup.Get("/pending", kycHandler.GetPendingKYC)
	adminKYCGroup.Patch("/:id/approve", kycHandler.ApproveKYC)
	adminKYCGroup.Patch("/:id/reject", kycHandler.RejectKYC)

	log.Printf("Starting server on port %s", cfg.Port)
	if err := app.Listen(":" + cfg.Port); err != nil {
		log.Fatalf("Error starting server: %v", err)
	}
}
