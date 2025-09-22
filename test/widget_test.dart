// Basic Flutter widget test for NexPost app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nexpost/main.dart';

void main() {
  testWidgets('NexPost app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: NexPostApp()));

    // Verify that the app title is displayed.
    expect(find.text('NexPost'), findsOneWidget);
  });
}
