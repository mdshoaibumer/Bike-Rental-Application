package application

import (
	"testing"

	"bike-rental/internal/domain"
)

// Mock KYC repository
type mockKYCRepo struct {
	docs map[string]*domain.KYCDocument
}

func newMockKYCRepo() *mockKYCRepo {
	return &mockKYCRepo{docs: make(map[string]*domain.KYCDocument)}
}

func (m *mockKYCRepo) CreateOrUpdate(doc *domain.KYCDocument) error {
	m.docs[doc.ID] = doc
	return nil
}

func (m *mockKYCRepo) GetByID(id string) (*domain.KYCDocument, error) {
	if d, ok := m.docs[id]; ok {
		return d, nil
	}
	return nil, domain.ErrNotFound
}

func (m *mockKYCRepo) GetByCustomerID(customerID string) (*domain.KYCDocument, error) {
	for _, d := range m.docs {
		if d.CustomerID == customerID {
			return d, nil
		}
	}
	return nil, domain.ErrNotFound
}

func (m *mockKYCRepo) ListPending(offset, limit int) ([]domain.KYCDocument, error) {
	var result []domain.KYCDocument
	for _, d := range m.docs {
		if d.Status == domain.KYCStatusPending {
			result = append(result, *d)
		}
	}
	return result, nil
}

func TestKYCService_UploadDocuments(t *testing.T) {
	repo := newMockKYCRepo()
	service := NewKYCService(repo)

	doc, err := service.UploadDocuments("cust-1", "https://storage.example.com/dl.jpg", "https://storage.example.com/aadhaar.jpg")
	if err != nil {
		t.Fatalf("UploadDocuments() unexpected error: %v", err)
	}
	if doc == nil {
		t.Fatal("UploadDocuments() returned nil")
	}
	if doc.Status != domain.KYCStatusPending {
		t.Errorf("expected status PENDING, got %q", doc.Status)
	}
	if doc.CustomerID != "cust-1" {
		t.Errorf("expected customer_id 'cust-1', got %q", doc.CustomerID)
	}
}

func TestKYCService_UploadDocuments_UpdateExisting(t *testing.T) {
	repo := newMockKYCRepo()
	service := NewKYCService(repo)

	// First upload
	doc1, _ := service.UploadDocuments("cust-1", "https://old-dl.jpg", "https://old-aadhaar.jpg")

	// Second upload should update
	doc2, err := service.UploadDocuments("cust-1", "https://new-dl.jpg", "https://new-aadhaar.jpg")
	if err != nil {
		t.Fatalf("UploadDocuments() update error: %v", err)
	}
	if doc2.ID != doc1.ID {
		t.Error("expected same document to be updated")
	}
	if doc2.DrivingLicenseURL != "https://new-dl.jpg" {
		t.Errorf("expected updated DL URL, got %q", doc2.DrivingLicenseURL)
	}
}

func TestKYCService_ApproveKYC(t *testing.T) {
	repo := newMockKYCRepo()
	service := NewKYCService(repo)

	doc, _ := service.UploadDocuments("cust-1", "https://dl.jpg", "https://aadhaar.jpg")

	err := service.ApproveKYC(doc.ID)
	if err != nil {
		t.Fatalf("ApproveKYC() unexpected error: %v", err)
	}

	updated, _ := service.GetCustomerKYC("cust-1")
	if updated.Status != domain.KYCStatusApproved {
		t.Errorf("expected status APPROVED, got %q", updated.Status)
	}
	if updated.ApprovalDate == nil {
		t.Error("expected approval_date to be set")
	}
}

func TestKYCService_ApproveKYC_NotPending(t *testing.T) {
	repo := newMockKYCRepo()
	service := NewKYCService(repo)

	doc, _ := service.UploadDocuments("cust-1", "https://dl.jpg", "https://aadhaar.jpg")
	_ = service.ApproveKYC(doc.ID)

	// Try approving again
	err := service.ApproveKYC(doc.ID)
	if err == nil {
		t.Error("expected error for non-pending KYC approval")
	}
}

func TestKYCService_RejectKYC(t *testing.T) {
	repo := newMockKYCRepo()
	service := NewKYCService(repo)

	doc, _ := service.UploadDocuments("cust-1", "https://dl.jpg", "https://aadhaar.jpg")

	err := service.RejectKYC(doc.ID, "Document is blurry")
	if err != nil {
		t.Fatalf("RejectKYC() unexpected error: %v", err)
	}

	updated, _ := service.GetCustomerKYC("cust-1")
	if updated.Status != domain.KYCStatusRejected {
		t.Errorf("expected status REJECTED, got %q", updated.Status)
	}
	if updated.RejectReason != "Document is blurry" {
		t.Errorf("expected reject reason 'Document is blurry', got %q", updated.RejectReason)
	}
}

func TestKYCService_RejectKYC_NotPending(t *testing.T) {
	repo := newMockKYCRepo()
	service := NewKYCService(repo)

	doc, _ := service.UploadDocuments("cust-1", "https://dl.jpg", "https://aadhaar.jpg")
	_ = service.RejectKYC(doc.ID, "bad")

	// Try rejecting again
	err := service.RejectKYC(doc.ID, "another reason")
	if err == nil {
		t.Error("expected error for non-pending KYC rejection")
	}
}

func TestKYCService_GetPendingKYC(t *testing.T) {
	repo := newMockKYCRepo()
	service := NewKYCService(repo)

	_, _ = service.UploadDocuments("cust-1", "https://dl1.jpg", "https://a1.jpg")
	_, _ = service.UploadDocuments("cust-2", "https://dl2.jpg", "https://a2.jpg")

	docs, err := service.GetPendingKYC(0, 10)
	if err != nil {
		t.Fatalf("GetPendingKYC() unexpected error: %v", err)
	}
	if len(docs) != 2 {
		t.Errorf("expected 2 pending docs, got %d", len(docs))
	}
}

func TestKYCService_GetCustomerKYC_NotFound(t *testing.T) {
	repo := newMockKYCRepo()
	service := NewKYCService(repo)

	_, err := service.GetCustomerKYC("nonexistent")
	if err == nil {
		t.Error("expected error for non-existent KYC")
	}
}
