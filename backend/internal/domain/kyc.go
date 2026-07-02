package domain

import "time"

const (
	KYCStatusPending  = "PENDING"
	KYCStatusApproved = "APPROVED"
	KYCStatusRejected = "REJECTED"
)

type KYCDocument struct {
	ID               string     `json:"id"`
	CustomerID       string     `json:"customer_id"`
	DrivingLicenseURL string    `json:"driving_license_url"`
	AadhaarURL       string     `json:"aadhaar_url"`
	Status           string     `json:"status"`
	RejectReason     string     `json:"reject_reason,omitempty"`
	ApprovalDate     *time.Time `json:"approval_date,omitempty"`
	CreatedAt        time.Time  `json:"created_at"`
	UpdatedAt        time.Time  `json:"updated_at"`
}

type KYCRepository interface {
	CreateOrUpdate(doc *KYCDocument) error
	GetByID(id string) (*KYCDocument, error)
	GetByCustomerID(customerID string) (*KYCDocument, error)
	ListPending(offset, limit int) ([]KYCDocument, error)
}

type KYCService interface {
	UploadDocuments(customerID, dlURL, aadhaarURL string) (*KYCDocument, error)
	GetCustomerKYC(customerID string) (*KYCDocument, error)
	GetPendingKYC(offset, limit int) ([]KYCDocument, error)
	ApproveKYC(id string) error
	RejectKYC(id, reason string) error
}
