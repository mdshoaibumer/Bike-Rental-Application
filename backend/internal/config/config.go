package config

import (
	"errors"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	Port               string
	DBDSN              string
	JWTSecret          string
	JWTExpiry          time.Duration
	RefreshTokenExpiry time.Duration
	Env                string
	DBMaxOpenConns     int
	DBMaxIdleConns     int
	DBConnMaxLifetime  time.Duration
	RateLimitRequests  int
	RateLimitWindow    time.Duration
	CORSAllowOrigins   string
}

func LoadConfig() (*Config, error) {
	// Load .env file if it exists (non-fatal if missing)
	_ = godotenv.Load()

	port := getEnv("PORT", "8080")
	env := getEnv("ENVIRONMENT", "development")

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		if env == "production" {
			return nil, errors.New("JWT_SECRET environment variable is required in production")
		}
		jwtSecret = "dev-only-secret-change-in-production"
	}
	if len(jwtSecret) < 32 {
		if env == "production" {
			return nil, errors.New("JWT_SECRET must be at least 32 characters in production")
		}
	}

	dbDSN := os.Getenv("DATABASE_URL")
	if dbDSN == "" {
		return nil, errors.New("DATABASE_URL environment variable is required")
	}

	jwtExpiryMinutes := getEnvInt("JWT_EXPIRY_MINUTES", 60)
	refreshExpiryHours := getEnvInt("REFRESH_TOKEN_EXPIRY_HOURS", 168) // 7 days
	dbMaxOpen := getEnvInt("DB_MAX_OPEN_CONNS", 50)
	dbMaxIdle := getEnvInt("DB_MAX_IDLE_CONNS", 10)
	dbLifetimeMin := getEnvInt("DB_CONN_MAX_LIFETIME_MINUTES", 30)
	rateLimitReqs := getEnvInt("RATE_LIMIT_REQUESTS", 100)
	rateLimitWindowSec := getEnvInt("RATE_LIMIT_WINDOW_SECONDS", 60)
	corsOrigins := getEnv("CORS_ALLOW_ORIGINS", "*")
	if env == "production" && corsOrigins == "*" {
		return nil, errors.New("CORS_ALLOW_ORIGINS must not be '*' in production")
	}

	return &Config{
		Port:               port,
		DBDSN:              dbDSN,
		JWTSecret:          jwtSecret,
		JWTExpiry:          time.Duration(jwtExpiryMinutes) * time.Minute,
		RefreshTokenExpiry: time.Duration(refreshExpiryHours) * time.Hour,
		Env:                env,
		DBMaxOpenConns:     dbMaxOpen,
		DBMaxIdleConns:     dbMaxIdle,
		DBConnMaxLifetime:  time.Duration(dbLifetimeMin) * time.Minute,
		RateLimitRequests:  rateLimitReqs,
		RateLimitWindow:    time.Duration(rateLimitWindowSec) * time.Second,
		CORSAllowOrigins:   corsOrigins,
	}, nil
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if val := os.Getenv(key); val != "" {
		if i, err := strconv.Atoi(val); err == nil {
			return i
		}
	}
	return fallback
}
