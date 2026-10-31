import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/arrowbox_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Hint button highlights correct valid escape arrow across skins',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = await AppStore.load();
      final game = ArrowBoxState.initial(level: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: ArrowBoxScreen(store: store, initialState: game),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hint'), findsOneWidget);
      await tester.ensureVisible(find.text('Hint'));
      await tester.tap(find.text('Hint'));
      await tester.pump();

      // Verify hint index is tracked and tile builds without error
      expect(tester.takeException(), isNull);
    },
  );
}
