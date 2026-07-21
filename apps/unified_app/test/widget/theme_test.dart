import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/theme/app_theme.dart';

void main() {
  group('AppTheme Color Constants', () {
    test('primaryBlue is defined', () {
      expect(AppTheme.primaryBlue, const Color(0xFF0F62FE));
    });

    test('accentOrange is defined', () {
      expect(AppTheme.accentOrange, const Color(0xFFFF8C42));
    });

    test('successGreen is defined', () {
      expect(AppTheme.successGreen, const Color(0xFF10B981));
    });

    test('warningAmber is defined', () {
      expect(AppTheme.warningAmber, const Color(0xFFF59E0B));
    });

    test('errorRed is defined', () {
      expect(AppTheme.errorRed, const Color(0xFFDC2626));
    });

    test('surfaceLight is defined', () {
      expect(AppTheme.surfaceLight, const Color(0xFFF8FAFC));
    });

    test('surfaceDark is defined', () {
      expect(AppTheme.surfaceDark, const Color(0xFF0F1419));
    });

    test('textPrimary is defined', () {
      expect(AppTheme.textPrimary, const Color(0xFF1F2937));
    });

    test('textSecondary is defined', () {
      expect(AppTheme.textSecondary, const Color(0xFF6B7280));
    });
  });

  group('AppTheme Gradients', () {
    test('primaryGradient is a LinearGradient', () {
      expect(AppTheme.primaryGradient, isA<LinearGradient>());
    });

    test('primaryGradient has at least 2 colors', () {
      expect(AppTheme.primaryGradient.colors.length, greaterThanOrEqualTo(2));
    });
  });

  group('AppTheme Shadows', () {
    test('cardShadow is defined', () {
      expect(AppTheme.cardShadow, isNotEmpty);
    });

    test('elevatedShadow is defined', () {
      expect(AppTheme.elevatedShadow, isNotEmpty);
    });

    test('dialogShadow is defined', () {
      expect(AppTheme.dialogShadow, isNotEmpty);
    });
  });

  group('AppTheme Theme Data', () {
    // Note: These tests access AppTheme.lightTheme/darkTheme which triggers
    // GoogleFonts. In test environments, fonts can't be loaded from network.
    // We verify ThemeData properties through widget tests instead.
    testWidgets('lightTheme creates ThemeData with Material 3', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              expect(theme.useMaterial3, isTrue);
              expect(theme.colorScheme.brightness, Brightness.light);
              expect(theme.scaffoldBackgroundColor, AppTheme.surfaceLight);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('darkTheme creates ThemeData with Material 3', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              expect(theme.useMaterial3, isTrue);
              expect(theme.colorScheme.brightness, Brightness.dark);
              expect(theme.scaffoldBackgroundColor, AppTheme.surfaceDark);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('lightTheme has correct primary color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              expect(Theme.of(context).colorScheme.primary, AppTheme.primaryBlue);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('darkTheme has correct primary color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              expect(Theme.of(context).colorScheme.primary, AppTheme.primaryBlue);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('lightTheme app bar is transparent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              expect(Theme.of(context).appBarTheme.backgroundColor, Colors.transparent);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('lightTheme card has 24px border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              final shape = Theme.of(context).cardTheme.shape as RoundedRectangleBorder;
              expect(shape.borderRadius, BorderRadius.circular(24));
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('lightTheme elevated button has correct background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              final style = Theme.of(context).elevatedButtonTheme.style!;
              final bgColor = style.backgroundColor!.resolve({});
              expect(bgColor, AppTheme.primaryBlue);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('darkTheme card color is cardDark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              expect(Theme.of(context).cardTheme.color, AppTheme.cardDark);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('Theme Rendering in Widgets', () {
    testWidgets('Light theme renders without crashes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: Text('Light mode')),
        ),
      );
      // Just need to pump, not pumpAndSettle (fonts cause async issues)
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Light mode'), findsOneWidget);
    });

    testWidgets('Dark theme renders without crashes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: Text('Dark mode')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dark mode'), findsOneWidget);
    });

    testWidgets('Theme mode switching works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) => Text(
              Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light',
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('dark'), findsOneWidget);
    });
  });
}
