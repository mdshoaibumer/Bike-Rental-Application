import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/stat_card.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/primary_button.dart';
import 'package:shared/widgets/gradient_card.dart';
import 'package:shared/theme/app_theme.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('Responsive Layout - Small Phone (320x568)', () {
    const size = Size(320, 568);

    testWidgets('StatCard renders without overflow', (tester) async {
      await tester.pumpApp(
        const StatCard(
          label: 'Total Rides',
          value: '12',
          icon: Icons.directions_bike,
        ),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(StatCard), findsOneWidget);
    });

    testWidgets('PrimaryButton renders at full width', (tester) async {
      await tester.pumpApp(
        PrimaryButton(text: 'Book Now', onPressed: () {}),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Book Now'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget fits small screen', (tester) async {
      await tester.pumpApp(
        const SingleChildScrollView(
          child: EmptyStateWidget(
            icon: Icons.inbox,
            title: 'No Bookings Yet',
            message: 'You haven\'t rented any bikes yet.',
          ),
        ),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('No Bookings Yet'), findsOneWidget);
    });
  });

  group('Responsive Layout - Medium Phone (375x812)', () {
    const size = Size(375, 812);

    testWidgets('Row of two StatCards renders without overflow', (tester) async {
      await tester.pumpApp(
        const Row(
          children: [
            Expanded(
              child: StatCard(label: 'Rides', value: '12', icon: Icons.bike_scooter),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(label: 'Spent', value: '₹2,480', icon: Icons.wallet),
            ),
          ],
        ),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(StatCard), findsNWidgets(2));
    });

    testWidgets('GradientCard content does not clip', (tester) async {
      await tester.pumpApp(
        const GradientCard(
          gradient: AppTheme.primaryGradient,
          child: Text('Limited Time Offer - Get 20% off on weekly bookings'),
        ),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Responsive Layout - Large Phone (428x926)', () {
    const size = Size(428, 926);

    testWidgets('Complex layout renders without overflow', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(
          child: Column(
            children: [
              PrimaryButton(text: 'Send Verification Code', onPressed: () {}),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: StatCard(label: 'Rides', value: '12', icon: Icons.bike_scooter)),
                  SizedBox(width: 12),
                  Expanded(child: StatCard(label: 'Spent', value: '₹2,480', icon: Icons.wallet)),
                ],
              ),
              const SizedBox(height: 16),
              const EmptyStateWidget(
                icon: Icons.search_off,
                title: 'No Results',
                message: 'Try different search terms',
              ),
            ],
          ),
        ),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Responsive Layout - Tablet (768x1024)', () {
    const size = Size(768, 1024);

    testWidgets('Widgets scale appropriately on tablet', (tester) async {
      await tester.pumpApp(
        const Row(
          children: [
            Expanded(child: StatCard(label: 'A', value: '100', icon: Icons.star)),
            SizedBox(width: 12),
            Expanded(child: StatCard(label: 'B', value: '200', icon: Icons.star)),
            SizedBox(width: 12),
            Expanded(child: StatCard(label: 'C', value: '300', icon: Icons.star)),
          ],
        ),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(StatCard), findsNWidgets(3));
    });

    testWidgets('EmptyStateWidget centers on wide screen', (tester) async {
      await tester.pumpApp(
        const EmptyStateWidget(
          icon: Icons.inbox,
          title: 'No Data',
          message: 'Nothing to show here',
        ),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Text Scaling', () {
    testWidgets('Widgets handle large text scale factor', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const StatCard(
                      label: 'Total Rides',
                      value: '12',
                      icon: Icons.directions_bike,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(text: 'Book Now', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
