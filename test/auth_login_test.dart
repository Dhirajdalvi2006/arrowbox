import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/app.dart';
import 'package:locate/core/app_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('WelcomeScreen header shows login button when not signed in', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();

    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(store: store),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Login button exists in the header
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
  });
}
