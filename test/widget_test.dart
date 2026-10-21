import 'package:flutter_test/flutter_test.dart';
import 'package:locate/app.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OfflineGamesApp());
    expect(find.text('Offline Games'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
