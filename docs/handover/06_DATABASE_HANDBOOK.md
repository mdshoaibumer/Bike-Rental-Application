# Database Handbook

## Database Choice
**PostgreSQL 17** is chosen for its robust ACID compliance, JSONB capabilities (for future dynamic attributes), and strong concurrent read/write performance.

## ER Structure
*   **`users`**: Contains both `customer` and `admin` roles.
*   **`bikes`**: Inventory table.
*   **`categories`**: Grouping for bikes (e.g., "Scooter", "Cruiser").
*   **`bookings`**: The central transactional table.

## Key Constraints
*   All tables use `UUID v4` for primary keys.
*   `bookings.customer_id` and `bookings.bike_id` utilize `ON DELETE RESTRICT` to prevent accidental deletion of historical data.

## Migration Strategy
It is recommended to use `golang-migrate/migrate` or `pressly/goose`. The initial `schema.sql` is provided for bootstrap, but all future `ALTER TABLE` commands must be versioned.
