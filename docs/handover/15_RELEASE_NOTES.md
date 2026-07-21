# Release Notes: Version 1.0 (MVP)

**Release Date:** Q3 2026
**Target Platform:** Android (Client), Linux/Docker (Server)

## What's Included in V1.0
*   **Complete Customer Android App**: Material 3 interface featuring OTP login, dynamic Bike Catalog with real-time filtering, and a robust Booking Engine with date-conflict prevention.
*   **Integrated Admin Dashboard**: Mobile administrative views to manage fleet operations, track metrics, and approve bookings via a strict state machine.
*   **Production Go Backend**: High-performance REST API built on Fiber v3, featuring Clean Architecture and full JWT security.
*   **PostgreSQL Database**: Normalized schema utilizing UUIDs, protecting against orphaned data and ensuring data integrity.
*   **Dockerized Deployment**: A one-click `docker-compose` environment standing up the API and Database simultaneously.

## Known Limitations / Missing Features (Pending V1.1)
*   **Payment Gateway**: Currently, bookings are logged with total amounts but no actual financial transaction occurs. Integration with Razorpay/Stripe is required.
*   **Push Notifications / SMS**: Handover updates currently rely on customer polling. FCM integration is pending.
*   **Offline Support**: Android app requires an active internet connection to load the catalog.
*   **Pagination**: The backend currently returns all bookings/bikes in single large arrays.
