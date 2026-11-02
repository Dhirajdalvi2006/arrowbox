import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/app.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/core/widgets/arrowbox_widgets.dart';
import 'package:locate/features/arrow_designs/arrow_designs.dart';
import 'package:locate/features/arrow_lab/arrow_lab_screen.dart';
import 'package:locate/features/arrowbox/arrowbox_board_widgets.dart';
import 'package:locate/features/arrowbox/arrowbox_screen.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/shell/app_shell.dart';
import 'package:locate/features/shell/floating_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Scrolls the appearance catalog until [text] is rendered and visible.
///
/// Sliver grids build their items lazily, so off-screen skins/themes must be
/// scrolled into view before they can be located or tapped.
Future<void> scrollToText(WidgetTester tester, String text) async {
  final scrollable = find.byType(CustomScrollView).first;
  for (var i = 0; i < 40 && find.text(text).evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  await tester.pumpAndSettle();
}

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

    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
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

    final tile = tester.widget<GradientArrowTile>(
      find.byType(GradientArrowTile).first,
    );
    expect(tile.skin.id, store.arrowSkinId);
    expect(tile.direction, ArrowBoxState.initial(level: 1).board[tile.index]);

    await store.setArrowSkin(ArrowSkinId.neon);
    await store.setBoardTheme(BoardThemeId.graphite);
    await tester.pump();
    final updated = tester.widget<GradientArrowTile>(
      find.byType(GradientArrowTile).first,
    );
    expect(updated.skin.id, ArrowSkinId.neon);
    expect(updated.direction, tile.direction);
  });

  testWidgets('Arrow Lab exposes every skin and board theme', (tester) async {
    addTearDown(() => tester.view.reset());

    // Set up completed levels so all skins and themes are unlocked.
    SharedPreferences.setMockInitialValues({
      'completedLevels': List<String>.generate(501, (i) => i.toString()),
    });
    final store = await AppStore.load();
    await tester.pumpWidget(MaterialApp(home: ArrowLabScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.byType(ArrowSkinPreviewBoard), findsOneWidget);
    expect(find.byType(EmptyBoardCell), findsWidgets);

    expect(find.text('Arrow Appearance'), findsOneWidget);
    expect(find.text('ARROW STYLE'), findsOneWidget);

    // Equip Neon skin near the top of the catalog.
    await scrollToText(tester, 'Neon');
    await tester.tap(find.text('Neon'));
    await tester.pump();
    expect(store.arrowSkinId, ArrowSkinId.neon);

    // Scroll to the BOARD THEME section to confirm every item builds.
    await scrollToText(tester, 'BOARD THEME');
    await tester.pumpAndSettle();
    expect(find.text('BOARD THEME'), findsOneWidget);

    expect(find.text('Create. Experiment. Master.'), findsNothing);
    expect(find.text('Lab Tools'), findsNothing);
    expect(find.text('Featured Experiments'), findsNothing);
    expect(find.text('Reset Preview'), findsNothing);
    expect(find.text('Save Config'), findsNothing);

    // Equip Graphite theme further down in the theme catalog.
    await scrollToText(tester, 'Graphite');
    await tester.tap(find.text('Graphite'));
    await tester.pump();
    expect(store.boardThemeId, BoardThemeId.graphite);
  });

  testWidgets('WelcomeScreen has correct hero logo and action cards', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    await tester.pumpWidget(MaterialApp(home: WelcomeScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.byType(ArrowBoxHeroArtwork), findsOneWidget);
    // The logo in the top bar still exists
    expect(find.byType(ArrowBoxLogoMark), findsWidgets);

    expect(find.text('Progress'), findsNothing);
    expect(find.text('About'), findsNothing);
    expect(find.text('How to Play'), findsOneWidget);
  });

  testWidgets('Minimal and Tech skins build with correct dimensions', (
    tester,
  ) async {
    for (final skinId in [ArrowSkinId.minimal, ArrowSkinId.tech]) {
      final skin = ArrowSkinRegistry.byId(skinId);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: skin.buildArrow(direction: ArrowDirection.up, size: 60),
            ),
          ),
        ),
      );

      final paintFinder = find.descendant(
        of: find.byType(SizedBox),
        matching: find.byType(CustomPaint),
      );
      expect(paintFinder, findsOneWidget);
      final paintSize = tester.getSize(paintFinder);
      expect(paintSize, const Size(60, 60));
    }
  });
}
