import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('ShimmerLoader', () {
    testWidgets('renders with specified dimensions', (tester) async {
      await tester.pumpApp(
        const ShimmerLoader(width: 200, height: 100),
      );

      final containerSize = tester.getSize(find.byType(ShimmerLoader));
      expect(containerSize.width, 200.0);
      expect(containerSize.height, 100.0);
    });

    testWidgets('renders with full width', (tester) async {
      await tester.pumpApp(
        const ShimmerLoader(width: double.infinity, height: 50),
      );

      final loader = find.byType(ShimmerLoader);
      expect(loader, findsOneWidget);
    });

    testWidgets('animates (has AnimationController running)', (tester) async {
      await tester.pumpApp(
        const ShimmerLoader(width: 100, height: 50),
      );

      // Pump a few frames to verify animation doesn't crash
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ShimmerLoader), findsOneWidget);
    });

    testWidgets('multiple shimmer loaders render correctly', (tester) async {
      await tester.pumpApp(
        const Column(
          children: [
            ShimmerLoader(width: 100, height: 50),
            SizedBox(height: 8),
            ShimmerLoader(width: 100, height: 50),
            SizedBox(height: 8),
            ShimmerLoader(width: 100, height: 50),
          ],
        ),
      );

      expect(find.byType(ShimmerLoader), findsNWidgets(3));
    });

    testWidgets('disposes animation controller without error', (tester) async {
      await tester.pumpApp(
        const ShimmerLoader(width: 100, height: 50),
      );

      // Removing the widget should not throw
      await tester.pumpApp(const SizedBox.shrink());
      await tester.pump();
    });
  });
}
