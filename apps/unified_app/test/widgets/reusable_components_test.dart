import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/primary_button.dart';

void main() {
  group('PrimaryButton Widget Tests', () {
    testWidgets('PrimaryButton renders correctly with text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Tap Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify text is present
      expect(find.text('Tap Me'), findsOneWidget);
    });

    testWidgets('PrimaryButton triggers onPressed callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Tap Me',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      // Verify callback was triggered
      expect(tapped, isTrue);
    });

    testWidgets('PrimaryButton displays loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Tap Me',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify loading indicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
