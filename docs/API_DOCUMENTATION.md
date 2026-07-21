# API Reference Manual — Bike Rental Platform (v1.0)

All platform endpoints are version-prefixed under `/api/v1` and require communication via HTTPS.

---

## 1. Unified Success & Error Formats

### Error Response (HTTP 4xx/5xx)
```json
{
  "error": "Error details description goes here"
}
```

---

## 2. Authentication & JWT Credentials

### Send OTP Request
- **Endpoint**: `POST /api/v1/auth/otp/send`
- **Body**:
  ```json
  {
    "phone": "+919876543210"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "message": "OTP verification code sent successfully"
  }
  ```

### Verify OTP (Login)
- **Endpoint**: `POST /api/v1/auth/otp/verify`
- **Body**:
  ```json
  {
    "phone": "+919876543210",
    "code": "123456"
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NSIsIm5hbWUiOiJBbWl0IFNoYXJtYSIsIm9sZSI6IkNVU1RPTUVSIiwiZXhwIjoxNjg4MzEzNjAwfQ...",
    "role": "CUSTOMER"
  }
  ```

---

## 3. Bike Fleet Management (Auth Required)

### List Bikes (With Optional Pagination & Search Query)
- **Endpoint**: `GET /api/v1/bikes?limit=10&offset=0&search=Royal+Enfield`
- **Headers**: `Authorization: Bearer <JWT_TOKEN>`
- **Response (200 OK)**:
  ```json
  [
    {
      "id": "82a89304-4f0e-473d-9d21-f09dfd7a8e02",
      "model_name": "Royal Enfield Classic 350",
      "category": "Cruiser",
      "rental_price": 1200.00,
      "security_deposit": 5000.00,
      "is_available": true
    }
  ]
  ```

### Add New Bike (Requires Role: PARTNER or ADMIN)
- **Endpoint**: `POST /api/v1/bikes`
- **Headers**: `Authorization: Bearer <JWT_TOKEN>`
- **Body**:
  ```json
  {
    "model_name": "KTM Duke 390",
    "category": "Sport",
    "rental_price": 1800.00,
    "security_deposit": 7000.00
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "id": "e4c7d81a-2831-4b14-9ff5-5827392a819b",
    "model_name": "KTM Duke 390",
    "category": "Sport",
    "rental_price": 1800.00,
    "security_deposit": 7000.00,
    "is_available": true
  }
  ```

---

## 4. Bookings & Reservations (Auth Required)

### Create Booking
- **Endpoint**: `POST /api/v1/bookings`
- **Headers**: `Authorization: Bearer <JWT_TOKEN>`
- **Body**:
  ```json
  {
    "bike_id": "82a89304-4f0e-473d-9d21-f09dfd7a8e02",
    "pickup_date": "2026-07-05T10:00:00Z",
    "return_date": "2026-07-08T10:00:00Z"
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "booking_id": "bkg-90812-78d1",
    "bike_id": "82a89304-4f0e-473d-9d21-f09dfd7a8e02",
    "pickup_date": "2026-07-05T10:00:00Z",
    "return_date": "2026-07-08T10:00:00Z",
    "total_amount": 3600.00,
    "status": "PENDING"
  }
  ```

---

## 5. Webhooks & Integrations

### Razorpay / Stripe Payment Webhook
- **Endpoint**: `POST /api/v1/payments/webhook`
- **Headers**: `X-Webhook-Signature: sha256=abcdef123456...`
- **Body**:
  ```json
  {
    "event": "payment.captured",
    "payload": {
      "payment": {
        "entity": {
          "id": "pay_xyz123",
          "amount": 360000,
          "currency": "INR",
          "notes": {
            "booking_id": "bkg-90812-78d1"
          }
        }
      }
    }
  }
  ```
- **Response (200 OK)**:
  ```json
  {
    "status": "success",
    "message": "Payment recorded"
  }
  ```
