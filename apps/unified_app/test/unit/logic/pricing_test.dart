import 'package:flutter_test/flutter_test.dart';

/// Tests for pricing/booking calculation logic used in BikeDetailScreenEnhanced.
/// Logic extracted from the screen:
///   totalRent = dailyRate * durationDays
///   taxes = totalRent * 0.18
///   deposit = bike.securityDeposit
///   grandTotal = totalRent + taxes + deposit

// Extracted calculation functions matching the app's pricing logic
class BookingCalculator {
  final double dailyRate;
  final double securityDeposit;
  static const double taxRate = 0.18;

  BookingCalculator({required this.dailyRate, required this.securityDeposit});

  int durationDays(DateTime pickup, DateTime returnDate) {
    return returnDate.difference(pickup).inDays;
  }

  double totalRent(int days) => dailyRate * days;

  double taxes(int days) => totalRent(days) * taxRate;

  double grandTotal(int days) => totalRent(days) + taxes(days) + securityDeposit;
}

void main() {
  group('Booking Price Calculations', () {
    late BookingCalculator calculator;

    setUp(() {
      calculator = BookingCalculator(
        dailyRate: 1200.0,
        securityDeposit: 3000.0,
      );
    });

    test('duration days calculates correctly', () {
      final pickup = DateTime(2025, 1, 15);
      final returnDate = DateTime(2025, 1, 18);

      expect(calculator.durationDays(pickup, returnDate), 3);
    });

    test('duration days is 0 for same-day', () {
      final date = DateTime(2025, 1, 15);

      expect(calculator.durationDays(date, date), 0);
    });

    test('total rent = daily rate * days', () {
      expect(calculator.totalRent(3), 3600.0);
    });

    test('total rent for 1 day equals daily rate', () {
      expect(calculator.totalRent(1), 1200.0);
    });

    test('total rent for 0 days is 0', () {
      expect(calculator.totalRent(0), 0.0);
    });

    test('taxes are 18% of total rent', () {
      expect(calculator.taxes(3), closeTo(648.0, 0.01));
    });

    test('taxes for 1 day', () {
      expect(calculator.taxes(1), closeTo(216.0, 0.01));
    });

    test('grand total includes rent + taxes + deposit', () {
      // 3 days: rent=3600, taxes=648, deposit=3000 => 7248
      expect(calculator.grandTotal(3), closeTo(7248.0, 0.01));
    });

    test('grand total for 1 day', () {
      // 1 day: rent=1200, taxes=216, deposit=3000 => 4416
      expect(calculator.grandTotal(1), closeTo(4416.0, 0.01));
    });

    test('calculations with budget bike', () {
      final budgetCalc = BookingCalculator(
        dailyRate: 300.0,
        securityDeposit: 500.0,
      );

      expect(budgetCalc.totalRent(7), 2100.0);
      expect(budgetCalc.taxes(7), closeTo(378.0, 0.01));
      expect(budgetCalc.grandTotal(7), closeTo(2978.0, 0.01));
    });

    test('calculations with premium bike', () {
      final premiumCalc = BookingCalculator(
        dailyRate: 1500.0,
        securityDeposit: 5000.0,
      );

      expect(premiumCalc.totalRent(5), 7500.0);
      expect(premiumCalc.taxes(5), closeTo(1350.0, 0.01));
      expect(premiumCalc.grandTotal(5), closeTo(13850.0, 0.01));
    });
  });

  group('Date Duration Edge Cases', () {
    late BookingCalculator calculator;

    setUp(() {
      calculator = BookingCalculator(dailyRate: 1000.0, securityDeposit: 2000.0);
    });

    test('30-day rental', () {
      final pickup = DateTime(2025, 1, 1);
      final returnDate = DateTime(2025, 1, 31);

      expect(calculator.durationDays(pickup, returnDate), 30);
      expect(calculator.totalRent(30), 30000.0);
    });

    test('cross-month duration', () {
      final pickup = DateTime(2025, 1, 28);
      final returnDate = DateTime(2025, 2, 4);

      expect(calculator.durationDays(pickup, returnDate), 7);
    });

    test('leap year calculation', () {
      final pickup = DateTime(2024, 2, 28);
      final returnDate = DateTime(2024, 3, 1);

      expect(calculator.durationDays(pickup, returnDate), 2); // Feb 29 exists in 2024
    });
  });
}
