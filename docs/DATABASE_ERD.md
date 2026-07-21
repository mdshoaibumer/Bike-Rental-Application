# Database Architecture & ERD

## Entity Relationship Diagram (PostgreSQL)

```mermaid
erDiagram
    USERS ||--o{ USER_ADDRESSES : "has"
    USERS ||--o{ KYC_DOCUMENTS : "submits"
    USERS ||--o{ BOOKINGS : "makes"
    USERS ||--o{ REVIEWS : "writes"
    USERS ||--o{ NOTIFICATIONS : "receives"

    ROLES ||--o{ USERS : "assigned_to"

    BIKE_CATEGORIES ||--o{ BIKES : "categorizes"
    BIKES ||--o{ BIKE_IMAGES : "has"
    BIKES ||--o{ BIKES_AVAILABILITY : "tracked_in"
    BIKES ||--o{ MAINTENANCE : "undergoes"
    BIKES ||--o{ BOOKINGS : "rented_in"
    BIKES ||--o{ REVIEWS : "receives"

    BOOKINGS ||--o| PAYMENTS : "paid_via"
    COUPONS ||--o{ BOOKINGS : "applied_to"

    USERS {
        uuid id PK
        string full_name
        string mobile
        string email
        string password_hash "nullable"
        uuid role_id FK
        string status "ACTIVE, INACTIVE, SUSPENDED"
        timestamp created_at
        timestamp updated_at
    }

    ROLES {
        uuid id PK
        string name "ADMIN, OWNER, CUSTOMER"
        string permissions
    }

    BIKES {
        uuid id PK
        string bike_name
        string brand
        string model
        int engine_cc
        string registration_number "UNIQUE"
        string fuel_type
        string transmission
        string color
        string description
        string status "ACTIVE, MAINTENANCE, RETIRED"
        decimal rental_price_per_day
        decimal security_deposit
        int current_odometer
        date insurance_expiry
        string rc_details
        date pollution_certificate_expiry
        uuid category_id FK
        timestamp created_at
        timestamp updated_at
    }

    BOOKINGS {
        uuid id PK
        string booking_number "UNIQUE"
        uuid customer_id FK
        uuid bike_id FK
        timestamp pickup_date
        timestamp return_date
        int duration_days
        decimal price
        decimal deposit
        decimal taxes
        decimal discount
        decimal final_amount
        string booking_status "PENDING, CONFIRMED, ACTIVE, COMPLETED, CANCELLED"
        string payment_status "PENDING, PAID, REFUNDED"
        uuid coupon_id FK "nullable"
        timestamp created_at
        timestamp updated_at
    }

    PAYMENTS {
        uuid id PK
        uuid booking_id FK
        string gateway
        string transaction_id
        decimal amount
        string status "SUCCESS, FAILED, PENDING"
        string method "UPI, CARD, NETBANKING"
        timestamp created_at
    }
```

## Normalization & Performance
*   **UUIDs**: All tables use UUIDv4 for Primary Keys.
*   **Indexes**: 
    *   B-Tree Indexes on `mobile` and `email` in `USERS`.
    *   B-Tree Index on `booking_number` in `BOOKINGS`.
    *   Composite Indexes on `(bike_id, pickup_date, return_date)` for fast availability checking.
*   **Soft Deletes**: Implemented via `deleted_at` timestamp on Users and Bikes.
*   **Cascading**: 
    *   `RESTRICT` on deleting a user with active bookings.
    *   `CASCADE` on deleting a user's session/OTP records.
