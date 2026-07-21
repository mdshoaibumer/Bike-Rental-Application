package domain

import (
	"time"
)

type Bike struct {
	ID                 string      `json:"id"`
	BikeName           string      `json:"bike_name"`
	Brand              string      `json:"brand"`
	Model              string      `json:"model"`
	EngineCC           int         `json:"engine_cc"`
	RegistrationNumber string      `json:"registration_number"`
	FuelType           string      `json:"fuel_type"`
	Transmission       string      `json:"transmission"`
	Mileage            float64     `json:"mileage"`
	Color              string      `json:"color"`
	Description        string      `json:"description"`
	RentalPrice        float64     `json:"rental_price"`
	SecurityDeposit    float64     `json:"security_deposit"`
	AvailabilityStatus string      `json:"availability_status"`
	InsuranceExpiry    time.Time   `json:"insurance_expiry"`
	CurrentOdometer    int         `json:"current_odometer"`
	CategoryID         string      `json:"category_id"`
	OwnerID            string      `json:"owner_id"`
	Images             []BikeImage `json:"images,omitempty"`
	CreatedAt          time.Time   `json:"created_at"`
	UpdatedAt          time.Time   `json:"updated_at"`
}

type BikeCategory struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

type BikeImage struct {
	ID        string `json:"id"`
	BikeID    string `json:"bike_id"`
	ImageURL  string `json:"image_url"`
	IsPrimary bool   `json:"is_primary"`
	OrderIdx  int    `json:"order_idx"`
}

// Interfaces
type BikeRepository interface {
	Create(bike *Bike) error
	Update(bike *Bike) error
	Delete(id string) error
	GetByID(id string) (*Bike, error)
	List(offset, limit int) ([]Bike, error)
	Search(query string, offset, limit int) ([]Bike, error)
	UpdateAvailability(id, status string) error
	GetCategories() ([]BikeCategory, error)
}

type BikeService interface {
	AddBike(bike *Bike) error
	EditBike(bike *Bike) error
	RemoveBike(id string) error
	GetBikeDetails(id string) (*Bike, error)
	GetBikes(offset, limit int) ([]Bike, error)
	SearchBikes(query string, offset, limit int) ([]Bike, error)
	UpdateBikeAvailability(id, status string) error
	GetCategories() ([]BikeCategory, error)
}
