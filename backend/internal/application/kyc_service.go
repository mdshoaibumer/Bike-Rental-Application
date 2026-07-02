package application

import (
	"errors"
	"time"

	"bike-rental/internal/domain"
	"github.com/google/uuid"
)

type kycService struct {
	repo domain.KYCRepository
}

func NewKYCService(repo domain.KYCRepository) domain.KYCService {
	return &kycService{repo: repo}
}

func (s *kycService) UploadDocuments(customerID, dlURL, aadhaarURL string) (*domain.KYCDocument, error) {
	doc, err := s.repo.GetByCustomerID(customerID)
	if err == nil {
		// Update existing
		doc.DrivingLicenseURL = dlURL
		doc.AadhaarURL = aadhaarURL
		doc.Status = domain.KYCStatusPending
		doc.UpdatedAt = time.Now()
	} else {
		// Create new
		doc = &domain.KYCDocument{
			ID:               uuid.New().String(),
			CustomerID:       customerID,
			DrivingLicenseURL: dlURL,
			AadhaarURL:       aadhaarURL,
			Status:           domain.KYCStatusPending,
			CreatedAt:        time.Now(),
			UpdatedAt:        time.Now(),
		}
	}
	
	if err := s.repo.CreateOrUpdate(doc); err != nil {
		return nil, err
	}
	return doc, nil
}

func (s *kycService) GetCustomerKYC(customerID string) (*domain.KYCDocument, error) {
	return s.repo.GetByCustomerID(customerID)
}

func (s *kycService) GetPendingKYC(offset, limit int) ([]domain.KYCDocument, error) {
	return s.repo.ListPending(offset, limit)
}

func (s *kycService) ApproveKYC(id string) error {
	doc, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	if doc.Status != domain.KYCStatusPending {
		return errors.New("only pending kyc can be approved")
	}
	now := time.Now()
	doc.Status = domain.KYCStatusApproved
	doc.ApprovalDate = &now
	doc.UpdatedAt = now
	return s.repo.CreateOrUpdate(doc)
}

func (s *kycService) RejectKYC(id, reason string) error {
	doc, err := s.repo.GetByID(id)
	if err != nil {
		return err
	}
	if doc.Status != domain.KYCStatusPending {
		return errors.New("only pending kyc can be rejected")
	}
	doc.Status = domain.KYCStatusRejected
	doc.RejectReason = reason
	doc.UpdatedAt = time.Now()
	return s.repo.CreateOrUpdate(doc)
}
