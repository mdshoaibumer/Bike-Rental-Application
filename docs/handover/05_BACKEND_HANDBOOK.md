# Backend Handbook

## Framework
*   **Language**: Go 1.24+
*   **HTTP Router**: Fiber v3
*   **Configuration**: Viper (reads `.env`)
*   **Logging**: Uber Zap

## Clean Architecture Flow
1.  **Router/Delivery (`cmd/api/` & `internal/delivery/http/`)**: Defines HTTP paths, applies Auth/Rate-Limiting Middleware, parses JSON bodies.
2.  **UseCase (`internal/usecase/`)**: Contains the pure business logic. E.g., `BookingUseCase` checks if a bike is already booked for the requested dates.
3.  **Repository (`internal/repository/`)**: Converts Domain objects to SQL rows and vice versa using `pgx`.

## Security Middleware
*   **JWT Middleware**: Intercepts requests, validates the RS256/HS256 signature, extracts the user ID and Role, and attaches it to the Fiber Context (`c.Locals("user")`).
