# Phase 12 — Production Deployment & DevOps Guide

This guide provides setup, deployment, and deployment pipeline configuration instructions for launching the Bike Rental Platform into a production cloud environment.

---

## 1. Backend Containerization (Docker)
Our backend uses a multi-stage Docker build to keep production images secure and under 25MB:

```dockerfile
# Stage 1: Build binary
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main ./cmd/api

# Stage 2: Production scratch runtime
FROM alpine:3.18
RUN apk --no-cache add ca-certificates tzdata
WORKDIR /root/
COPY --from=builder /app/main .
COPY --from=builder /app/.env.example .env
EXPOSE 8080
CMD ["./main"]
```

### Docker Compose Production Environment
```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    container_name: bike_rental_db
    restart: always
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: bike_rental
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: bike_rental_backend
    restart: always
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=db
      - DB_PORT=5432
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=bike_rental
      - JWT_SECRET=${JWT_SECRET}
      - PORT=8080

volumes:
  postgres_data:
```

---

## 2. CI/CD Pipelines (GitHub Actions)
Our automated pipeline ensures that every commit is compiled, tested, and validated:

```yaml
name: Bike Rental Platform CI/CD

on:
  push:
    branches: [ main, release/* ]
  pull_request:
    branches: [ main ]

jobs:
  backend-test-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'

      - name: Run Backend Tests
        run: |
          cd backend
          go test -v ./...

      - name: Build Docker Image
        run: |
          docker build -t bike-rental-backend:latest ./backend

  flutter-test-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.x'
          channel: 'stable'

      - name: Install Flutter Dependencies
        run: |
          flutter pub get --directory=shared
          flutter pub get --directory=apps/customer_app
          flutter pub get --directory=apps/owner_app

      - name: Run Flutter Tests
        run: |
          flutter test --directory=shared
          flutter test --directory=apps/customer_app
          flutter test --directory=apps/owner_app

      - name: Build Android APK (Customer)
        run: |
          cd apps/customer_app
          flutter build apk --release --split-per-abi

      - name: Build Android App Bundle (Owner)
        run: |
          cd apps/owner_app
          flutter build appbundle --release
```

---

## 3. Play Store Release Strategy

### Application Signing Configurations
- Generate an upload key keystore: `keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias`
- Configure `android/key.properties` to map keystore passwords and aliases securely. Never commit the `.jks` file or passwords to version control.
- Leverage **Google Play App Signing** so that Google manages your delivery signing key, protecting your app from key loss.

### Play Console Checklist
- [ ] **Adaptive Icon Assets**: Ensure your launcher asset is properly formatted with background and foreground layers to match modern Android devices.
- [ ] **Privacy Policy Link**: Set up an active URL pointing to your GDPR and DPDP-compliant user agreement page.
- [ ] **Data Safety Questionnaire**: Inform users about the storage and processing of user data (e.g., location, phone number, and KYC document uploads).
- [ ] **Store Listing Images**: Upload 1080p screenshots for both apps on mobile and tablet form factors.

---

## 4. Production Go-Live Checklist
- [ ] **Database Encryption**: Verify PostgreSQL is configured to enforce connection TLS.
- [ ] **Secrets Integration**: Check that all secrets (JWT secrets, DB credentials) are loaded from secure production environment variables.
- [ ] **Rate Limiting**: Confirm rate limits are active on all public API endpoints.
- [ ] **Webhook Protection**: Verify webhook signatures are enabled for payment integrations.
- [ ] **CDN / Image Hosting**: Confirm that public images are hosted behind a secure CDN with cache headers configured.
- [ ] **Crash Analytics**: Integrate modern crash-reporting tools into the Flutter apps to monitor production errors.
