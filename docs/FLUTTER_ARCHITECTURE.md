# Flutter Architecture & Foundation

## Project Structure
We follow a Monorepo approach for our Flutter applications:
- `/apps/customer_app/`: The Customer facing application.
- `/apps/owner_app/`: The Owner/Admin facing application.
- `/shared/`: A shared Dart package containing UI components, theme, network configuration, and common utilities.

## Clean Architecture inside Flutter
Within `customer_app` and `owner_app`, the structure is:
- `lib/core/`: Application-wide configurations, constants, and utilities.
- `lib/features/`: Feature-based modules (e.g., Auth, Bikes, Bookings).
  - `presentation/`: UI screens, widgets, and state controllers (Riverpod).
  - `application/`: Application logic, use cases.
  - `domain/`: Entities and core interfaces.
  - `data/`: Repositories, DTOs, and API clients.

## Technology Stack
- **State Management**: Riverpod (`flutter_riverpod`)
- **Navigation**: GoRouter (`go_router`)
- **Networking**: Dio (`dio`)
- **Local Storage**: Flutter Secure Storage & Hive
- **Code Generation**: Freezed & JSON Serializable

## Theming
We use Material 3. The theme tokens, colors, typography, and reusable widgets are located in the `shared` package to ensure a consistent experience across both applications.
