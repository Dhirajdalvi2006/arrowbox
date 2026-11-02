import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/core/theme/app_theme.dart';
import 'package:locate/features/arrow_designs/models/board_theme.dart';
import 'package:locate/features/arrow_lab/arrow_lab_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Scrolls the appearance catalog until [text] is rendered and visible.
Future<void> scrollToText(WidgetTester tester, String text) async {
  final scrollable = find.byType(CustomScrollView).first;
  for (var i = 0; i < 40 && find.text(text).evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Theme card layout renders miniature board andEQUIPPED badge correctly',
    (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.reset());

      SharedPreferences.setMockInitialValues({
        'boardThemeId': 'midnight',
        'completedLevels': List<String>.generate(101, (i) => i.toString()),
      });
      final store = await AppStore.load();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: ArrowLabScreen(store: store)),
        ),
      );
      await tester.pumpAndSettle();

      await scrollToText(tester, 'Midnight');
      await tester.pumpAndSettle();
      expect(find.text('Midnight'), findsOneWidget);
      expect(find.text('EQUIPPED'), findsOneWidget);

      // Tap Deep Ocean to select it
      await scrollToText(tester, 'Deep Ocean');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deep Ocean'));
      await tester.pumpAndSettle();

      expect(store.boardThemeId, BoardThemeId.deepOcean);
      expect(find.text('EQUIPPED'), findsOneWidget);
    },
  );

  testWidgets('Theme card list renders in light theme', (tester) async {
    tester.view.physicalSize = const Size(400 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    SharedPreferences.setMockInitialValues({
      'boardThemeId': 'aurora',
      'completedLevels': List<String>.generate(101, (i) => i.toString()),
    });
    final store = await AppStore.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: ArrowLabScreen(store: store)),
      ),
    );
    await tester.pumpAndSettle();

    await scrollToText(tester, 'BOARD THEME');
    await tester.pumpAndSettle();
    expect(find.text('EQUIPPED'), findsOneWidget);
  });
}
