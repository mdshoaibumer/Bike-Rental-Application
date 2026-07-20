# Architecture Handbook

## Overall Architecture
The Bike Rental Platform is a client-server distributed system.
*   **Client**: Native Android App (Kotlin).
*   **Server**: Go API (Fiber v3).
*   **Database**: PostgreSQL 17.

## Module Responsibilities
*   **Android Presentation**: Captures user input, handles UI state via StateFlow.
*   **Android Domain/Data**: `Api*RepositoryImpl` translates local domain calls into Retrofit HTTP requests.
*   **Go Delivery (HTTP)**: Parses incoming requests, validates JWTs, and invokes Use Cases.
*   **Go Use Cases**: Enforces business logic (e.g., "Cannot book if dates overlap").
*   **Go Repository**: Executes parameterized SQL queries.

## Extension Points
*   **Payment Gateway**: Intercept the `APPROVED` to `READY_FOR_PICKUP` transition to trigger an intent to a payment provider.
*   **Notifications**: Emit an event from the Go Booking UseCase to an SNS/FCM worker queue.
