# API Handbook

All endpoints expect `Content-Type: application/json`.
Protected endpoints expect `Authorization: Bearer <token>`.

## Common Responses
*   `200 OK`: Success.
*   `400 Bad Request`: Validation failure.
*   `401 Unauthorized`: Missing or invalid JWT.
*   `403 Forbidden`: Insufficient role permissions.
*   `409 Conflict`: Business rule violation (e.g., date overlap).

## Core Endpoints
### Authentication
`POST /api/auth/login/customer`
*   **Body**: `{"phone": "+91...", "otp": "..."}`
*   **Returns**: `{"token": "..."}`

### Bikes
`GET /api/bikes`
*   **Query**: `?category_id=uuid` (optional)
*   **Returns**: `[{"id": "...", "name": "..."}]`

### Bookings (Customer)
`POST /api/bookings`
*   **Body**: `{"bike_id": "...", "pickup_date": "YYYY-MM-DD", ...}`

### Admin
`PATCH /api/admin/bookings/{id}/status`
*   **Body**: `{"status": "APPROVED"}`
