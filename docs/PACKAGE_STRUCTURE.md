# Package Structure

The project follows a feature-driven modular package structure to ensure scalability and isolation.

```text
com.aistudio.bikerental.pzkbyq
│
├── core/
│   ├── common/         # Utility functions, extensions, and base classes (e.g., UiState)
│   ├── designsystem/   # Material 3 Theme, Colors, Typography, and shared UI Components
│   ├── mock/           # Mock data providers for local development (Phase 5)
│   ├── navigation/     # NavHost setup, Routes, and Graph definitions
│   ├── network/        # Retrofit setup, interceptors, error handling
│   └── storage/        # DataStore preferences, Room database setup
│
├── features/
│   ├── admin/          # Admin dashboard, bookings management, customer list
│   ├── auth/           # Login, OTP verification
│   ├── bike/           # Bike listing, search, details
│   ├── booking/        # Date picker, summary, success, booking history
│   ├── home/           # Customer home screen (discovery)
│   └── profile/        # User profile, settings, support
│
└── BikeRentalApplication.kt # Application class (Hilt & Timber initialization)
```

Each feature package should ideally contain its own UI (screens), ViewModels, and state definitions.
