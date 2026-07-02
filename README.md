# Bike Rental Application

An Enterprise-grade Bike Rental Platform featuring a dual-portal Customer app and Owner/Admin management console.

## Architecture

This project is built using a modern, scalable architecture:

*   **Backend System**: Written in **Go** following a clean architecture pattern (`backend/internal/...`). It includes structured domains, handlers, repositories, and services for entities like bikes, bookings, KYC, notifications, and payments.
*   **Mobile Applications**:
    *   **Native Android App**: Located in the `app/` directory, built with Kotlin and Jetpack Compose.
    *   **Flutter Customer App**: Located in `apps/customer_app/`, designed with modular features.
    *   **Flutter Owner App**: Located in `apps/owner_app/`, which includes management features for bikes, bookings, customers, and a dashboard.
*   **Shared Libraries**: A `shared/` Flutter package containing reusable networking, storage, theming, and UI widget components.

## Documentation

Extensive documentation is available in the `docs/` folder:

*   [API Documentation](docs/API_DOCUMENTATION.md)
*   [Architecture](docs/ARCHITECTURE.md)
*   [Database ERD](docs/DATABASE_ERD.md)
*   [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)

## Setup and Installation

Please refer to the [Installation Guide](docs/INSTALLATION_GUIDE.md) for detailed instructions on setting up the backend and mobile applications locally.
