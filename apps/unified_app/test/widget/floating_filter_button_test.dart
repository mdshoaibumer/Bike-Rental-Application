import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/floating_filter_button.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('FloatingFilterButton', () {
    testWidgets('renders with filter icon', (tester) async {
      await tester.pumpApp(
        FloatingFilterButton(onTap: () {}),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('onTap callback is triggered', (tester) async {
      bool tapped = false;

      await tester.pumpApp(
        FloatingFilterButton(onTap: () => tapped = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('badge is hidden when showBadge is false', (tester) async {
      await tester.pumpApp(
        FloatingFilterButton(onTap: () {}, showBadge: false),
      );
      await tester.pumpAndSettle();

      // Badge count text should not be visible
      expect(find.text('1'), findsNothing);
    });

    testWidgets('badge shows count when showBadge is true', (tester) async {
      await tester.pumpApp(
        FloatingFilterButton(
          onTap: () {},
          showBadge: true,
          badgeCount: 5,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('badge shows 99+ for counts over 99', (tester) async {
      await tester.pumpApp(
        FloatingFilterButton(
          onTap: () {},
          showBadge: true,
          badgeCount: 150,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('badge hidden when count is 0', (tester) async {
      await tester.pumpApp(
        FloatingFilterButton(
          onTap: () {},
          showBadge: true,
          badgeCount: 0,
        ),
      );
      await tester.pumpAndSettle();

      // When badgeCount is 0, badge should not show
      expect(find.text('0'), findsNothing);
    });

    testWidgets('FAB has minimum 48px tap target', (tester) async {
      await tester.pumpApp(
        FloatingFilterButton(onTap: () {}),
      );
      await tester.pumpAndSettle();

      final fabSize = tester.getSize(find.byType(FloatingActionButton));
      expect(fabSize.width, greaterThanOrEqualTo(48));
      expect(fabSize.height, greaterThanOrEqualTo(48));
    });
  });
}
