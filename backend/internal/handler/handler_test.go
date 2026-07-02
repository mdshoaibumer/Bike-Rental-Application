package handler

import (
	"bytes"
	"encoding/json"
	"net/http/httptest"
	"testing"
	"time"

	"bike-rental/internal/domain"

	"github.com/gofiber/fiber/v2"
)

// --- Mock Services ---

type mockBikeService struct {
	bikes      map[string]*domain.Bike
	categories []domain.BikeCategory
}

func newMockBikeService() *mockBikeService {
	return &mockBikeService{
		bikes:      make(map[string]*domain.Bike),
		categories: []domain.BikeCategory{{ID: "1", Name: "Sports"}},
	}
}

func (m *mockBikeService) AddBike(bike *domain.Bike) error {
	if bike.RegistrationNumber == "" {
		return domain.ErrValidation
	}
	if bike.RentalPrice <= 0 {
		return domain.ErrValidation
	}
	m.bikes[bike.ID] = bike
	return nil
}
func (m *mockBikeService) EditBike(bike *domain.Bike) error {
	m.bikes[bike.ID] = bike
	return nil
}
func (m *mockBikeService) RemoveBike(id string) error {
	delete(m.bikes, id)
	return nil
}
func (m *mockBikeService) GetBikeDetails(id string) (*domain.Bike, error) {
	if b, ok := m.bikes[id]; ok {
		return b, nil
	}
	return nil, domain.ErrNotFound
}
func (m *mockBikeService) GetBikes(offset, limit int) ([]domain.Bike, error) {
	var result []domain.Bike
	for _, b := range m.bikes {
		result = append(result, *b)
	}
	return result, nil
}
func (m *mockBikeService) SearchBikes(query string, offset, limit int) ([]domain.Bike, error) {
	return []domain.Bike{}, nil
}
func (m *mockBikeService) UpdateBikeAvailability(id, status string) error {
	return nil
}
func (m *mockBikeService) GetCategories() ([]domain.BikeCategory, error) {
	return m.categories, nil
}

type mockBookingService struct {
	bookings map[string]*domain.Booking
}

func newMockBookingService() *mockBookingService {
	return &mockBookingService{bookings: make(map[string]*domain.Booking)}
}

func (m *mockBookingService) CreateBooking(customerID, bikeID string, pickup, returnDate time.Time) (*domain.Booking, error) {
	b := &domain.Booking{
		ID:            "bkg-1",
		BookingNumber: "BKG-12345678",
		CustomerID:    customerID,
		BikeID:        bikeID,
		PickupDate:    pickup,
		ReturnDate:    returnDate,
		FinalAmount:   5000,
		BookingStatus: domain.BookingStatusPending,
	}
	m.bookings[b.ID] = b
	return b, nil
}
func (m *mockBookingService) GetBooking(id string) (*domain.Booking, error) {
	if b, ok := m.bookings[id]; ok {
		return b, nil
	}
	return nil, domain.ErrNotFound
}
func (m *mockBookingService) GetCustomerBookings(cid string, o, l int) ([]domain.Booking, error) {
	return []domain.Booking{}, nil
}
func (m *mockBookingService) GetAdminBookings(o, l int) ([]domain.Booking, error) {
	return []domain.Booking{}, nil
}
func (m *mockBookingService) CancelBooking(id, cid string) error {
	if b, ok := m.bookings[id]; ok {
		if b.CustomerID != cid {
			return domain.ErrUnauthorized
		}
		b.BookingStatus = domain.BookingStatusCancelled
		return nil
	}
	return domain.ErrNotFound
}
func (m *mockBookingService) ApproveBooking(id string) error  { return nil }
func (m *mockBookingService) RejectBooking(id string) error   { return nil }
func (m *mockBookingService) MarkPickedUp(id string) error    { return nil }
func (m *mockBookingService) MarkReturned(id string) error    { return nil }
func (m *mockBookingService) CompleteBooking(id string) error { return nil }

// --- Tests ---

func TestBikeHandler_GetBikes(t *testing.T) {
	app := fiber.New()
	svc := newMockBikeService()
	svc.bikes["bike-1"] = &domain.Bike{
		ID:       "bike-1",
		BikeName: "Honda Activa",
	}
	handler := NewBikeHandler(svc)
	app.Get("/bikes", handler.GetBikes)

	req := httptest.NewRequest("GET", "/bikes", nil)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 200 {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}
}

func TestBikeHandler_GetBikeDetails_NotFound(t *testing.T) {
	app := fiber.New()
	svc := newMockBikeService()
	handler := NewBikeHandler(svc)
	app.Get("/bikes/:id", handler.GetBikeDetails)

	req := httptest.NewRequest("GET", "/bikes/nonexistent", nil)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 404 {
		t.Errorf("expected 404, got %d", resp.StatusCode)
	}
}

func TestBikeHandler_GetCategories(t *testing.T) {
	app := fiber.New()
	svc := newMockBikeService()
	handler := NewBikeHandler(svc)
	app.Get("/categories", handler.GetCategories)

	req := httptest.NewRequest("GET", "/categories", nil)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 200 {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}
}

func TestBikeHandler_SearchBikes_MissingQuery(t *testing.T) {
	app := fiber.New()
	svc := newMockBikeService()
	handler := NewBikeHandler(svc)
	app.Get("/search", handler.SearchBikes)

	req := httptest.NewRequest("GET", "/search", nil)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 400 {
		t.Errorf("expected 400, got %d", resp.StatusCode)
	}
}

func TestBikeHandler_SearchBikes_WithQuery(t *testing.T) {
	app := fiber.New()
	svc := newMockBikeService()
	handler := NewBikeHandler(svc)
	app.Get("/search", handler.SearchBikes)

	req := httptest.NewRequest("GET", "/search?q=honda", nil)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 200 {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}
}

func TestBikeHandler_AddBike_InvalidBody(t *testing.T) {
	app := fiber.New()
	svc := newMockBikeService()
	handler := NewBikeHandler(svc)
	app.Post("/bikes", handler.AddBike)

	req := httptest.NewRequest("POST", "/bikes", bytes.NewReader([]byte("invalid json")))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 400 {
		t.Errorf("expected 400, got %d", resp.StatusCode)
	}
}

func TestBookingHandler_GetAdminBookings(t *testing.T) {
	app := fiber.New()
	svc := newMockBookingService()
	handler := NewBookingHandler(svc)
	app.Get("/bookings", handler.GetAdminBookings)

	req := httptest.NewRequest("GET", "/bookings", nil)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 200 {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}
}

func TestBookingHandler_CreateBooking_Unauthorized(t *testing.T) {
	app := fiber.New()
	svc := newMockBookingService()
	handler := NewBookingHandler(svc)
	app.Post("/bookings", handler.CreateBooking)

	body, _ := json.Marshal(map[string]interface{}{
		"bike_id":     "bike-1",
		"pickup_date": time.Now().Add(24 * time.Hour),
		"return_date": time.Now().Add(72 * time.Hour),
	})
	req := httptest.NewRequest("POST", "/bookings", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	// No JWT middleware = no user_id in locals = 401
	if resp.StatusCode != 401 {
		t.Errorf("expected 401, got %d", resp.StatusCode)
	}
}

func TestBookingHandler_GetBookingDetails_NotFound(t *testing.T) {
	app := fiber.New()
	svc := newMockBookingService()
	handler := NewBookingHandler(svc)
	app.Get("/bookings/:id", handler.GetBookingDetails)

	req := httptest.NewRequest("GET", "/bookings/nonexistent", nil)
	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}
	if resp.StatusCode != 404 {
		t.Errorf("expected 404, got %d", resp.StatusCode)
	}
}

func TestParsePagination(t *testing.T) {
	app := fiber.New()
	var gotOffset, gotLimit int

	app.Get("/test", func(c *fiber.Ctx) error {
		gotOffset, gotLimit = parsePagination(c)
		return c.SendStatus(200)
	})

	tests := []struct {
		name       string
		query      string
		wantOffset int
		wantLimit  int
	}{
		{"defaults", "/test", 0, 20},
		{"custom offset", "/test?offset=10", 10, 20},
		{"custom limit", "/test?limit=50", 0, 50},
		{"both", "/test?offset=5&limit=30", 5, 30},
		{"negative offset", "/test?offset=-1", 0, 20},
		{"zero limit", "/test?limit=0", 0, 20},
		{"over max limit", "/test?limit=200", 0, 20},
		{"invalid values", "/test?offset=abc&limit=xyz", 0, 20},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest("GET", tt.query, nil)
			_, _ = app.Test(req)
			if gotOffset != tt.wantOffset {
				t.Errorf("offset: expected %d, got %d", tt.wantOffset, gotOffset)
			}
			if gotLimit != tt.wantLimit {
				t.Errorf("limit: expected %d, got %d", tt.wantLimit, gotLimit)
			}
		})
	}
}
