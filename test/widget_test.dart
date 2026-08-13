import 'package:flutter_test/flutter_test.dart';

import 'package:uk_food_scanner/main.dart';

void main() {
  testWidgets('UK Food Scanner app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const UKFoodScannerApp());

    // Wait for asynchronous mock service call to complete
    await tester.pumpAndSettle();

    // Verify that app title / home elements are present.
    expect(find.text('UK Food Scanner'), findsOneWidget);
    expect(find.text('Scan Product'), findsOneWidget);
    expect(find.text('Recent Scans'), findsOneWidget);
  });
}
