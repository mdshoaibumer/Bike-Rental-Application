/// Centralized test data for consistent testing across the suite.
class TestData {
  // Valid test credentials (demo mode)
  static const validPhone = '9876543210';
  static const validOtp = '123456';
  static const adminEmail = 'admin@bikerental.com';
  static const adminPassword = 'admin123';

  // Invalid credentials
  static const invalidPhone = '123';
  static const invalidOtp = '000';
  static const emptyString = '';

  // Sample bike JSON
  static Map<String, dynamic> bikeJson({
    String id = 'bike_1',
    String bikeName = 'Royal Enfield Classic 350',
    String brand = 'Royal Enfield',
    String model = 'Classic 350',
    String category = 'Cruiser',
    double rentalPrice = 1200.0,
    double securityDeposit = 3000.0,
    String availabilityStatus = 'Available',
    int engineCC = 349,
  }) {
    return {
      'id': id,
      'bike_name': bikeName,
      'brand': brand,
      'model': model,
      'category': category,
      'rental_price': rentalPrice,
      'security_deposit': securityDeposit,
      'availability_status': availabilityStatus,
      'description': 'Test bike description',
      'color': 'Black',
      'engine_cc': engineCC,
      'fuel_type': 'Petrol',
      'transmission': 'Manual',
      'image_url': null,
      'registration_number': 'KA-01-HH-1234',
    };
  }

  // Sample booking JSON
  static Map<String, dynamic> bookingJson({
    String id = 'booking_1',
    String bookingNumber = 'BK-001',
    String bikeId = 'bike_1',
    String pickupDate = '2025-01-15',
    String returnDate = '2025-01-18',
    int durationDays = 3,
    double price = 3600.0,
    double deposit = 3000.0,
    double taxes = 648.0,
    double finalAmount = 7248.0,
    String bookingStatus = 'CONFIRMED',
    String paymentStatus = 'PAID',
  }) {
    return {
      'id': id,
      'booking_number': bookingNumber,
      'bike_id': bikeId,
      'pickup_date': pickupDate,
      'return_date': returnDate,
      'duration_days': durationDays,
      'price': price,
      'deposit': deposit,
      'taxes': taxes,
      'final_amount': finalAmount,
      'booking_status': bookingStatus,
      'payment_status': paymentStatus,
    };
  }

  // Sample owner booking JSON
  static Map<String, dynamic> ownerBookingJson({
    String id = 'ob_1',
    String customerName = 'Rajesh Kumar',
    String bikeName = 'Royal Enfield Classic 350',
    String status = 'PENDING',
    String pickupDate = '2025-01-15T00:00:00Z',
    String returnDate = '2025-01-18T00:00:00Z',
    double amount = 4200.0,
  }) {
    return {
      'id': id,
      'customer_name': customerName,
      'bike_name': bikeName,
      'booking_status': status,
      'pickup_date': pickupDate,
      'return_date': returnDate,
      'final_amount': amount,
    };
  }

  // Sample dashboard stats JSON
  static Map<String, dynamic> dashboardStatsJson({
    int totalBikes = 24,
    int availableBikes = 18,
    int activeRentals = 6,
    int pendingBookings = 3,
    double todayRevenue = 4800.0,
    double monthlyRevenue = 125000.0,
  }) {
    return {
      'total_bikes': totalBikes,
      'available_bikes': availableBikes,
      'active_rentals': activeRentals,
      'pending_bookings': pendingBookings,
      'today_revenue': todayRevenue,
      'monthly_revenue': monthlyRevenue,
    };
  }

  // Generate a list of bike JSONs
  static List<Map<String, dynamic>> bikeListJson(int count) {
    return List.generate(count, (i) => bikeJson(
      id: 'bike_${i + 1}',
      bikeName: 'Test Bike ${i + 1}',
      rentalPrice: 500.0 + (i * 100),
    ));
  }

  // Generate a list of booking JSONs
  static List<Map<String, dynamic>> bookingListJson(int count) {
    return List.generate(count, (i) => bookingJson(
      id: 'booking_${i + 1}',
      bookingNumber: 'BK-${(i + 1).toString().padLeft(3, '0')}',
      finalAmount: 2000.0 + (i * 500),
    ));
  }
}
