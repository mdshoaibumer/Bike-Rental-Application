package application

import (
	"errors"
	"bike-rental/internal/domain"
)

type bikeService struct {
	repo domain.BikeRepository
}

func NewBikeService(repo domain.BikeRepository) domain.BikeService {
	return &bikeService{repo: repo}
}

func (s *bikeService) AddBike(bike *domain.Bike) error {
	if bike.RegistrationNumber == "" {
		return errors.New("registration number is required")
	}
	if bike.RentalPrice <= 0 {
		return errors.New("rental price must be greater than zero")
	}
	return s.repo.Create(bike)
}

func (s *bikeService) EditBike(bike *domain.Bike) error {
	return s.repo.Update(bike)
}

func (s *bikeService) RemoveBike(id string) error {
	// Business Rule: Do not delete bikes with active bookings.
	// For now, simple delegate to repo. In real implementation, check bookings first.
	return s.repo.Delete(id)
}

func (s *bikeService) GetBikeDetails(id string) (*domain.Bike, error) {
	return s.repo.GetByID(id)
}

func (s *bikeService) GetBikes(offset, limit int) ([]domain.Bike, error) {
	return s.repo.List(offset, limit)
}

func (s *bikeService) SearchBikes(query string, offset, limit int) ([]domain.Bike, error) {
	return s.repo.Search(query, offset, limit)
}

func (s *bikeService) UpdateBikeAvailability(id, status string) error {
	validStatuses := map[string]bool{
		"Available": true, "Booked": true, "Reserved": true,
		"Maintenance": true, "Inactive": true,
	}
	if !validStatuses[status] {
		return errors.New("invalid status")
	}
	return s.repo.UpdateAvailability(id, status)
}

func (s *bikeService) GetCategories() ([]domain.BikeCategory, error) {
	return s.repo.GetCategories()
}
