# Bike Rental REST API Documentation

## Overview
The backend API is built using Go 1.24 and Fiber v3. It interfaces with a PostgreSQL 17 database.
All protected routes require a `Bearer <JWT>` token.

## Endpoints

### 1. Authentication
- `POST /api/auth/login/customer`
  - Body: `{ "phone": "+91...", "otp": "123456" }`
  - Returns: `{ "token": "jwt_token", "user": { ... } }`
- `POST /api/auth/login/admin`
  - Body: `{ "email": "admin@example.com", "password": "password123" }`
  - Returns: `{ "token": "jwt_token", "user": { ... } }`

### 2. Bike Catalog
- `GET /api/bikes` - List available bikes with optional `?category=` and `?sort=` parameters.
- `GET /api/bikes/{id}` - Get bike details.

### 3. Bookings (Customer)
- `POST /api/bookings`
  - Body: `{ "bike_id": "uuid", "pickup_date": "YYYY-MM-DD", ... }`
  - Validates date overlaps before inserting.
- `GET /api/bookings/me` - List customer's booking history.

### 4. Admin Operations (Requires Admin Role)
- `GET /api/admin/dashboard` - Returns metrics (revenue, active rentals, pending approvals).
- `GET /api/admin/bookings` - List all bookings in the system.
- `PATCH /api/admin/bookings/{id}/status`
  - Body: `{ "status": "APPROVED" | "READY_FOR_PICKUP" | "ACTIVE" | "COMPLETED" }`
- `POST /api/admin/bikes` - Add a new bike.
- `PUT /api/admin/bikes/{id}` - Edit bike details.
- `DELETE /api/admin/bikes/{id}` - Soft delete a bike.
- `GET /api/admin/customers` - Directory of registered users.

## Docker Deployment
1. Start the infrastructure:
   ```bash
   cd backend
   docker-compose up -d
   ```
2. The Go Fiber API will be accessible at `http://localhost:8080`.
3. PostgreSQL is available at `localhost:5432`.
