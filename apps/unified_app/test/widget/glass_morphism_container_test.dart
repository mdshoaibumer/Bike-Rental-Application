import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/glass_morphism_container.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('GlassMorphismContainer', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpApp(
        const GlassMorphismContainer(
          child: Text('Glass Content'),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);
    });

    testWidgets('applies backdrop filter', (tester) async {
      await tester.pumpApp(
        const GlassMorphismContainer(
          blur: 15.0,
          child: Text('Blurred'),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('applies ClipRRect for border radius', (tester) async {
      await tester.pumpApp(
        const GlassMorphismContainer(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          child: Text('Rounded'),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpApp(
        const GlassMorphismContainer(
          padding: EdgeInsets.all(32),
          child: Text('Padded'),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(of: find.text('Padded'), matching: find.byType(Padding)).first,
      );
      expect(padding.padding, const EdgeInsets.all(32));
    });

    testWidgets('applies custom margin', (tester) async {
      await tester.pumpApp(
        const GlassMorphismContainer(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Margined'),
        ),
      );

      expect(find.text('Margined'), findsOneWidget);
    });

    testWidgets('premiumCard factory creates widget', (tester) async {
      await tester.pumpApp(
        GlassMorphismContainer.premiumCard(
          child: const Text('Premium Card'),
        ),
      );

      expect(find.text('Premium Card'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('premium factory creates widget', (tester) async {
      await tester.pumpApp(
        GlassMorphismContainer.premium(
          child: const Text('Premium'),
        ),
      );

      expect(find.text('Premium'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpApp(
        const GlassMorphismContainer(
          child: Text('Dark Mode'),
        ),
        themeMode: ThemeMode.dark,
      );

      expect(find.text('Dark Mode'), findsOneWidget);
    });
  });
}
