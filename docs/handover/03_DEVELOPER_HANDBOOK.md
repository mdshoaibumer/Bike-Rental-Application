# Developer Handbook (Knowledge Transfer)

Welcome to the Bike Rental Platform engineering team!

## Folder Structure
*   `/app/src/main/java/.../pzkbyq/`: Core Android Application.
    *   `core/`: Design system, Network (Retrofit), DI (Hilt).
    *   `features/`: Isolated by domain (`auth`, `bike`, `booking`, `admin`).
*   `/backend/`: The Go API.
    *   `cmd/api/`: Application entry point (`main.go`).
    *   `internal/`: Clean architecture layers (`delivery`, `usecase`, `repository`).
*   `/docs/handover/`: This documentation suite.

## Building the Project
### Backend
```bash
cd backend
docker-compose up --build -d
```
The API is available at `http://localhost:8080`.

### Android
Open the root `e:\bike-rental` in Android Studio. Ensure the device/emulator is connected to the same network as the Docker host (or use `10.0.2.2` for local emulators).

## Coding Standards
*   **Android**: Strict adherence to MVVM. No business logic in Composables.
*   **Go**: Idiomatic Go. Use `zap` for logging. Always return `error` up the chain; do not `panic()`.
