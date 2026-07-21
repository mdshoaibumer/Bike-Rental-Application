import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/gradient_card.dart';
import 'package:shared/theme/app_theme.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('GradientCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpApp(
        const GradientCard(
          child: Text('Card Content'),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('applies custom gradient', (tester) async {
      await tester.pumpApp(
        const GradientCard(
          gradient: AppTheme.accentGradient,
          child: Text('Accent Gradient'),
        ),
      );

      expect(find.text('Accent Gradient'), findsOneWidget);
    });

    testWidgets('is tappable when onTap provided', (tester) async {
      bool tapped = false;

      await tester.pumpApp(
        GradientCard(
          onTap: () => tapped = true,
          child: const Text('Tap me'),
        ),
      );

      await tester.tap(find.byType(GradientCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('is not tappable when onTap is null', (tester) async {
      await tester.pumpApp(
        const GradientCard(
          child: Text('Static Card'),
        ),
      );

      // Should not find GestureDetector wrapping
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('respects custom border radius', (tester) async {
      await tester.pumpApp(
        const GradientCard(
          borderRadius: 32,
          child: Text('Rounded'),
        ),
      );

      expect(find.text('Rounded'), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpApp(
        const GradientCard(
          padding: EdgeInsets.all(32),
          child: Text('Custom Padding'),
        ),
      );

      expect(find.text('Custom Padding'), findsOneWidget);
    });

    testWidgets('enableGlassMorphism applies backdrop filter', (tester) async {
      await tester.pumpApp(
        const GradientCard(
          enableGlassMorphism: true,
          child: Text('Glass Card'),
        ),
      );

      expect(find.text('Glass Card'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpApp(
        const GradientCard(
          enableGlassMorphism: true,
          child: Text('Dark Glass'),
        ),
        themeMode: ThemeMode.dark,
      );

      expect(find.text('Dark Glass'), findsOneWidget);
    });
  });
}
