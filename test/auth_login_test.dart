import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:locate/features/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen displays sign in button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
