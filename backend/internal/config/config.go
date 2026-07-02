package config

import (
	"os"
)

type Config struct {
	Port      string
	DBDSN     string
	JWTSecret string
	Env       string
}

func LoadConfig() (*Config, error) {
	// Simple mock implementation of Viper/Env config loading
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "super-secret-development-key"
	}

	return &Config{
		Port:      port,
		DBDSN:     os.Getenv("DATABASE_URL"),
		JWTSecret: jwtSecret,
		Env:       os.Getenv("ENVIRONMENT"),
	}, nil
}
