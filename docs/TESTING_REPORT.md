# Phase 12 — Testing Strategy & QA Report

To ensure functional reliability, prevent regressions, and ensure the safety of payment flows, we have formulated a strict testing matrix spanning unit, widget, and integration domains.

---

## 1. Test Coverage Goals
The project targets the following coverage standards prior to final release:
- **Go Backend**: Minimum **80%** test coverage (focusing on validation logic, booking states, and RBAC auth rules).
- **Flutter Client Apps**: Minimum **80%** test coverage (focusing on Riverpod controller state machines, error handlers, and key UI screens).

---

## 2. Go Backend Testing Matrix

### Unit Testing
Backend business logic (e.g., booking pricing and availability checks) is unit tested using mock repository structures:
- Tests verify correct pricing calculations under various rental periods.
- Tests verify that duplicate booking requests on conflicting dates throw an `ErrOverlapConflict` error.

### Repository Testing
Database interactions are tested using mock databases (e.g., Sqlmock) or containerized integration databases:
- Verifies database constraints (such as preventing negative rental pricing or invalid date ranges) reject incorrect values.
- Verifies database transactions rollback properly on execution errors.

### Integration (API) Testing
We test our Fiber HTTP endpoints using the built-in HTTP request helpers:
- Checks that restricted paths reject requests missing valid JWT tokens with a `401 Unauthorized` status.
- Validates role checks, ensuring a user with a `CUSTOMER` token receives a `403 Forbidden` response when trying to access admin endpoints.

---

## 3. Flutter Client Testing Matrix

### Unit & Controller Testing
- Tests mock our HTTP client (`Dio`) to return static mock payloads (e.g., successful logins, active bookings) and verify that Riverpod state providers update correctly.
- Verifies that error-response interceptors transition the UI state to `AsyncError`, enabling user-facing retry actions.

### Widget Testing
- Widget tests verify that important screen elements render correctly.
- Checks that our loading shimmer widgets display while state provider streams are active, and vanish once the success state is loaded.
- Validates form validation rules, checking that empty phone fields trigger an immediate inline error.

---

## 4. Automation & Testing Script Setup
We have configured standard automation scripts in our project runner to streamline testing pipelines:

### Backend Test Script
```bash
# Run all backend unit and integration tests
cd backend && go test -v -coverprofile=coverage.out ./...
```

### Flutter Test Script
```bash
# Run tests for customer app, owner app, and shared package
cd apps/customer_app && flutter test
cd ../owner_app && flutter test
cd ../../shared && flutter test
```
