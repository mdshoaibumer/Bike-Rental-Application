import 'package:flutter_test/flutter_test.dart';
import 'package:unified_app/core/admin_providers.dart';
import '../../test_helpers/test_data.dart';

void main() {
  group('DashboardStats Model', () {
    test('fromJson creates DashboardStats with all fields', () {
      final json = TestData.dashboardStatsJson();
      final stats = DashboardStats.fromJson(json);

      expect(stats.totalBikes, 24);
      expect(stats.availableBikes, 18);
      expect(stats.activeRentals, 6);
      expect(stats.pendingBookings, 3);
      expect(stats.todayRevenue, 4800.0);
      expect(stats.monthlyRevenue, 125000.0);
    });

    test('fromJson handles missing values with defaults', () {
      final stats = DashboardStats.fromJson({});

      expect(stats.totalBikes, 0);
      expect(stats.availableBikes, 0);
      expect(stats.activeRentals, 0);
      expect(stats.pendingBookings, 0);
      expect(stats.todayRevenue, 0.0);
      expect(stats.monthlyRevenue, 0.0);
    });

    test('fromJson handles integer revenue values', () {
      final json = TestData.dashboardStatsJson();
      json['today_revenue'] = 4800;
      json['monthly_revenue'] = 125000;
      final stats = DashboardStats.fromJson(json);

      expect(stats.todayRevenue, 4800.0);
      expect(stats.monthlyRevenue, 125000.0);
    });
  });

  group('OwnerBike Model', () {
    test('fromJson creates OwnerBike from standard bike JSON', () {
      final json = {
        'id': 'bike_1',
        'bike_name': 'Royal Enfield Classic 350',
        'category': 'Cruiser',
        'rental_price': 1200.0,
        'security_deposit': 3000.0,
        'availability_status': 'Available',
        'registration_number': 'KA-01-HH-1234',
      };
      final bike = OwnerBike.fromJson(json);

      expect(bike.id, 'bike_1');
      expect(bike.name, 'Royal Enfield Classic 350');
      expect(bike.category, 'Cruiser');
      expect(bike.rentalPrice, 1200.0);
      expect(bike.securityDeposit, 3000.0);
      expect(bike.availabilityStatus, 'Available');
      expect(bike.registrationNumber, 'KA-01-HH-1234');
    });

    test('fromJson reads name from alternative key', () {
      final json = {
        'id': 'bike_2',
        'name': 'Alternate Name',
        'rental_price': 800,
        'security_deposit': 2000,
        'availability_status': 'Maintenance',
      };
      final bike = OwnerBike.fromJson(json);

      expect(bike.name, 'Alternate Name');
    });

    test('fromJson handles empty JSON', () {
      final bike = OwnerBike.fromJson({});

      expect(bike.id, '');
      expect(bike.name, '');
      expect(bike.rentalPrice, 0.0);
      expect(bike.securityDeposit, 0.0);
      expect(bike.availabilityStatus, 'Available');
    });
  });

  group('OwnerBooking Model', () {
    test('fromJson creates OwnerBooking with all fields', () {
      final json = TestData.ownerBookingJson();
      final booking = OwnerBooking.fromJson(json);

      expect(booking.id, 'ob_1');
      expect(booking.customerName, 'Rajesh Kumar');
      expect(booking.bikeName, 'Royal Enfield Classic 350');
      expect(booking.status, 'PENDING');
      expect(booking.amount, 4200.0);
    });

    test('fromJson handles missing values', () {
      final booking = OwnerBooking.fromJson({});

      expect(booking.id, '');
      expect(booking.customerName, 'Unknown');
      expect(booking.bikeName, 'Unknown');
      expect(booking.status, 'PENDING');
      expect(booking.amount, 0.0);
    });
  });

  group('OwnerBikesState', () {
    test('initial state is empty and not loading', () {
      const state = OwnerBikesState();

      expect(state.bikes, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith updates specified fields', () {
      const state = OwnerBikesState();
      final updated = state.copyWith(isLoading: true, error: 'test error');

      expect(updated.isLoading, true);
      expect(updated.error, 'test error');
      expect(updated.bikes, isEmpty);
    });
  });

  group('OwnerBookingsState', () {
    test('initial state is empty and not loading', () {
      const state = OwnerBookingsState();

      expect(state.bookings, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith updates specified fields', () {
      const state = OwnerBookingsState();
      final updated = state.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.bookings, isEmpty);
    });
  });
}
