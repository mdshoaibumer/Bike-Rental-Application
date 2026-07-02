package main

import (
	"os"
	"os/signal"
	"syscall"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	"bike-rental/internal/application"
	"bike-rental/internal/config"
	"bike-rental/internal/database"
	"bike-rental/internal/handler"
	"bike-rental/internal/middleware"
	"bike-rental/internal/repository"
)

func main() {
	// Configure structured logging
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	if os.Getenv("ENVIRONMENT") != "production" {
		log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})
	}

	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to load configuration")
	}

	// Connect to database
	pool, err := database.NewPostgresPool(cfg)
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to connect to database")
	}
	defer pool.Close()

	// Run migrations
	if err := database.RunMigrations(pool); err != nil {
		log.Fatal().Err(err).Msg("Failed to run migrations")
	}

	// Initialize Fiber app
	app := fiber.New(fiber.Config{
		ErrorHandler: middleware.CentralErrorHandler,
		BodyLimit:    5 * 1024 * 1024, // 5MB max body size
	})

	// Global middleware
	app.Use(recover.New())
	app.Use(middleware.SecurityHeaders())
	app.Use(middleware.RequestLogger())
	app.Use(cors.New(cors.Config{
		AllowOrigins:     cfg.CORSAllowOrigins,
		AllowMethods:     "GET,POST,PUT,PATCH,DELETE,OPTIONS",
		AllowHeaders:     "Origin,Content-Type,Accept,Authorization",
		AllowCredentials: true,
	}))

	// Health Endpoints
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok"})
	})
	app.Get("/ready", func(c *fiber.Ctx) error {
		if err := pool.Ping(c.Context()); err != nil {
			return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{"status": "not ready", "error": "database unavailable"})
		}
		return c.JSON(fiber.Map{"status": "ready"})
	})

	// Setup API Version 1
	api := app.Group("/api/v1")

	// --- Repositories ---
	userRepo := repository.NewUserRepository(pool)
	bikeRepo := repository.NewBikeRepository(pool)
	bookingRepo := repository.NewBookingRepository(pool)
	paymentRepo := repository.NewPaymentRepository(pool)
	kycRepo := repository.NewKYCRepository(pool)

	// --- Services ---
	authService := application.NewAuthService(userRepo, cfg)
	bikeService := application.NewBikeService(bikeRepo)
	bookingService := application.NewBookingService(bookingRepo, bikeRepo)
	paymentService := application.NewPaymentService(paymentRepo, nil)
	kycService := application.NewKYCService(kycRepo)

	// --- Handlers ---
	authHandler := handler.NewAuthHandler(authService)
	bikeHandler := handler.NewBikeHandler(bikeService)
	bookingHandler := handler.NewBookingHandler(bookingService)
	paymentHandler := handler.NewPaymentHandler(paymentService)
	kycHandler := handler.NewKYCHandler(kycService)

	// --- Auth Routes (with rate limiting) ---
	authGroup := api.Group("/auth")
	authGroup.Use(middleware.RateLimiter(cfg.RateLimitRequests, cfg.RateLimitWindow))
	authGroup.Post("/send-otp", authHandler.SendOTP)
	authGroup.Post("/verify-otp", authHandler.VerifyOTP)
	authGroup.Post("/login", authHandler.Login)
	authGroup.Post("/refresh", authHandler.RefreshToken)
	authGroup.Post("/logout", authHandler.Logout)

	// --- Protected Profile Routes ---
	profileGroup := api.Group("/profile")
	profileGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	profileGroup.Get("/", authHandler.GetProfile)
	profileGroup.Put("/", authHandler.UpdateProfile)
	profileGroup.Delete("/", authHandler.DeleteProfile)

	// --- Admin Routes ---
	adminGroup := api.Group("/admin")
	adminGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	adminGroup.Use(middleware.RoleMiddleware("ADMIN", "OWNER"))

	// Admin Bike Routes
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

	// Admin KYC Routes
	adminKYCGroup := adminGroup.Group("/kyc")
	adminKYCGroup.Get("/pending", kycHandler.GetPendingKYC)
	adminKYCGroup.Patch("/:id/approve", kycHandler.ApproveKYC)
	adminKYCGroup.Patch("/:id/reject", kycHandler.RejectKYC)

	// --- Public Bike Routes ---
	bikeGroup := api.Group("/bikes")
	bikeGroup.Get("/", bikeHandler.GetBikes)
	bikeGroup.Get("/search", bikeHandler.SearchBikes)
	bikeGroup.Get("/categories", bikeHandler.GetCategories)
	bikeGroup.Get("/:id", bikeHandler.GetBikeDetails)

	// --- Customer Booking Routes ---
	customerBookingGroup := api.Group("/bookings")
	customerBookingGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	customerBookingGroup.Post("/", bookingHandler.CreateBooking)
	customerBookingGroup.Get("/", bookingHandler.GetCustomerBookings)
	customerBookingGroup.Get("/history", bookingHandler.GetCustomerBookings)
	customerBookingGroup.Get("/:id", bookingHandler.GetBookingDetails)
	customerBookingGroup.Delete("/:id", bookingHandler.CancelBooking)

	// --- Payment Routes ---
	paymentGroup := api.Group("/payments")
	paymentGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	paymentGroup.Post("/create-order", paymentHandler.CreateOrder)
	paymentGroup.Post("/verify", paymentHandler.VerifyPayment)
	paymentGroup.Post("/refund", paymentHandler.ProcessRefund)
	paymentGroup.Get("/history", paymentHandler.GetPaymentHistory)
	paymentGroup.Get("/:id", paymentHandler.GetPaymentDetails)

	// Payment webhook (public, verified by signature)
	api.Post("/payments/webhook", paymentHandler.HandleWebhook)

	// --- KYC Routes (Customer) ---
	kycGroup := api.Group("/kyc")
	kycGroup.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	kycGroup.Post("/", kycHandler.UploadDocuments)
	kycGroup.Get("/", kycHandler.GetCustomerKYC)

	// Graceful shutdown
	go func() {
		if err := app.Listen(":" + cfg.Port); err != nil {
			log.Fatal().Err(err).Msg("Server failed to start")
		}
	}()

	log.Info().Str("port", cfg.Port).Str("env", cfg.Env).Msg("Server started")

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Info().Msg("Shutting down server...")
	if err := app.Shutdown(); err != nil {
		log.Error().Err(err).Msg("Server forced shutdown")
	}
	log.Info().Msg("Server exited gracefully")
}
