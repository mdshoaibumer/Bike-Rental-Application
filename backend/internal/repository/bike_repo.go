package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"bike-rental/internal/domain"
)

type bikeRepository struct {
	pool *pgxpool.Pool
}

func NewBikeRepository(pool *pgxpool.Pool) domain.BikeRepository {
	return &bikeRepository{pool: pool}
}

func (r *bikeRepository) Create(bike *domain.Bike) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		INSERT INTO bikes (id, bike_name, brand, model, engine_cc, registration_number, 
			fuel_type, transmission, mileage, color, description, rental_price, 
			security_deposit, availability_status, insurance_expiry, current_odometer, 
			category_id, owner_id, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)`

	_, err := r.pool.Exec(ctx, query,
		bike.ID, bike.BikeName, bike.Brand, bike.Model, bike.EngineCC,
		bike.RegistrationNumber, bike.FuelType, bike.Transmission, bike.Mileage,
		bike.Color, bike.Description, bike.RentalPrice, bike.SecurityDeposit,
		bike.AvailabilityStatus, bike.InsuranceExpiry, bike.CurrentOdometer,
		bike.CategoryID, bike.OwnerID, bike.CreatedAt, bike.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to create bike: %w", err)
	}
	return nil
}

func (r *bikeRepository) Update(bike *domain.Bike) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		UPDATE bikes SET bike_name=$1, brand=$2, model=$3, engine_cc=$4,
			registration_number=$5, fuel_type=$6, transmission=$7, mileage=$8,
			color=$9, description=$10, rental_price=$11, security_deposit=$12,
			availability_status=$13, insurance_expiry=$14, current_odometer=$15,
			category_id=$16, updated_at=$17
		WHERE id=$18 AND deleted_at IS NULL`

	result, err := r.pool.Exec(ctx, query,
		bike.BikeName, bike.Brand, bike.Model, bike.EngineCC,
		bike.RegistrationNumber, bike.FuelType, bike.Transmission, bike.Mileage,
		bike.Color, bike.Description, bike.RentalPrice, bike.SecurityDeposit,
		bike.AvailabilityStatus, bike.InsuranceExpiry, bike.CurrentOdometer,
		bike.CategoryID, time.Now(), bike.ID,
	)
	if err != nil {
		return fmt.Errorf("failed to update bike: %w", err)
	}
	if result.RowsAffected() == 0 {
		return fmt.Errorf("bike not found")
	}
	return nil
}

func (r *bikeRepository) Delete(id string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Soft delete
	query := `UPDATE bikes SET deleted_at = NOW(), updated_at = NOW() WHERE id = $1 AND deleted_at IS NULL`
	result, err := r.pool.Exec(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete bike: %w", err)
	}
	if result.RowsAffected() == 0 {
		return fmt.Errorf("bike not found")
	}
	return nil
}

func (r *bikeRepository) GetByID(id string) (*domain.Bike, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		SELECT id, bike_name, brand, model, engine_cc, registration_number,
			fuel_type, transmission, mileage, color, description, rental_price,
			security_deposit, availability_status, insurance_expiry, current_odometer,
			category_id, owner_id, created_at, updated_at
		FROM bikes WHERE id = $1 AND deleted_at IS NULL`

	bike := &domain.Bike{}
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&bike.ID, &bike.BikeName, &bike.Brand, &bike.Model, &bike.EngineCC,
		&bike.RegistrationNumber, &bike.FuelType, &bike.Transmission, &bike.Mileage,
		&bike.Color, &bike.Description, &bike.RentalPrice, &bike.SecurityDeposit,
		&bike.AvailabilityStatus, &bike.InsuranceExpiry, &bike.CurrentOdometer,
		&bike.CategoryID, &bike.OwnerID, &bike.CreatedAt, &bike.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("bike not found")
	}
	return bike, nil
}

func (r *bikeRepository) List(offset, limit int) ([]domain.Bike, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	query := `
		SELECT id, bike_name, brand, model, engine_cc, registration_number,
			fuel_type, transmission, mileage, color, description, rental_price,
			security_deposit, availability_status, insurance_expiry, current_odometer,
			category_id, owner_id, created_at, updated_at
		FROM bikes WHERE deleted_at IS NULL
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2`

	rows, err := r.pool.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list bikes: %w", err)
	}
	defer rows.Close()

	var bikes []domain.Bike
	for rows.Next() {
		var bike domain.Bike
		if err := rows.Scan(
			&bike.ID, &bike.BikeName, &bike.Brand, &bike.Model, &bike.EngineCC,
			&bike.RegistrationNumber, &bike.FuelType, &bike.Transmission, &bike.Mileage,
			&bike.Color, &bike.Description, &bike.RentalPrice, &bike.SecurityDeposit,
			&bike.AvailabilityStatus, &bike.InsuranceExpiry, &bike.CurrentOdometer,
			&bike.CategoryID, &bike.OwnerID, &bike.CreatedAt, &bike.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan bike: %w", err)
		}
		bikes = append(bikes, bike)
	}
	return bikes, nil
}

func (r *bikeRepository) Search(query string, offset, limit int) ([]domain.Bike, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	searchQuery := `
		SELECT id, bike_name, brand, model, engine_cc, registration_number,
			fuel_type, transmission, mileage, color, description, rental_price,
			security_deposit, availability_status, insurance_expiry, current_odometer,
			category_id, owner_id, created_at, updated_at
		FROM bikes 
		WHERE deleted_at IS NULL 
			AND (LOWER(bike_name) LIKE LOWER($1) OR LOWER(brand) LIKE LOWER($1) OR LOWER(model) LIKE LOWER($1))
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`

	searchTerm := "%" + query + "%"
	rows, err := r.pool.Query(ctx, searchQuery, searchTerm, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to search bikes: %w", err)
	}
	defer rows.Close()

	var bikes []domain.Bike
	for rows.Next() {
		var bike domain.Bike
		if err := rows.Scan(
			&bike.ID, &bike.BikeName, &bike.Brand, &bike.Model, &bike.EngineCC,
			&bike.RegistrationNumber, &bike.FuelType, &bike.Transmission, &bike.Mileage,
			&bike.Color, &bike.Description, &bike.RentalPrice, &bike.SecurityDeposit,
			&bike.AvailabilityStatus, &bike.InsuranceExpiry, &bike.CurrentOdometer,
			&bike.CategoryID, &bike.OwnerID, &bike.CreatedAt, &bike.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan bike: %w", err)
		}
		bikes = append(bikes, bike)
	}
	return bikes, nil
}

func (r *bikeRepository) UpdateAvailability(id, status string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `UPDATE bikes SET availability_status = $1, updated_at = NOW() WHERE id = $2 AND deleted_at IS NULL`
	result, err := r.pool.Exec(ctx, query, status, id)
	if err != nil {
		return fmt.Errorf("failed to update availability: %w", err)
	}
	if result.RowsAffected() == 0 {
		return fmt.Errorf("bike not found")
	}
	return nil
}

func (r *bikeRepository) GetCategories() ([]domain.BikeCategory, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `SELECT id, name, description FROM bike_categories ORDER BY name`
	rows, err := r.pool.Query(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("failed to get categories: %w", err)
	}
	defer rows.Close()

	var categories []domain.BikeCategory
	for rows.Next() {
		var cat domain.BikeCategory
		if err := rows.Scan(&cat.ID, &cat.Name, &cat.Description); err != nil {
			return nil, fmt.Errorf("failed to scan category: %w", err)
		}
		categories = append(categories, cat)
	}
	return categories, nil
}
