# Security Handbook (OWASP Compliance)

## Authentication & Authorization
*   **JWT**: Tokens are signed using `HS256`. The secret key must be deeply randomized in production and rotated every 90 days.
*   **Android Storage**: Tokens MUST be stored in `EncryptedSharedPreferences`. Never use standard `SharedPreferences` or plaintext variables.

## Common Vulnerability Prevention
*   **SQL Injection**: Prevented globally by the exclusive use of parameterized queries via `pgx` in the Go Repository layer.
*   **XSS (Cross Site Scripting)**: Android Compose natively sanitizes strings. Go Fiber strictly returns `application/json`.
*   **Brute Force**: (Pending V1.1) `fiber/middleware/limiter` must be applied to `/api/auth/login`.

## Secrets Management
Never commit `.env` files. CI/CD pipelines (GitHub Actions/GitLab CI) must inject environment variables at runtime.
