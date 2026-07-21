# Android Handbook

## Architecture
The Android client strictly adheres to **MVVM (Model-View-ViewModel)** layered with **Clean Architecture**.
*   **UI Layer**: Jetpack Compose screens reading from `StateFlow`.
*   **Presentation Layer**: ViewModels extending `androidx.lifecycle.ViewModel`, exposing `UiState` sealed classes.
*   **Domain Layer**: Repositories (e.g., `BikeRepository`) defined by interfaces.
*   **Data Layer**: `Api*RepositoryImpl` integrating Retrofit to fulfill Domain contracts.

## Navigation
Driven by `Navigation Compose` in `BikeRentalNavHost.kt`.
The app is split into distinct graphs:
*   `auth_graph`: Login, OTP.
*   `customer_graph`: Catalog, Details, History.
*   `admin_graph`: Fleet Management, Booking Workflows.

## Theming & Design System
Located in `core/designsystem/`.
*   Uses `MaterialTheme.colorScheme`.
*   Standardized typography overrides.
*   Atomic components: `PrimaryButton`, `SecondaryButton`, `MetricCard`.
