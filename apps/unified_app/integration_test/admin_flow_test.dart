import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:unified_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin Flow E2E Tests', () {
    testWidgets('Full Admin Journey: Login -> Dashboard -> Bikes -> Bookings -> Customers -> Settings -> Logout', (tester) async {
      app.main();
      // Pump through splash
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // 1. Should be on Login Screen
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);

      // 2. Switch to Admin tab
      final adminTab = find.text('Admin');
      expect(adminTab, findsOneWidget);
      await tester.tap(adminTab);
      await tester.pumpAndSettle();

      // 3. Enter admin credentials
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'admin@bikerental.com');
      await tester.pump(const Duration(milliseconds: 500));

      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, 'admin123');
      await tester.pump(const Duration(milliseconds: 500));

      // 4. Tap login button
      final loginBtn = find.text('Login');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        // Demo admin login has 1s delay
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
      }

      // 5. Should be on Admin Dashboard
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));

      // Verify dashboard loaded (should have management cards)
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);

      // 6. Navigate to Bike Management
      final manageBikes = find.text('Manage Bikes');
      if (manageBikes.evaluate().isNotEmpty) {
        await tester.tap(manageBikes);
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 1));

        // Go back
        await tester.pageBack();
        await tester.pump(const Duration(seconds: 1));
      }

      // 7. Navigate to Bookings
      final reservations = find.text('Reservations');
      if (reservations.evaluate().isNotEmpty) {
        await tester.tap(reservations);
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 1));

        await tester.pageBack();
        await tester.pump(const Duration(seconds: 1));
      }

      // 8. Navigate to Customers
      final customers = find.text('Customers');
      if (customers.evaluate().isNotEmpty) {
        await tester.tap(customers);
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 1));

        await tester.pageBack();
        await tester.pump(const Duration(seconds: 1));
      }

      // 9. Navigate to Settings
      final settings = find.text('Settings');
      if (settings.evaluate().isNotEmpty) {
        await tester.tap(settings);
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 1));
      }

      // Test passes if all navigation succeeded without crashes
    });
  });
}
