import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('renders icon, title, and message', (tester) async {
      await tester.pumpApp(
        const EmptyStateWidget(
          icon: Icons.search_off,
          title: 'No Results',
          message: 'Try a different search term',
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('No Results'), findsOneWidget);
      expect(find.text('Try a different search term'), findsOneWidget);
    });

    testWidgets('does not show action button when no callback', (tester) async {
      await tester.pumpApp(
        const EmptyStateWidget(
          icon: Icons.inbox,
          title: 'Empty',
          message: 'Nothing here',
        ),
      );

      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('shows action button when callback and label provided', (tester) async {
      await tester.pumpApp(
        EmptyStateWidget(
          icon: Icons.refresh,
          title: 'Error',
          message: 'Something went wrong',
          onAction: () {},
          actionLabel: 'Retry',
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('action button triggers callback', (tester) async {
      bool tapped = false;

      await tester.pumpApp(
        EmptyStateWidget(
          icon: Icons.refresh,
          title: 'Error',
          message: 'Failed',
          onAction: () => tapped = true,
          actionLabel: 'Retry',
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('has minimum tap target size for accessibility', (tester) async {
      await tester.pumpApp(
        EmptyStateWidget(
          icon: Icons.inbox,
          title: 'Test',
          message: 'Test message',
          onAction: () {},
          actionLabel: 'Action',
        ),
      );

      final buttonSize = tester.getSize(find.byType(OutlinedButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48));
      expect(buttonSize.width, greaterThanOrEqualTo(48));
    });
  });
}
