import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/price_breakdown.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('PriceBreakdown Widget', () {
    final testItems = [
      PriceItem(label: 'Rental (3 days)', amount: 3600.0),
      PriceItem(label: 'Taxes (18%)', amount: 648.0),
      PriceItem(label: 'Security Deposit', amount: 3000.0),
    ];

    testWidgets('displays total correctly', (tester) async {
      await tester.pumpApp(
        PriceBreakdown(items: testItems),
      );

      // Total = 3600 + 648 + 3000 = 7248
      expect(find.text('\$7248.00'), findsOneWidget);
    });

    testWidgets('shows item count', (tester) async {
      await tester.pumpApp(
        PriceBreakdown(items: testItems),
      );

      expect(find.text('3 items'), findsOneWidget);
    });

    testWidgets('expands to show individual items on tap', (tester) async {
      await tester.pumpApp(
        PriceBreakdown(items: testItems, expandable: true),
      );

      // Initially collapsed - items not visible
      expect(find.text('Rental (3 days)'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Price Details'));
      await tester.pumpAndSettle();

      // Now items should be visible
      expect(find.text('Rental (3 days)'), findsOneWidget);
      expect(find.text('Taxes (18%)'), findsOneWidget);
      expect(find.text('Security Deposit'), findsOneWidget);
    });

    testWidgets('shows discount when provided', (tester) async {
      await tester.pumpApp(
        PriceBreakdown(
          items: testItems,
          discountCode: 'SAVE20',
          discountAmount: 500.0,
          expandable: true,
        ),
      );

      // Total with discount = 7248 - 500 = 6748
      expect(find.text('\$6748.00'), findsOneWidget);

      // Expand to see discount
      await tester.tap(find.text('Price Details'));
      await tester.pumpAndSettle();

      expect(find.text('SAVE20'), findsOneWidget);
    });

    testWidgets('custom currency symbol is displayed', (tester) async {
      await tester.pumpApp(
        PriceBreakdown(
          items: [PriceItem(label: 'Rental', amount: 1200.0)],
          currencySymbol: '₹',
        ),
      );

      expect(find.text('₹1200.00'), findsOneWidget);
    });

    testWidgets('non-expandable does not respond to tap', (tester) async {
      await tester.pumpApp(
        PriceBreakdown(
          items: testItems,
          expandable: false,
        ),
      );

      await tester.tap(find.text('Price Details'));
      await tester.pumpAndSettle();

      // Items should not appear since expandable is false
      // The expand icon should not be shown
      expect(find.byIcon(Icons.expand_more_rounded), findsNothing);
    });
  });
}
