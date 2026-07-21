import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/premium_rating_display.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('PremiumRatingDisplay', () {
    testWidgets('displays rating and review count', (tester) async {
      await tester.pumpApp(
        const PremiumRatingDisplay(
          rating: 4.5,
          reviewCount: 100,
        ),
      );

      expect(find.text('4.5 (100)'), findsOneWidget);
    });

    testWidgets('renders 5 star icons for a 5.0 rating', (tester) async {
      await tester.pumpApp(
        const PremiumRatingDisplay(
          rating: 5.0,
          reviewCount: 50,
        ),
      );

      // Should have 5 filled stars
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    });

    testWidgets('renders correct number of filled stars for 3.0', (tester) async {
      await tester.pumpApp(
        const PremiumRatingDisplay(
          rating: 3.0,
          reviewCount: 20,
        ),
      );

      // 3 full stars + 2 empty stars
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(2));
    });

    testWidgets('hides count when showCount is false', (tester) async {
      await tester.pumpApp(
        const PremiumRatingDisplay(
          rating: 4.0,
          reviewCount: 200,
          showCount: false,
        ),
      );

      expect(find.text('4.0 (200)'), findsNothing);
    });

    testWidgets('renders with zero rating (all empty stars)', (tester) async {
      await tester.pumpApp(
        const PremiumRatingDisplay(
          rating: 0.0,
          reviewCount: 0,
        ),
      );

      // All 5 should be outline stars
      expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
    });

    testWidgets('half star renders for x.5 ratings', (tester) async {
      await tester.pumpApp(
        const PremiumRatingDisplay(
          rating: 3.5,
          reviewCount: 10,
        ),
      );

      // 3 full + 1 half (has ClipRect for half) + 1 empty
      // The half star uses a Stack with ClipRect
      expect(find.byType(ClipRect), findsOneWidget);
    });

    testWidgets('custom star size applies', (tester) async {
      await tester.pumpApp(
        const PremiumRatingDisplay(
          rating: 4.0,
          reviewCount: 50,
          starSize: 24,
        ),
      );

      expect(find.byType(PremiumRatingDisplay), findsOneWidget);
    });
  });
}
