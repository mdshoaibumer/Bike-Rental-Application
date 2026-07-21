# Admin Fleet Management Architecture

## Module Overview
The Fleet Management module equips administrators with comprehensive tools to oversee the bike rental business. It operates independently from the customer-facing components but modifies the same underlying data models.

## Architecture

### 1. Admin Repository (`MockAdminRepositoryImpl`)
Acts as the central nervous system for admin operations. It holds authority over:
*   **Bike Fleet**: Creating, Updating, and Deleting bikes. 
*   **Booking Operations**: Retrieving all bookings and executing state transitions.
*   **Customers**: Accessing profiles and KYC information.
*   **Dashboard Metrics**: Calculating real-time statistics (Revenue, Pending Approvals, Active Rentals).

### 2. State Transition Flow (Bookings)
Administrators progress bookings through a strict linear timeline using the `AdminBookingDetailsViewModel`:
1. **PENDING_APPROVAL** -> Admin can select `APPROVE` or `REJECT`.
2. **APPROVED** -> Admin physically prepares the bike, selects `MARK READY`.
3. **READY_FOR_PICKUP** -> Customer arrives, Admin hands over keys, selects `START RENTAL (ACTIVE)`.
4. **ACTIVE** -> Customer returns bike, Admin inspects, selects `COMPLETE RENTAL`.

## Future Backend Mapping
To transition this module to a production API:
*   Replace `MockAdminRepositoryImpl` with `ApiAdminRepositoryImpl`.
*   **Dashboard**: Implement `GET /api/admin/dashboard` returning aggregated metrics.
*   **Bike CRUD**: Map to standard `POST /api/bikes`, `PUT /api/bikes/{id}`, `DELETE /api/bikes/{id}`. Ensure the backend handles cascading deletes safely (e.g. archiving bikes with past bookings instead of hard deletion).
*   **Booking Transitions**: Implement `PATCH /api/admin/bookings/{id}/status` taking the new state enum.
