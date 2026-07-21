import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unified_app/main.dart';

void main() {
  testWidgets('App smoke test - renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CustomerApp()),
    );

    // The app should render and show the splash screen initially
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
