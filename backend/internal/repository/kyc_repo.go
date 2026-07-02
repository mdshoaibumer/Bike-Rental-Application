package repository

import (
	"errors"
	"bike-rental/internal/domain"
)

type kycRepository struct {
	docs map[string]*domain.KYCDocument
}

func NewKYCRepository() domain.KYCRepository {
	return &kycRepository{
		docs: make(map[string]*domain.KYCDocument),
	}
}

func (r *kycRepository) CreateOrUpdate(doc *domain.KYCDocument) error {
	r.docs[doc.ID] = doc
	return nil
}

func (r *kycRepository) GetByID(id string) (*domain.KYCDocument, error) {
	if doc, exists := r.docs[id]; exists {
		return doc, nil
	}
	return nil, errors.New("kyc document not found")
}

func (r *kycRepository) GetByCustomerID(customerID string) (*domain.KYCDocument, error) {
	for _, doc := range r.docs {
		if doc.CustomerID == customerID {
			return doc, nil
		}
	}
	return nil, errors.New("kyc document not found")
}

func (r *kycRepository) ListPending(offset, limit int) ([]domain.KYCDocument, error) {
	var list []domain.KYCDocument
	for _, doc := range r.docs {
		if doc.Status == domain.KYCStatusPending {
			list = append(list, *doc)
		}
	}
	return list, nil
}
