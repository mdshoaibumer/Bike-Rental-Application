import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/widgets/premium_search_field.dart';
import '../test_helpers/pump_app.dart';

void main() {
  group('PremiumSearchField', () {
    testWidgets('renders with hint text', (tester) async {
      await tester.pumpApp(
        const PremiumSearchField(hintText: 'Search bikes...'),
      );

      expect(find.text('Search bikes...'), findsOneWidget);
    });

    testWidgets('typing triggers onChanged callback', (tester) async {
      String? changedValue;

      await tester.pumpApp(
        PremiumSearchField(
          onChanged: (value) => changedValue = value,
        ),
      );

      await tester.enterText(find.byType(TextField), 'Honda');
      await tester.pump();

      expect(changedValue, 'Honda');
    });

    testWidgets('clear button appears when text is entered', (tester) async {
      final controller = TextEditingController();

      await tester.pumpApp(
        PremiumSearchField(controller: controller),
      );

      // Initially no clear button
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      // Type something
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Clear button should appear
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('clear button clears text and calls onClear', (tester) async {
      bool clearCalled = false;
      final controller = TextEditingController(text: 'initial');

      await tester.pumpApp(
        PremiumSearchField(
          controller: controller,
          onClear: () => clearCalled = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(controller.text, '');
      expect(clearCalled, isTrue);
    });

    testWidgets('shows voice search icon when enabled', (tester) async {
      await tester.pumpApp(
        const PremiumSearchField(enableVoiceSearch: true),
      );

      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    });

    testWidgets('hides voice search icon when disabled', (tester) async {
      await tester.pumpApp(
        const PremiumSearchField(enableVoiceSearch: false),
      );

      expect(find.byIcon(Icons.mic_rounded), findsNothing);
    });

    testWidgets('shows filter icon when enabled', (tester) async {
      await tester.pumpApp(
        const PremiumSearchField(enableFilter: true),
      );

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });

    testWidgets('filter tap triggers callback', (tester) async {
      bool filterTapped = false;

      await tester.pumpApp(
        PremiumSearchField(
          enableFilter: true,
          onFilterTap: () => filterTapped = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pump();

      expect(filterTapped, isTrue);
    });

    testWidgets('search icon is always visible', (tester) async {
      await tester.pumpApp(
        const PremiumSearchField(),
      );

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('onSubmitted triggers on keyboard submit', (tester) async {
      String? submittedValue;

      await tester.pumpApp(
        PremiumSearchField(
          onSubmitted: (value) => submittedValue = value,
        ),
      );

      await tester.enterText(find.byType(TextField), 'KTM');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, 'KTM');
    });
  });
}
