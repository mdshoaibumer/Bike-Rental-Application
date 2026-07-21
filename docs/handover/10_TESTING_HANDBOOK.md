# Testing Handbook

## Android Testing Strategy
*   **Unit Tests**: Test ViewModels and Repositories using JUnit and MockK. Utilize `Turbine` to test StateFlow emissions.
*   **UI Tests**: Test Jetpack Compose screens using `compose:ui-test-junit4`. Validate click interactions, text presence, and navigation events.

## Backend Testing Strategy
*   **Unit Tests**: Test UseCases independently by mocking Repositories.
*   **Repository Tests**: Test SQL queries against a live, isolated Test Database (or use `testcontainers/testcontainers-go`).
*   **Integration (API) Tests**: Use Fiber's `app.Test()` to send simulated HTTP requests and assert JSON responses and status codes.

## End-to-End (Acceptance) Tests
Leverage tools like Postman (Newman) or Cypress to hit the live Docker API and ensure full end-to-end connectivity.
