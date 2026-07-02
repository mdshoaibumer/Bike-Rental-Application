package application

import (
	"io"
	"bike-rental/internal/domain"
	"github.com/google/uuid"
)

type uploadService struct {
	provider domain.UploadProvider
}

func NewUploadService(provider domain.UploadProvider) domain.UploadService {
	return &uploadService{provider: provider}
}

func (s *uploadService) UploadImage(filename string, file io.Reader) (string, error) {
	if s.provider != nil {
		return s.provider.UploadFile(filename, file)
	}
	// Mock successful upload
	return "https://storage.mock.com/" + uuid.New().String() + "_" + filename, nil
}
