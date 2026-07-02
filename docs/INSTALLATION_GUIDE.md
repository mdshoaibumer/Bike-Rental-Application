# Installation & Developer Setup Guide — Bike Rental Platform (v1.0)

This document provides setup instructions for developers and DevOps engineers to establish local, sandbox, and staging environments for the Bike Rental Platform.

---

## 1. Prerequisites
Ensure you have the following tools installed on your local development workstation:
- **Go**: Version 1.21 or later
- **Flutter**: SDK Version 3.19.x (Stable)
- **Docker & Docker Compose** (Highly recommended for database services)
- **PostgreSQL**: Version 15 or later (if deploying bare-metal locally)

---

## 2. Environment Variables (.env Template)
Create an `.env` file at the root of `/backend` based on the following template:

```env
# Server Configuration
PORT=8080
ENV=development

# Security Configurations
JWT_SECRET=super_secret_jwt_hmac_signing_key_2026_bike_rental
TOKEN_EXPIRY_HOURS=24

# PostgreSQL Relational Database Settings
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres_password_xyz
DB_NAME=bike_rental
DB_SSLMODE=disable

# Payment Integration Configurations
RAZORPAY_KEY_ID=rzp_test_mock_id_12345
RAZORPAY_SECRET=rzp_test_mock_secret_abcde
RAZORPAY_WEBHOOK_SECRET=rzp_webhook_secret_67890
```

---

## 3. Go Backend Installation (Local Setup)

1. **Clone & Navigate**:
   ```bash
   cd backend
   ```
2. **Download Dependencies**:
   ```bash
   go mod download
   ```
3. **Run Database Migrations** (or spin up database services using Docker Compose):
   ```bash
   docker compose up -d db
   ```
4. **Compile & Run Server**:
   ```bash
   go run cmd/api/main.go
   ```
   The API gateway will start on `http://localhost:8080/`. You can verify by visiting `http://localhost:8080/health`.

---

## 4. Flutter Setup (Customer & Owner Apps)

Our monorepo utilizes a `/shared` package to consolidate core styling, Material 3 configurations, and API connections.

1. **Resolve Shared Package Dependencies**:
   ```bash
   cd shared
   flutter pub get
   ```
2. **Setup Customer Application**:
   ```bash
   cd ../apps/customer_app
   flutter pub get
   ```
3. **Setup Owner/Admin Console**:
   ```bash
   cd ../owner_app
   flutter pub get
   ```
4. **Compile / Run locally**:
   Ensure you have an active emulator or device connected:
   ```bash
   flutter run -d <device_id_or_emulator>
   ```

---

## 5. Reverse Proxy Configuration (Nginx Staging & Production)
For secure public access, route your backend traffic through an Nginx reverse proxy to manage SSL terminations and secure headers:

```nginx
server {
    listen 80;
    server_name api.bikerentalhub.com;
    return 301 https://$host$request_uri; # Force HTTPS
}

server {
    listen 443 ssl http2;
    server_name api.bikerentalhub.com;

    ssl_certificate /etc/letsencrypt/live/api.bikerentalhub.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.bikerentalhub.com/privkey.pem;

    # High security protocols and ciphers
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305';

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Protect against slow-loris attacks
        client_body_timeout 10s;
        client_header_timeout 10s;
    }
}
```
