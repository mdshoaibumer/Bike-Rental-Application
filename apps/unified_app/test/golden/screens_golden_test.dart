import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import 'package:shared/widgets/stat_card.dart';
import 'package:shared/widgets/primary_button.dart';
import 'package:shared/widgets/availability_badge.dart';
import 'package:shared/theme/app_theme.dart';

/// A test-safe theme that avoids GoogleFonts network calls
ThemeData get _testTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryBlue),
);

void main() {
  group('Component Golden Tests', () {
    testGoldens('EmptyState Widget Golden', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone])
        ..addScenario(
          widget: MaterialApp(
            theme: _testTheme,
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.inbox_rounded,
                title: 'No Bookings Yet',
                message: 'Start exploring bikes to make your first booking.',
                onAction: () {},
                actionLabel: 'Browse Bikes',
              ),
            ),
            debugShowCheckedModeBanner: false,
          ),
          name: 'empty_state',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'empty_state_widget');
    });

    testGoldens('StatCard Widget Golden', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone])
        ..addScenario(
          widget: MaterialApp(
            theme: _testTheme,
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16),
                child: StatCard(
                  label: 'Monthly Revenue',
                  value: '₹125K',
                  icon: Icons.trending_up_rounded,
                  subtitle: '₹4,800 today',
                  showTrend: true,
                  trendUp: true,
                  trendPercentage: '+12%',
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
          ),
          name: 'stat_card',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'stat_card_widget');
    });

    testGoldens('PrimaryButton Widget Golden', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone])
        ..addScenario(
          widget: MaterialApp(
            theme: _testTheme,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PrimaryButton(text: 'Book Now', onPressed: () {}),
                    const SizedBox(height: 16),
                    PrimaryButton(text: 'View Details', isOutlined: true, onPressed: () {}),
                  ],
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
          ),
          name: 'buttons',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'primary_button_variants');
    });

    testGoldens('AvailabilityBadge all states Golden', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone])
        ..addScenario(
          widget: MaterialApp(
            theme: _testTheme,
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvailabilityBadge(label: 'Available', status: AvailabilityStatus.available),
                    SizedBox(height: 12),
                    AvailabilityBadge(label: 'Booked', status: AvailabilityStatus.booked),
                    SizedBox(height: 12),
                    AvailabilityBadge(label: 'Maintenance', status: AvailabilityStatus.maintenance),
                  ],
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
          ),
          name: 'badges',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'availability_badges');
    });
  });
}
