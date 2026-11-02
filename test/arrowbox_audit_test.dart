import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/features/arrowbox/arrowbox_board_widgets.dart';
import 'package:locate/features/arrowbox/arrowbox_screen.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';

/// Board with two arrows: index 2 points right, index 3 blocks its ray.
ArrowBoxState _blockedGame({int lives = 3, int mistakes = 0}) {
  return ArrowBoxState.fromJson({
    'level': 1,
    'lives': lives,
    'mistakes': mistakes,
    'board': [
      for (var i = 0; i < 25; i++) i == 2 ? 'right' : (i == 3 ? 'down' : null),
    ],
  });
}

void main() {
  group('Audit: escape validation and hearts', () {
    test(
      'valid escape consumes no heart and clears the arrow exactly once',
      () {
        // Create a board with a single arrow that can escape (top row arrow pointing up)
        final board = List<ArrowDirection?>.filled(25, null);
        board[0] = ArrowDirection.up; // Can escape immediately
        final state = ArrowBoxState.fromJson({
          'level': 1,
          'lives': 3,
          'mistakes': 0,
          'board': board.map((a) => a?.name).toList(),
        });

        expect(state.canEscape(0), isTrue);
        final result = state.move(0);

        expect(result.wasValid, isTrue);
        expect(result.state.board[0], isNull);
        expect(result.state.lives, 3);
        expect(result.state.mistakes, 0);
      },
    );

    test('blocked arrow consumes exactly one heart and keeps the arrow', () {
      final state = _blockedGame(lives: 3, mistakes: 0);
      expect(state.canEscape(2), isFalse);

      final result = state.move(2);

      expect(result.wasValid, isFalse);
      expect(result.state.lives, 2);
      expect(result.state.mistakes, 1);
      expect(result.state.board[2], ArrowDirection.right);
      expect(result.state.isGameOver, isFalse);

      final second = result.state.move(2);
      expect(second.wasValid, isFalse);
      expect(second.state.lives, 1);
      expect(second.state.mistakes, 2);
      expect(second.state.board[2], ArrowDirection.right);
    });

    test('third mistake ends the game and further moves stay blocked', () {
      final state = _blockedGame(lives: 1, mistakes: 2);
      final result = state.move(2);

      expect(result.wasValid, isFalse);
      expect(result.state.isGameOver, isTrue);
      expect(result.state.lives, 0);
      expect(result.state.mistakes, 3);

      final further = result.state.move(2);
      expect(further.wasValid, isFalse);
      expect(further.state.lives, 0);
      expect(further.state.mistakes, 3);
    });
  });

  group('Audit: widget game over, restart and timer', () {
    testWidgets('game over dialog appears once and restart resets board', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'confirmRestart': false});
      final store = await AppStore.load();
      final game = _blockedGame(lives: 1, mistakes: 2);

      await tester.pumpWidget(
        MaterialApp(
          home: ArrowBoxScreen(store: store, initialState: game),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GradientArrowTile), findsNWidgets(2));
      expect(find.text('Game Over'), findsNothing);

      await tester.tap(find.byType(GradientArrowTile).first);
      await tester.pumpAndSettle();

      expect(find.text('Game Over'), findsOneWidget);

      await tester.tap(find.text('Restart Level'));
      await tester.pumpAndSettle();

      expect(find.text('Game Over'), findsNothing);
      // Board resets back to the level's initial layout (level 1 has 8 arrows).
      expect(find.byType(GradientArrowTile), findsNWidgets(8));
    });

    testWidgets('restart after game over restarts the countdown timer', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'confirmRestart': false});
      final store = await AppStore.load();
      final game = _blockedGame(lives: 1, mistakes: 2);

      await tester.pumpWidget(
        MaterialApp(
          home: ArrowBoxScreen(store: store, initialState: game),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GradientArrowTile).first);
      await tester.pumpAndSettle();

      expect(find.text('Game Over'), findsOneWidget);
      await tester.tap(find.text('Restart Level'));
      await tester.pumpAndSettle();

      // Restart resets the clock; the periodic timer must be running again.
      // With a live timer the display moves past the reset value (00:00).
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('00:00'), findsNothing);
    });

    testWidgets('restart during pending escape animation discards stale exit', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'confirmRestart': false});
      final store = await AppStore.load();
      final game = ArrowBoxState.fromJson({
        'level': 1,
        'lives': 3,
        'mistakes': 0,
        'board': [
          for (var i = 0; i < 25; i++) i == 0 ? 'up' : (i == 7 ? 'down' : null),
        ],
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ArrowBoxScreen(store: store, initialState: game),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GradientArrowTile), findsNWidgets(2));

      // Start a legitimate escape (arrow leaves the logical board + visual).
      await tester.tap(find.byType(GradientArrowTile).first);
      await tester.pumpAndSettle();
      expect(find.byType(GradientArrowTile), findsNWidgets(1));

      // Restart while the exit animation is still pending.
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();

      // Restart must reset the board back to the level's initial layout
      // (level 1 starts with 8 arrows).
      expect(find.byType(GradientArrowTile), findsNWidgets(8));
      expect(tester.takeException(), isNull);
    });
  });
}
