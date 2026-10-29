import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locate/app.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/startup.dart';
import 'package:locate/core/theme/app_theme.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/arrowbox_screen.dart';
import 'package:locate/features/arrowbox/arrowbox_board_widgets.dart';
import 'package:locate/core/widgets/arrowbox_widgets.dart';
import 'package:locate/features/arrowbox/arrowbox_dialogs.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'unlockedLevel': 3,
      'completedLevels': ['1', '2'],
      'gamesPlayed': 5,
      'totalMistakes': 8,
    });
  });

  testWidgets('Startup shows splash while store initialization is pending', (
    tester,
  ) async {
    final pending = Completer<AppStore>();

    await tester.pumpWidget(ArrowBoxStartup(
      storeLoader: () => pending.future,
      firebaseInitializer: () async {},
    ));
    await tester.pump();

    expect(find.text('Preparing your puzzle...'), findsOneWidget);
    expect(find.text('Play Now'), findsNothing);
  });

  testWidgets('Startup shows landing after one successful store load', (
    tester,
  ) async {
    var loadCount = 0;
    final store = await AppStore.load();

    await tester.pumpWidget(
      ArrowBoxStartup(
        storeLoader: () async {
          loadCount++;
          return store;
        },
        firebaseInitializer: () async {},
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Play Now'), findsOneWidget);
    expect(loadCount, 1);
  });

  testWidgets('Startup converts synchronous loader errors into retry UI', (
    tester,
  ) async {
    await tester.pumpWidget(
      ArrowBoxStartup(
        storeLoader: () {
          throw StateError('sync load failed');
        },
        firebaseInitializer: () async {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ArrowBox could not start'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Startup failure can retry without duplicate pending loads', (
    tester,
  ) async {
    final first = Completer<AppStore>();
    final second = Completer<AppStore>();
    var loadCount = 0;
    final store = await AppStore.load();

    await tester.pumpWidget(
      ArrowBoxStartup(
        storeLoader: () {
          loadCount++;
          return loadCount == 1 ? first.future : second.future;
        },
        firebaseInitializer: () async {},
      ),
    );
    await tester.pump();
    first.completeError(StateError('load failed'));
    await tester.pumpAndSettle();

    expect(find.text('ArrowBox could not start'), findsOneWidget);
    expect(loadCount, 1);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('Play Now'), findsNothing);
    expect(loadCount, 2);

    second.complete(store);
    await tester.pumpAndSettle();
    expect(find.text('Play Now'), findsOneWidget);
  });

  testWidgets('Landing screen uses the cube logo instead of hero artwork', (
    tester,
  ) async {
    final store = await AppStore.load();
    await tester.pumpWidget(ArrowBoxApp(store: store));
    await tester.pumpAndSettle();

    expect(find.byType(ArrowBoxHeroArtwork), findsNothing);

    final logo = tester.widget<Image>(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName ==
                    'assets/images/arrowbox_cube_logo.png',
          )
          .first,
    );
    expect(logo.fit, BoxFit.contain);
  });

  testWidgets('Landing screen renders title, tagline and action buttons', (
    tester,
  ) async {
    final store = await AppStore.load();
    await tester.pumpWidget(ArrowBoxApp(store: store));
    await tester.pumpAndSettle();

    expect(find.byType(ArrowBoxTitle), findsWidgets);
    expect(find.text('Think. Aim. Escape.'), findsOneWidget);
    expect(find.text('Play Now'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('Landing screen fits a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(640, 1200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final store = await AppStore.load();
    await tester.pumpWidget(ArrowBoxApp(store: store));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Play Now navigates to level selection', (tester) async {
    final store = await AppStore.load();
    await tester.pumpWidget(ArrowBoxApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play Now'));
    await tester.pumpAndSettle();

    expect(find.text('Select Level'), findsOneWidget);
  });

  testWidgets('Continue Level appears and opens the saved level', (
    tester,
  ) async {
    final store = await AppStore.load();
    await store.saveGame(ArrowBoxState.initial(level: 7).withSeconds(4));

    await tester.pumpWidget(ArrowBoxApp(store: store));
    await tester.pumpAndSettle();

    final continueButton = find.text('Continue Level 7');
    expect(continueButton, findsOneWidget);
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Level 7'), findsOneWidget);
  });

  testWidgets('Level Selection screen displays the expanded catalog', (
    tester,
  ) async {
    final store = await AppStore.load();
    await tester.pumpWidget(
      MaterialApp(home: LevelSelectionScreen(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Select Level'), findsOneWidget);
    expect(find.text('2 / ${AppStore.totalLevels}'), findsOneWidget);
    expect(find.text('Levels Completed'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Level difficulty filter can return to all levels', (
    tester,
  ) async {
    final store = await AppStore.load();
    await tester.pumpWidget(
      MaterialApp(home: LevelSelectionScreen(store: store)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Filter difficulty'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ultra Hard'));
    await tester.pumpAndSettle();
    expect(find.text('Ultra'), findsWidgets);
    expect(find.text('Medium'), findsNothing);

    await tester.tap(find.byTooltip('Filter difficulty'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All levels'));
    await tester.pumpAndSettle();
    expect(find.text('Easy'), findsWidgets);
  });

  test('Escape offset scales with board geometry and direction', () {
    expect(arrowEscapeOffset(ArrowDirection.right, 48), const Offset(48, 0));
    expect(arrowEscapeOffset(ArrowDirection.up, 72), const Offset(0, -72));
  });

  testWidgets('Gameplay screen renders Level 3 with hint and controls', (
    tester,
  ) async {
    final store = await AppStore.load();
    final game = ArrowBoxState.initial(level: 3);

    await tester.pumpWidget(
      MaterialApp(
        home: ArrowBoxScreen(store: store, initialState: game),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('EASY'), findsOneWidget);
    expect(find.text('0 mistakes'), findsOneWidget);
    expect(find.text('Hint'), findsWidgets);
    expect(find.textContaining('arrow can escape'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('Gameplay screen fits a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(640, 1200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final store = await AppStore.load();
    await tester.pumpWidget(
      MaterialApp(
        home: ArrowBoxScreen(
          store: store,
          initialState: ArrowBoxState.initial(level: 3),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('Undo restores an escaping tile for immediate input', (
    tester,
  ) async {
    final store = await AppStore.load();
    final initialState = ArrowBoxState.initial(level: 1);
    final escapeIndex = initialState.nextEscapeIndex!;

    await tester.pumpWidget(
      MaterialApp(
        home: ArrowBoxScreen(store: store, initialState: initialState),
      ),
    );
    await tester.pumpAndSettle();

    Finder escapeTileFinder() => find.byWidgetPredicate(
      (widget) => widget is GradientArrowTile && widget.index == escapeIndex,
    );

    tester.widget<GradientArrowTile>(escapeTileFinder()).onTap();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      tester.widget<GradientArrowTile>(escapeTileFinder()).isEscaping,
      isTrue,
    );

    final undoButton = find.ancestor(
      of: find.text('Undo'),
      matching: find.byType(GameplayControlButton),
    );
    tester.widget<GameplayControlButton>(undoButton).onTap();
    await tester.pumpAndSettle();

    expect(escapeTileFinder(), findsOneWidget);
    expect(
      tester.widget<GradientArrowTile>(escapeTileFinder()).isEscaping,
      isFalse,
    );

    tester.widget<GradientArrowTile>(escapeTileFinder()).onTap();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      tester.widget<GradientArrowTile>(escapeTileFinder()).isEscaping,
      isTrue,
    );

    await tester.pumpAndSettle();
  });

  testWidgets('Completion dialog text has no decoration in both themes', (
    tester,
  ) async {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: brightness == Brightness.light
              ? AppTheme.light
              : AppTheme.dark,
          home: Scaffold(
            body: ArrowBoxLevelCompleteDialog(
              level: 3,
              moves: 6,
              mistakes: 0,
              hintsUsed: 0,
              stars: 3,
              seconds: 42,
              onNextLevel: () {},
              onReplayLevel: () {},
              onLevelSelection: () {},
              onMainMenu: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final title = tester.widget<Text>(find.text('Level Complete!'));
      final subtitle = tester.widget<Text>(find.text('Great job!'));
      expect(title.style?.decoration, isNot(TextDecoration.underline));
      expect(subtitle.style?.decoration, isNot(TextDecoration.underline));
    }
  });

  testWidgets('App theme selection changes effective brightness', (
    tester,
  ) async {
    final store = await AppStore.load();
    await store.setThemeMode(ThemeMode.light);
    await tester.pumpWidget(ArrowBoxApp(store: store));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Play Now'))).brightness,
      Brightness.light,
    );

    await store.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Play Now'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('Settings screen renders categories and switches', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.reset());

    final store = await AppStore.load();

    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('GAMEPLAY'), findsOneWidget);
    expect(find.text('Haptic feedback'), findsOneWidget);
    expect(find.text('Show hints'), findsOneWidget);
    expect(find.text('AUDIO'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('Dark theme'), findsOneWidget);
  });

  testWidgets('Progress screen displays circular progress and 4 metric cards', (
    tester,
  ) async {
    final store = await AppStore.load();

    await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('2 / ${AppStore.totalLevels}'), findsOneWidget);
    expect(find.text('Total Levels'), findsOneWidget);
    expect(find.text('${AppStore.totalLevels}'), findsOneWidget);
    expect(find.text('Current Level'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Games Played'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Total Mistakes'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('How to Play screen renders 4 step cards', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HowToPlayScreen()));
    await tester.pumpAndSettle();

    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Each block has a direction'), findsOneWidget);
    expect(find.text('Clear path to the edge'), findsOneWidget);
    expect(find.text('Remove the block'), findsOneWidget);
    expect(find.text('Complete the level'), findsOneWidget);
  });

  testWidgets('About screen renders version and legal rows', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('ArrowBox'), findsOneWidget);
    expect(find.text('Think. Aim. Escape.'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Credits'), findsOneWidget);
  });
}
