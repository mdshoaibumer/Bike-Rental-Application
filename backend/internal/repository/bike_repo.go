package repository

import (
	"errors"
	"bike-rental/internal/domain"
)

type bikeRepository struct {
	bikes map[string]*domain.Bike
}

func NewBikeRepository() domain.BikeRepository {
	return &bikeRepository{
		bikes: make(map[string]*domain.Bike),
	}
}

func (r *bikeRepository) Create(bike *domain.Bike) error {
	if _, exists := r.bikes[bike.ID]; exists {
		return errors.New("bike already exists")
	}
	r.bikes[bike.ID] = bike
	return nil
}

func (r *bikeRepository) Update(bike *domain.Bike) error {
	if _, exists := r.bikes[bike.ID]; !exists {
		return errors.New("bike not found")
	}
	r.bikes[bike.ID] = bike
	return nil
}

func (r *bikeRepository) Delete(id string) error {
	if _, exists := r.bikes[id]; !exists {
		return errors.New("bike not found")
	}
	delete(r.bikes, id)
	return nil
}

func (r *bikeRepository) GetByID(id string) (*domain.Bike, error) {
	if bike, exists := r.bikes[id]; exists {
		return bike, nil
	}
	return nil, errors.New("bike not found")
}

func (r *bikeRepository) List(offset, limit int) ([]domain.Bike, error) {
	var list []domain.Bike
	for _, b := range r.bikes {
		list = append(list, *b)
	}
	return list, nil
}

func (r *bikeRepository) Search(query string, offset, limit int) ([]domain.Bike, error) {
	var list []domain.Bike
	for _, b := range r.bikes {
		if b.BikeName == query || b.CategoryID == query || b.Brand == query {
			list = append(list, *b)
		}
	}
	return list, nil
}

func (r *bikeRepository) UpdateAvailability(id, status string) error {
	bike, exists := r.bikes[id]
	if !exists {
		return errors.New("bike not found")
	}
	bike.AvailabilityStatus = status
	return nil
}

func (r *bikeRepository) GetCategories() ([]domain.BikeCategory, error) {
	return []domain.BikeCategory{
		{ID: "1", Name: "Scooter", Description: "Scooters and mopeds"},
		{ID: "2", Name: "Electric", Description: "Electric bikes"},
		{ID: "3", Name: "Sports", Description: "Sports bikes"},
		{ID: "4", Name: "Cruiser", Description: "Cruiser bikes"},
		{ID: "5", Name: "Adventure", Description: "Adventure and off-road"},
		{ID: "6", Name: "Premium", Description: "Premium segment"},
		{ID: "7", Name: "Touring", Description: "Touring bikes"},
	}, nil
}
