import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noorway/main.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launch test for white screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Catch framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('FLUTTER ERROR CAUGHT: \${details.exception}');
    };

    try {
      await tester.pumpWidget(const NoorWayApp(showOnboarding: true));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      debugPrint('App pumped successfully.');
    } catch (e, stack) {
      debugPrint('EXCEPTION DURING PUMP: $e');
      debugPrint(stack.toString());
    }
  });
}
