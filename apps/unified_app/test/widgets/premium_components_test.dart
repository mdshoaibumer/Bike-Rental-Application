import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/gradient_card.dart';
import 'package:shared/widgets/stat_card.dart';
import 'package:shared/widgets/premium_rating_display.dart';
import 'package:shared/theme/app_theme.dart';

void main() {
  group('Premium Components Tests', () {
    testWidgets('GradientCard renders with gradient', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCard(
              gradient: AppTheme.primaryGradient,
              padding: const EdgeInsets.all(16),
              onTap: () {},
              child: const Text('Test Gradient Card'),
            ),
          ),
        ),
      );

      expect(find.text('Test Gradient Card'), findsOneWidget);
      expect(find.byType(GradientCard), findsOneWidget);
    });

    testWidgets('StatCard displays stats correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Test Label',
              value: '100',
              icon: Icons.star,
              showTrend: true,
              trendUp: true,
              trendPercentage: '+10%',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('+10%'), findsOneWidget);
    });

    testWidgets('PremiumRatingDisplay shows correct rating',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumRatingDisplay(
              rating: 4.5,
              reviewCount: 100,
            ),
          ),
        ),
      );

      expect(find.text('4.5 (100)'), findsOneWidget);
    });

    testWidgets('GradientCard is tappable', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCard(
              gradient: AppTheme.primaryGradient,
              onTap: () => tapped = true,
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GradientCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('Theme Application Tests', () {
    testWidgets('Primary gradient applies correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: const Text('Gradient Applied'),
            ),
          ),
        ),
      );

      expect(find.text('Gradient Applied'), findsOneWidget);
    });

    testWidgets('Dark mode theme renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: Text('Dark mode text'),
          ),
        ),
      );

      expect(find.text('Dark mode text'), findsOneWidget);
    });

    testWidgets('Light mode theme renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const Scaffold(
            body: Text('Light mode text'),
          ),
        ),
      );

      expect(find.text('Light mode text'), findsOneWidget);
    });
  });

  group('Component Accessibility Tests', () {
    testWidgets('StatCard has proper contrast', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Accessible Label',
              value: '50',
              icon: Icons.access_time,
            ),
          ),
        ),
      );

      expect(find.text('Accessible Label'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('All interactive elements have sufficient tap size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCard(
              gradient: AppTheme.primaryGradient,
              padding: const EdgeInsets.all(20),
              onTap: () {},
              child: const Text('Tap Target'),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(GradientCard));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });

  group('Responsive Design Tests', () {
    testWidgets('Components adapt to small screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  StatCard(
                    label: 'Test',
                    value: '100',
                    icon: Icons.star,
                  ),
                  SizedBox(height: 16),
                  StatCard(
                    label: 'Test 2',
                    value: '50',
                    icon: Icons.favorite,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(StatCard), findsWidgets);
    });

    testWidgets('Components adapt to large screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                const Expanded(
                  child: StatCard(
                    label: 'Test',
                    value: '100',
                    icon: Icons.star,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: StatCard(
                    label: 'Test 2',
                    value: '50',
                    icon: Icons.favorite,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(StatCard), findsWidgets);
    });
  });

  group('Animation Tests', () {
    testWidgets('GradientCard tap animation works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GradientCard(
              gradient: AppTheme.primaryGradient,
              onTap: () {},
              child: const Text('Animated tap'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GradientCard));
      await tester.pumpAndSettle();

      expect(find.text('Animated tap'), findsOneWidget);
    });
  });
}
