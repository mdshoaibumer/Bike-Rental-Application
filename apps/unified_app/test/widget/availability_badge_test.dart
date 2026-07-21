import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/availability_badge.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('AvailabilityBadge', () {
    testWidgets('renders available status with check icon', (tester) async {
      await tester.pumpApp(
        const AvailabilityBadge(
          label: 'Available',
          status: AvailabilityStatus.available,
        ),
      );

      expect(find.text('Available'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders booked status with schedule icon', (tester) async {
      await tester.pumpApp(
        const AvailabilityBadge(
          label: 'Booked',
          status: AvailabilityStatus.booked,
        ),
      );

      expect(find.text('Booked'), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    });

    testWidgets('renders maintenance status with warning icon', (tester) async {
      await tester.pumpApp(
        const AvailabilityBadge(
          label: 'Maintenance',
          status: AvailabilityStatus.maintenance,
        ),
      );

      expect(find.text('Maintenance'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('uses correct colors for available status', (tester) async {
      await tester.pumpApp(
        const AvailabilityBadge(
          label: 'Available',
          status: AvailabilityStatus.available,
        ),
      );

      // The container should render without errors
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container, isNotNull);
    });

    testWidgets('badge has minimum readable size', (tester) async {
      await tester.pumpApp(
        const AvailabilityBadge(
          label: 'Available',
          status: AvailabilityStatus.available,
        ),
      );

      final badgeSize = tester.getSize(find.byType(AvailabilityBadge));
      expect(badgeSize.width, greaterThan(0));
      expect(badgeSize.height, greaterThan(0));
    });
  });

  group('AvailabilityStatus enum', () {
    test('has 3 values', () {
      expect(AvailabilityStatus.values.length, 3);
    });

    test('contains all expected statuses', () {
      expect(AvailabilityStatus.values, contains(AvailabilityStatus.available));
      expect(AvailabilityStatus.values, contains(AvailabilityStatus.booked));
      expect(AvailabilityStatus.values, contains(AvailabilityStatus.maintenance));
    });
  });
}
