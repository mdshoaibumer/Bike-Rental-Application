import 'package:flutter_test/flutter_test.dart';

/// Tests for the date formatting logic used in BookingManagementScreen.
/// The function _formatBookingDate parses ISO strings and returns 'dd Mon' format.

// Extracted from booking_management_screen.dart
String formatBookingDate(String isoDate) {
  try {
    final date = DateTime.parse(isoDate);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  } catch (_) {
    return isoDate.length > 10 ? isoDate.substring(0, 10) : isoDate;
  }
}

void main() {
  group('Date Formatting', () {
    test('formats ISO date correctly', () {
      expect(formatBookingDate('2025-01-15T00:00:00Z'), '15 Jan');
    });

    test('formats date-only string', () {
      expect(formatBookingDate('2025-03-28'), '28 Mar');
    });

    test('formats December date', () {
      expect(formatBookingDate('2025-12-25'), '25 Dec');
    });

    test('formats February date', () {
      expect(formatBookingDate('2025-02-14'), '14 Feb');
    });

    test('handles single-digit day', () {
      expect(formatBookingDate('2025-06-01'), '1 Jun');
    });

    test('handles invalid date string gracefully', () {
      expect(formatBookingDate('not-a-date'), 'not-a-date');
    });

    test('handles long invalid string (truncates to 10)', () {
      expect(formatBookingDate('this is a very long invalid string'), 'this is a ');
    });

    test('handles empty string', () {
      expect(formatBookingDate(''), '');
    });

    test('formats date with timezone offset', () {
      expect(formatBookingDate('2025-07-04T10:30:00+05:30'), '4 Jul');
    });
  });
}
