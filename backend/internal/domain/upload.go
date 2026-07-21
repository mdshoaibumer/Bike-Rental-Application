package domain

import "io"

type UploadProvider interface {
	UploadFile(filename string, file io.Reader) (string, error)
	DeleteFile(fileURL string) error
}

type UploadService interface {
	UploadImage(filename string, file io.Reader) (string, error)
}
