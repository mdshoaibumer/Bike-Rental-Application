package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"bike-rental/internal/domain"
)

type kycRepository struct {
	pool *pgxpool.Pool
}

func NewKYCRepository(pool *pgxpool.Pool) domain.KYCRepository {
	return &kycRepository{pool: pool}
}

func (r *kycRepository) CreateOrUpdate(doc *domain.KYCDocument) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
		INSERT INTO kyc_documents (id, customer_id, driving_license_url, aadhaar_url, status, reject_reason, approval_date, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (id) DO UPDATE SET
			driving_license_url = EXCLUDED.driving_license_url,
			aadhaar_url = EXCLUDED.aadhaar_url,
			status = EXCLUDED.status,
			reject_reason = EXCLUDED.reject_reason,
			approval_date = EXCLUDED.approval_date,
			updated_at = NOW()`

	_, err := r.pool.Exec(ctx, query,
		doc.ID, doc.CustomerID, doc.DrivingLicenseURL, doc.AadhaarURL,
		doc.Status, doc.RejectReason, doc.ApprovalDate, doc.CreatedAt, doc.UpdatedAt,
	)
	if err != nil {
		return fmt.Errorf("failed to upsert kyc document: %w", err)
	}
	return nil
}

func (r *kycRepository) GetByID(id string) (*domain.KYCDocument, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `SELECT id, customer_id, driving_license_url, aadhaar_url, status, reject_reason, approval_date, created_at, updated_at
		FROM kyc_documents WHERE id = $1`

	doc := &domain.KYCDocument{}
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&doc.ID, &doc.CustomerID, &doc.DrivingLicenseURL, &doc.AadhaarURL,
		&doc.Status, &doc.RejectReason, &doc.ApprovalDate, &doc.CreatedAt, &doc.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("kyc document not found")
	}
	return doc, nil
}

func (r *kycRepository) GetByCustomerID(customerID string) (*domain.KYCDocument, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `SELECT id, customer_id, driving_license_url, aadhaar_url, status, reject_reason, approval_date, created_at, updated_at
		FROM kyc_documents WHERE customer_id = $1 ORDER BY created_at DESC LIMIT 1`

	doc := &domain.KYCDocument{}
	err := r.pool.QueryRow(ctx, query, customerID).Scan(
		&doc.ID, &doc.CustomerID, &doc.DrivingLicenseURL, &doc.AadhaarURL,
		&doc.Status, &doc.RejectReason, &doc.ApprovalDate, &doc.CreatedAt, &doc.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("kyc document not found")
	}
	return doc, nil
}

func (r *kycRepository) ListPending(offset, limit int) ([]domain.KYCDocument, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if limit <= 0 {
		limit = 20
	}

	query := `SELECT id, customer_id, driving_license_url, aadhaar_url, status, reject_reason, approval_date, created_at, updated_at
		FROM kyc_documents WHERE status = 'PENDING' ORDER BY created_at ASC LIMIT $1 OFFSET $2`

	rows, err := r.pool.Query(ctx, query, limit, offset)
	if err != nil {
		return nil, fmt.Errorf("failed to list pending kyc: %w", err)
	}
	defer rows.Close()

	var docs []domain.KYCDocument
	for rows.Next() {
		var doc domain.KYCDocument
		if err := rows.Scan(
			&doc.ID, &doc.CustomerID, &doc.DrivingLicenseURL, &doc.AadhaarURL,
			&doc.Status, &doc.RejectReason, &doc.ApprovalDate, &doc.CreatedAt, &doc.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan kyc document: %w", err)
		}
		docs = append(docs, doc)
	}
	return docs, nil
}
