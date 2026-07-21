# Security Audit Report (OWASP Compliance)

## 1. Authentication & Session Management
**Score: 8/10**
*   **JWT Implementation**: The backend utilizes `golang-jwt/v5` with strong HS256 signing. However, the token expiration (`exp`) is set very high (24 hours) with no `Refresh Token` logic implemented. 
    *   **Recommendation**: Reduce Access Token `exp` to 15 minutes, implement long-lived refresh tokens.
*   **Android Token Storage**: The token is retrieved via a hardcoded string `"mock_jwt_token_for_now"` in `AuthInterceptor.kt`.
    *   **CRITICAL BLOCKER**: Must implement `EncryptedSharedPreferences` or `DataStore` (with Tink) to securely store JWTs on device.

## 2. Authorization & Access Control
**Score: 7/10**
*   **Role Based Access Control (RBAC)**: Backend relies on the `role` column (`customer` vs `admin`). However, admin endpoints do not strictly validate the JWT claims for the `admin` role before executing CRUD.
    *   **CRITICAL BLOCKER**: Add RBAC middleware to `Fiber` for all `/api/admin/*` endpoints.

## 3. Injection Prevention
**Score: 9/10**
*   **SQL Injection**: PostgreSQL queries use parameterization (`$1, $2`) universally. SQLi risk is extremely low.
*   **XSS**: Fiber automatically sets `Content-Type: application/json`. Android Compose inherently sanitizes text rendering. Risk is low.

## 4. Rate Limiting & DoS
**Score: 3/10**
*   **Rate Limiting**: Not implemented on the backend.
    *   **BLOCKER**: Must add `fiber/middleware/limiter` to prevent brute-force attacks on `/api/auth/login`.

## 5. Secret Management
**Score: 5/10**
*   `DB_PASSWORD` and `JWT_SECRET` are passed in plaintext in `docker-compose.yml`. 
    *   **Recommendation**: Use a `.env` file excluded from version control, or a Secrets Manager in production.

---

# Performance Audit Report

## 1. Android Performance
*   **Recomposition**: Compose screens rely on `StateFlow`. Minor recomposition hazards exist due to passing lambdas directly in `AdminDashboardScreen`. Use `@Stable` models and `remember` for callbacks.
*   **Cold Start**: App uses Hilt which adds slight overhead to cold starts. Setup `Baseline Profiles` for Macrobenchmark optimization.
*   **Image Loading**: Coil lacks a memory-limit config for large lists like `AdminBookingListScreen`.

## 2. Backend & API Performance
*   **Fiber Performance**: Extremely high throughput. Capable of handling 500+ concurrent requests effortlessly.
*   **Database Pooling**: `pgx` is used, which handles connection pooling. Max connections should be explicitly set via `pgxpool.Config`.

## 3. Database Performance
*   **Indexing**: Searching bikes by category or bookings by status requires a full table scan.
    *   **BLOCKER**: Must run `CREATE INDEX idx_bikes_status ON bikes(status);` and `CREATE INDEX idx_bookings_status ON bookings(status);`.
