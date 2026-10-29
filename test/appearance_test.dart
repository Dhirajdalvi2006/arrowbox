import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/app.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/core/widgets/arrowbox_widgets.dart';
import 'package:locate/features/arrow_designs/arrow_designs.dart';

import 'package:locate/features/arrow_lab/arrow_lab_screen.dart';
import 'package:locate/features/arrowbox/arrowbox_board_widgets.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/arrowbox_screen.dart';
import 'package:locate/features/shell/app_shell.dart';
import 'package:locate/features/shell/floating_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'appearance preferences persist by stable ids and reject unknown values',
    () async {
      SharedPreferences.setMockInitialValues({
        'arrowSkinId': 'tech',
        'boardThemeId': 'aurora',
      });
      final store = await AppStore.load();
      expect(store.arrowSkinId, ArrowSkinId.tech);
      expect(store.boardThemeId, BoardThemeId.aurora);

      await store.setArrowSkin(ArrowSkinId.fantasy);
      await store.setBoardTheme(BoardThemeId.graphite);
      final restored = await AppStore.load();
      expect(restored.arrowSkinId, ArrowSkinId.fantasy);
      expect(restored.boardThemeId, BoardThemeId.graphite);

      SharedPreferences.setMockInitialValues({
        'arrowSkinId': 'missing',
        'boardThemeId': 'missing',
      });
      final defaults = await AppStore.load();
      expect(defaults.arrowSkinId, ArrowSkinId.classic);
      expect(defaults.boardThemeId, BoardThemeId.midnight);
    },
  );

  testWidgets('shell switches between all destinations', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    await tester.pumpWidget(MaterialApp(home: AppShell(store: store)));
    await tester.pump(const Duration(milliseconds: 300));

    final nav = find.byType(FloatingBottomNav);
    for (var index = 0; index < 5; index++) {
      await tester.tap(
        find.descendant(of: nav, matching: find.byType(Icon)).at(index),
      );
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('settings stays usable when Firebase is not initialized', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    final errors = <Object>[];

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(store: store),
      ),
    );
    await tester.pump();

    final thrown = tester.takeException();
    if (thrown != null) errors.add(thrown);

    expect(errors, isEmpty);
    expect(find.text('Settings'), findsOneWidget);
    // Should NOT show auth buttons since Firebase is not available
    expect(find.text('Continue with Google'), findsNothing);
  });

  testWidgets('gameplay route has no floating navigation', (tester) async {
    final store = await AppStore.load();
    await tester.pumpWidget(
      MaterialApp(
        home: ArrowBoxScreen(
          store: store,
          initialState: ArrowBoxState.initial(level: 1),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.byType(FloatingBottomNav), findsNothing);
    expect(find.byType(GradientArrowTile), findsWidgets);
  });

  testWidgets('Arrow Lab exposes every skin and board theme', (tester) async {
    final store = await AppStore.load();
    await tester.pumpWidget(MaterialApp(home: ArrowLabScreen(store: store)));
    await tester.pumpAndSettle();

    for (final skin in ArrowSkinRegistry.all) {
      expect(find.text(skin.name), findsWidgets);
    }
    final list = find.byType(ListView);
    for (var i = 0; i < 4; i++) {
      await tester.drag(list, const Offset(0, -500));
      await tester.pump();
    }
    for (final theme in BoardThemeRegistry.all) {
      expect(find.text(theme.name, skipOffstage: false), findsWidgets);
    }
  });

  testWidgets('WelcomeScreen has correct hero logo and action cards', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    await tester.pumpWidget(MaterialApp(home: WelcomeScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.byType(ArrowBoxHeroArtwork), findsOneWidget);
    // The logo in the top bar still exists
    expect(find.byType(ArrowBoxLogoMark), findsWidgets);

    expect(find.text('Progress'), findsNothing);
    expect(find.text('About'), findsNothing);
    expect(find.text('How to Play'), findsNothing);
  });
}
