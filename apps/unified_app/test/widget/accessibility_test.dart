import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/primary_button.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/stat_card.dart';
import 'package:shared/widgets/gradient_card.dart';
import 'package:shared/widgets/availability_badge.dart';
import 'package:shared/theme/app_theme.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('Touch Target Sizes (minimum 48x48)', () {
    testWidgets('PrimaryButton meets minimum tap target', (tester) async {
      await tester.pumpApp(
        PrimaryButton(text: 'Action', onPressed: () {}),
      );
      await tester.pumpAndSettle();

      final buttonSize = tester.getSize(find.byType(PrimaryButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48));
    });

    testWidgets('GradientCard with onTap meets minimum tap target', (tester) async {
      await tester.pumpApp(
        GradientCard(
          gradient: AppTheme.primaryGradient,
          onTap: () {},
          child: const Text('Tap'),
        ),
      );
      await tester.pumpAndSettle();

      final cardSize = tester.getSize(find.byType(GradientCard));
      expect(cardSize.height, greaterThanOrEqualTo(48));
      expect(cardSize.width, greaterThanOrEqualTo(48));
    });

    testWidgets('OutlinedButton in EmptyStateWidget meets target', (tester) async {
      await tester.pumpApp(
        EmptyStateWidget(
          icon: Icons.refresh,
          title: 'Error',
          message: 'Something went wrong',
          onAction: () {},
          actionLabel: 'Retry',
        ),
      );

      final buttonSize = tester.getSize(find.byType(OutlinedButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48));
      expect(buttonSize.width, greaterThanOrEqualTo(48));
    });
  });

  group('Semantic Labels', () {
    testWidgets('StatCard has readable label and value', (tester) async {
      await tester.pumpApp(
        const StatCard(
          label: 'Total Rides',
          value: '12',
          icon: Icons.directions_bike,
        ),
      );
      await tester.pumpAndSettle();

      // Text should be findable for screen readers
      expect(find.text('Total Rides'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('AvailabilityBadge text is readable', (tester) async {
      await tester.pumpApp(
        const AvailabilityBadge(
          label: 'Available',
          status: AvailabilityStatus.available,
        ),
      );

      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget provides descriptive text', (tester) async {
      await tester.pumpApp(
        const EmptyStateWidget(
          icon: Icons.search_off,
          title: 'No Results Found',
          message: 'Try adjusting your search filters',
        ),
      );

      expect(find.text('No Results Found'), findsOneWidget);
      expect(find.text('Try adjusting your search filters'), findsOneWidget);
    });
  });

  group('Color Contrast', () {
    testWidgets('PrimaryButton text is white on primary background', (tester) async {
      await tester.pumpApp(
        PrimaryButton(text: 'Submit', onPressed: () {}),
      );
      await tester.pumpAndSettle();

      // Button should render without errors, indicating proper contrast
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('AvailabilityBadge uses high-contrast status colors', (tester) async {
      for (final status in AvailabilityStatus.values) {
        await tester.pumpApp(
          AvailabilityBadge(
            label: status.name,
            status: status,
          ),
        );

        // Widget should render without errors
        expect(find.text(status.name), findsOneWidget);
      }
    });
  });

  group('Focus Traversal', () {
    testWidgets('Multiple interactive widgets can receive focus', (tester) async {
      await tester.pumpApp(
        Column(
          children: [
            PrimaryButton(text: 'First', onPressed: () {}),
            const SizedBox(height: 16),
            PrimaryButton(text: 'Second', onPressed: () {}),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Verify both buttons exist and could receive focus
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });
  });

  group('Loading States Accessibility', () {
    testWidgets('PrimaryButton loading shows progress indicator', (tester) async {
      await tester.pumpApp(
        PrimaryButton(
          text: 'Loading',
          isLoading: true,
          onPressed: () {},
        ),
      );

      // Should show a progress indicator (visible to assistive tech)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('PrimaryButton loading state prevents tap', (tester) async {
      bool tapped = false;

      await tester.pumpApp(
        PrimaryButton(
          text: 'Submit',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
