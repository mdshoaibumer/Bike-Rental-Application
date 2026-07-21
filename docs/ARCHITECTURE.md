# Architecture Overview

## Foundation
This project follows a modern Android development stack:
- **Language:** Kotlin
- **UI Toolkit:** Jetpack Compose (Material 3)
- **Architecture Pattern:** MVVM (Model-View-ViewModel)
- **Dependency Injection:** Dagger Hilt
- **Navigation:** Navigation Compose
- **Serialization:** Kotlinx Serialization
- **Logging:** Timber
- **Asynchronous Programming:** Kotlin Coroutines & Flow

## Architectural Layers
1. **UI Layer (Features)**
   - Composables (Screens & UI components)
   - ViewModels (Managing UiState via StateFlow)
2. **Domain Layer (Optional for MVP)**
   - UseCases / Interactors
3. **Data Layer (Core)**
   - Repositories
   - Network (Retrofit/OkHttp)
   - Local Storage (DataStore / Room)
   - Mock Data Providers (For Phase 5)

## Design System
The design system is strictly enforced in `core/designsystem/`.
Do not use hardcoded colors or fonts in feature screens. Always use:
`MaterialTheme.colorScheme` and `MaterialTheme.typography`.
