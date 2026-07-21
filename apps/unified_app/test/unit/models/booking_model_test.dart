import 'package:flutter_test/flutter_test.dart';
import 'package:unified_app/features/booking/providers/booking_provider.dart';
import '../../test_helpers/test_data.dart';

void main() {
  group('Booking Model', () {
    test('fromJson creates a Booking with all fields', () {
      final json = TestData.bookingJson();
      final booking = Booking.fromJson(json);

      expect(booking.id, 'booking_1');
      expect(booking.bookingNumber, 'BK-001');
      expect(booking.bikeId, 'bike_1');
      expect(booking.pickupDate, '2025-01-15');
      expect(booking.returnDate, '2025-01-18');
      expect(booking.durationDays, 3);
      expect(booking.price, 3600.0);
      expect(booking.deposit, 3000.0);
      expect(booking.taxes, 648.0);
      expect(booking.finalAmount, 7248.0);
      expect(booking.bookingStatus, 'CONFIRMED');
      expect(booking.paymentStatus, 'PAID');
    });

    test('fromJson handles null values with defaults', () {
      final booking = Booking.fromJson({});

      expect(booking.id, '');
      expect(booking.bookingNumber, '');
      expect(booking.bikeId, '');
      expect(booking.durationDays, 0);
      expect(booking.price, 0.0);
      expect(booking.deposit, 0.0);
      expect(booking.taxes, 0.0);
      expect(booking.finalAmount, 0.0);
      expect(booking.bookingStatus, 'PENDING');
      expect(booking.paymentStatus, 'PENDING');
    });

    test('fromJson handles integer amounts (type coercion)', () {
      final json = TestData.bookingJson();
      json['price'] = 3600; // int
      json['deposit'] = 3000; // int
      final booking = Booking.fromJson(json);

      expect(booking.price, 3600.0);
      expect(booking.deposit, 3000.0);
    });

    test('fromJson handles different booking statuses', () {
      for (final status in ['PENDING', 'CONFIRMED', 'ACTIVE', 'COMPLETED', 'CANCELLED']) {
        final booking = Booking.fromJson(TestData.bookingJson(bookingStatus: status));
        expect(booking.bookingStatus, status);
      }
    });
  });

  group('BookingsState', () {
    test('initial state has empty bookings and not loading', () {
      const state = BookingsState();

      expect(state.bookings, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith preserves unmodified fields', () {
      final state = BookingsState(
        bookings: [Booking.fromJson(TestData.bookingJson())],
        isLoading: false,
      );
      final updated = state.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.bookings.length, 1);
    });

    test('copyWith can clear error by setting null', () {
      const state = BookingsState(error: 'Some error');
      final updated = state.copyWith(error: null);

      expect(updated.error, isNull);
    });
  });
}
