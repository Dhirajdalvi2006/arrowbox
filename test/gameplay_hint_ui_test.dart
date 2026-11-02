import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/features/arrowbox/arrowbox_board_widgets.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/arrowbox_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a state from a sparse index → direction map.
ArrowBoxState _state(
  Map<int, ArrowDirection> arrows, {
  int level = 1,
  int lives = 3,
}) {
  return ArrowBoxState.fromJson({
    'level': level,
    'lives': lives,
    'mistakes': 0,
    'moves': 0,
    'secondsElapsed': 0,
    'hintsUsed': 0,
    'board': [for (var i = 0; i < 25; i++) arrows[i]?.name],
  });
}

Finder get _restartButton =>
    find.widgetWithText(GameplayControlButton, 'Restart');
Finder get _hintButton => find.widgetWithText(GameplayControlButton, 'Hint');
Finder get _highlightedTiles => find.byWidgetPredicate(
  (widget) => widget is GradientArrowTile && widget.highlighted,
);
Finder _tileAt(int index) => find.byWidgetPredicate(
  (widget) => widget is GradientArrowTile && widget.index == index,
);

/// A full board where every arrow points into another occupied cell, so no
/// arrow has a clear path to an edge.
Map<int, ArrowDirection> _fullyBlockedBoard() {
  final arrows = <int, ArrowDirection>{};
  for (var i = 0; i < 25; i++) {
    final row = i ~/ 5;
    final column = i % 5;
    if (row == 0) {
      arrows[i] = ArrowDirection.down;
    } else if (row == 4) {
      arrows[i] = ArrowDirection.up;
    } else if (column == 0) {
      arrows[i] = ArrowDirection.right;
    } else if (column == 4) {
      arrows[i] = ArrowDirection.left;
    } else {
      arrows[i] = ArrowDirection.up;
    }
  }
  return arrows;
}

Future<void> _pumpGame(
  WidgetTester tester,
  ArrowBoxState game, {
  Size? logicalSize,
}) async {
  SharedPreferences.setMockInitialValues({'confirmRestart': false});
  final store = await AppStore.load();

  // A tall-enough viewport keeps the board and bottom controls on screen.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = logicalSize ?? const Size(430, 900);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: ArrowBoxScreen(store: store, initialState: game),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Gameplay controls', () {
    testWidgets('shows only Restart and Hint, with no Undo', (tester) async {
      await _pumpGame(tester, ArrowBoxState.initial(level: 1));

      expect(_restartButton, findsOneWidget);
      expect(_hintButton, findsOneWidget);
      expect(find.byType(GameplayControlButton), findsNWidgets(2));
      expect(find.text('Undo'), findsNothing);
    });

    testWidgets('keeps the lightbulb icon on the Hint button', (tester) async {
      await _pumpGame(tester, ArrowBoxState.initial(level: 1));

      expect(find.byIcon(Icons.lightbulb_rounded), findsOneWidget);
    });

    testWidgets('removes the standalone explanatory Hint card', (tester) async {
      await _pumpGame(tester, ArrowBoxState.initial(level: 1));

      // The only "Hint" text is the control label; the old card also rendered
      // a heading plus the generated explanation and a chevron.
      expect(find.text('Hint'), findsOneWidget);
      expect(find.textContaining('can escape'), findsNothing);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.byType(GameplayControlButton), findsNWidgets(2));
    });

    testWidgets('Restart remains clickable and resets the board', (
      tester,
    ) async {
      await _pumpGame(
        tester,
        _state({2: ArrowDirection.right, 3: ArrowDirection.down}),
      );
      expect(find.byType(GradientArrowTile), findsNWidgets(2));

      await tester.tap(_restartButton);
      await tester.pumpAndSettle();

      // Level 1's initial layout has 8 arrows.
      expect(find.byType(GradientArrowTile), findsNWidgets(8));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Hint remains clickable and highlights a valid arrow', (
      tester,
    ) async {
      await _pumpGame(
        tester,
        _state({2: ArrowDirection.right, 3: ArrowDirection.down}),
      );

      await tester.tap(_hintButton);
      await tester.pump(); // pulse animation repeats, so don't settle

      expect(_highlightedTiles, findsOneWidget);
    });

    testWidgets('controls fit a narrow phone without overflow', (tester) async {
      await _pumpGame(
        tester,
        ArrowBoxState.initial(level: 1),
        logicalSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
      expect(_restartButton, findsOneWidget);
      expect(_hintButton, findsOneWidget);

      final restartRect = tester.getRect(_restartButton);
      final hintRect = tester.getRect(_hintButton);
      expect(restartRect.right, lessThanOrEqualTo(320));
      expect(hintRect.right, lessThanOrEqualTo(320));
      expect(restartRect.bottom, lessThanOrEqualTo(640));
      expect(hintRect.bottom, lessThanOrEqualTo(640));
    });
  });

  group('Hint visual feedback', () {
    testWidgets('highlights an arrow that is genuinely escapable', (
      tester,
    ) async {
      final game = _state({
        2: ArrowDirection.right, // blocked by index 3
        3: ArrowDirection.down, // clear path
      });
      await _pumpGame(tester, game);

      await tester.tap(_hintButton);
      await tester.pump();

      final tile = tester.widget<GradientArrowTile>(_highlightedTiles);
      expect(tile.index, 3);
      expect(game.canEscape(tile.index), isTrue);
      expect(find.byType(GradientArrowTile), findsNWidgets(2));
    });

    testWidgets('clears the highlight when the hinted arrow is removed', (
      tester,
    ) async {
      await _pumpGame(
        tester,
        _state({2: ArrowDirection.right, 3: ArrowDirection.down}),
      );

      await tester.tap(_hintButton);
      await tester.pump();
      await tester.tap(_highlightedTiles);
      await tester.pumpAndSettle();

      expect(_highlightedTiles, findsNothing);
      expect(_tileAt(3), findsNothing);
      expect(_tileAt(2), findsOneWidget);
    });

    testWidgets(
      'an invalid tap clears the highlight and the next hint is valid',
      (tester) async {
        await _pumpGame(
          tester,
          _state({2: ArrowDirection.right, 3: ArrowDirection.down}),
        );

        await tester.tap(_hintButton);
        await tester.pump();
        expect(_highlightedTiles, findsOneWidget);

        // Tap the blocked arrow — this costs a life but must not corrupt hints.
        await tester.tap(_tileAt(2));
        await tester.pumpAndSettle();
        expect(_highlightedTiles, findsNothing);

        await tester.tap(_hintButton);
        await tester.pump();
        final tile = tester.widget<GradientArrowTile>(_highlightedTiles);
        expect(tile.index, 3);
      },
    );

    testWidgets('Restart clears stale hint highlighting', (tester) async {
      await _pumpGame(
        tester,
        _state({2: ArrowDirection.right, 3: ArrowDirection.down}),
      );

      await tester.tap(_hintButton);
      await tester.pump();
      expect(_highlightedTiles, findsOneWidget);

      await tester.tap(_restartButton);
      await tester.pumpAndSettle();

      expect(_highlightedTiles, findsNothing);
    });

    testWidgets('a new hint after Restart is valid again', (tester) async {
      await _pumpGame(
        tester,
        _state({2: ArrowDirection.right, 3: ArrowDirection.down}),
      );

      await tester.tap(_hintButton);
      await tester.pump();
      await tester.tap(_restartButton);
      await tester.pumpAndSettle();

      await tester.tap(_hintButton);
      await tester.pump();

      final tile = tester.widget<GradientArrowTile>(_highlightedTiles);
      final levelOne = ArrowBoxState.initial(level: 1);
      expect(levelOne.canEscape(tile.index), isTrue);
    });

    testWidgets('shows a concise message when no arrow can escape', (
      tester,
    ) async {
      final blocked = _state(_fullyBlockedBoard());
      await _pumpGame(tester, blocked);

      await tester.tap(_hintButton);
      await tester.pump();

      expect(_highlightedTiles, findsNothing);
      expect(
        find.textContaining('No arrow can escape right now'),
        findsOneWidget,
      );

      // Let the snack bar expire so no pending timer leaks into the next test.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('Hint is disabled when the game is over', (tester) async {
      await _pumpGame(tester, _state({0: ArrowDirection.up}, lives: 0));

      final button = tester.widget<GameplayControlButton>(_hintButton);
      expect(button.enabled, isFalse);
    });

    testWidgets('Hint is disabled when the level is already cleared', (
      tester,
    ) async {
      await _pumpGame(tester, _state({}));

      final button = tester.widget<GameplayControlButton>(_hintButton);
      expect(button.enabled, isFalse);
    });

    testWidgets('changing levels clears the stale hint state', (tester) async {
      await _pumpGame(tester, _state({0: ArrowDirection.up}));

      await tester.tap(_hintButton);
      await tester.pump();
      expect(_highlightedTiles, findsOneWidget);

      // Complete the single-arrow level.
      await tester.tap(_tileAt(0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // The completion dialog has a repeating animation, so pump a fixed
      // number of frames instead of pumpAndSettle.
      for (
        var i = 0;
        i < 15 && find.text('Level Complete!').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Level Complete!'), findsOneWidget);

      final nextLevel = find.text('Next Level ➔');
      expect(nextLevel, findsOneWidget);
      await tester.ensureVisible(nextLevel);
      await tester.tap(nextLevel);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(_highlightedTiles, findsNothing);

      // A fresh hint on the new level is valid for that level's board.
      await tester.tap(_hintButton);
      await tester.pump();
      final tile = tester.widget<GradientArrowTile>(_highlightedTiles);
      final levelTwo = ArrowBoxState.initial(level: 2);
      expect(levelTwo.canEscape(tile.index), isTrue);

      await tester.pump(const Duration(seconds: 1));
    });
  });
}
