import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';

/// Builds a state from a sparse index → direction map.
ArrowBoxState _state(
  Map<int, ArrowDirection> arrows, {
  int level = 1,
  int lives = 3,
  int hintsUsed = 0,
}) {
  return ArrowBoxState.fromJson({
    'level': level,
    'lives': lives,
    'mistakes': 0,
    'moves': 0,
    'secondsElapsed': 0,
    'hintsUsed': hintsUsed,
    'board': [for (var i = 0; i < 25; i++) arrows[i]?.name],
  });
}

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

void main() {
  group('Hint correctness: directions', () {
    test('upward arrow with a clear path is escapable', () {
      final state = _state({20: ArrowDirection.up});
      expect(state.canEscape(20), isTrue);
      expect(state.nextEscapeIndex, 20);
    });

    test('rightward arrow with a clear path is escapable', () {
      final state = _state({10: ArrowDirection.right});
      expect(state.canEscape(10), isTrue);
      expect(state.nextEscapeIndex, 10);
    });

    test('downward arrow with a clear path is escapable', () {
      final state = _state({2: ArrowDirection.down});
      expect(state.canEscape(2), isTrue);
      expect(state.nextEscapeIndex, 2);
    });

    test('leftward arrow with a clear path is escapable', () {
      final state = _state({24: ArrowDirection.left});
      expect(state.canEscape(24), isTrue);
      expect(state.nextEscapeIndex, 24);
    });
  });

  group('Hint correctness: blocking', () {
    test('a blocked arrow is never suggested as immediately escapable', () {
      // Index 2 points right but index 3 blocks its ray. Index 3 points down
      // and has a clear path, so it is the only valid hint.
      final state = _state({2: ArrowDirection.right, 3: ArrowDirection.down});

      expect(state.canEscape(2), isFalse);
      expect(state.canEscape(3), isTrue);
      expect(state.nextEscapeIndex, isNot(2));
      expect(state.nextEscapeIndex, 3);
    });

    test('a fully blocked board produces no hint', () {
      final state = _state(_fullyBlockedBoard());

      expect(state.nextEscapeIndex, isNull);
      expect(state.hintMessage, contains('No clear path'));
    });

    test('useHint does not consume a credit when there is no suggestion', () {
      final state = _state(_fullyBlockedBoard());

      final hinted = state.useHint();
      expect(hinted.hintsUsed, state.hintsUsed);
      expect(hinted.board, state.board);
    });
  });

  group('Hint correctness: live board state', () {
    test('hint matches the current board and follows a successful escape', () {
      final state = _state({0: ArrowDirection.up, 24: ArrowDirection.down});

      expect(state.nextEscapeIndex, 0);

      final moved = state.move(state.nextEscapeIndex!);
      expect(moved.wasValid, isTrue);

      // The removed arrow is gone, and the next hint is the other arrow,
      // which is genuinely escapable in the updated board.
      expect(moved.state.board[0], isNull);
      expect(moved.state.nextEscapeIndex, 24);
      expect(moved.state.canEscape(24), isTrue);
    });

    test('hint generation never mutates the board or consumes a move', () {
      final state = _state({2: ArrowDirection.right, 3: ArrowDirection.down});
      final snapshot = List<ArrowDirection?>.of(state.board);

      final hint = state.nextEscapeIndex;
      expect(hint, isNotNull);
      expect(state.canEscape(hint!), isTrue);

      final hinted = state.useHint();
      expect(hinted.board, snapshot);
      expect(state.board, snapshot);
      expect(hinted.moves, state.moves);
      expect(hinted.mistakes, state.mistakes);
      expect(hinted.lives, state.lives);
      expect(hinted.hintsUsed, state.hintsUsed + 1);
    });

    test('repeated hint taps remain consistent with the current board', () {
      final state = _state({2: ArrowDirection.right, 3: ArrowDirection.down});

      final first = state.useHint();
      final second = first.useHint();

      expect(first.nextEscapeIndex, second.nextEscapeIndex);
      expect(second.board, state.board);
      expect(second.hintsUsed, state.hintsUsed + 2);
    });

    test('invalid moves do not corrupt the hint state', () {
      final state = _state({2: ArrowDirection.right, 3: ArrowDirection.down});
      expect(state.nextEscapeIndex, 3);

      // Tapping the blocked arrow costs a life but leaves the board intact.
      final blocked = state.move(2);
      expect(blocked.wasValid, isFalse);
      expect(blocked.state.board, state.board);
      expect(blocked.state.nextEscapeIndex, 3);
      expect(blocked.state.canEscape(3), isTrue);
    });

    test('hint remains correct after several arrows are removed', () {
      var state = ArrowBoxState.initial(level: 1);
      var removed = 0;

      while (!state.isCleared && removed < 25) {
        final hint = state.nextEscapeIndex;
        expect(hint, isNotNull, reason: 'solvable board must expose a hint');
        expect(state.canEscape(hint!), isTrue);

        final result = state.move(hint);
        expect(result.wasValid, isTrue);
        expect(result.state.board[hint], isNull);

        state = result.state;
        removed++;
      }

      expect(state.isCleared, isTrue);
      expect(removed, greaterThan(1));
      expect(state.nextEscapeIndex, isNull);
    });

    test('game over and cleared states are handled safely', () {
      final gameOver = _state({0: ArrowDirection.up}, lives: 0);
      expect(gameOver.isGameOver, isTrue);
      // Hint generation stays a pure read even when the game is over.
      final snapshot = List<ArrowDirection?>.of(gameOver.board);
      gameOver.nextEscapeIndex;
      expect(gameOver.board, snapshot);

      final cleared = _state({});
      expect(cleared.isCleared, isTrue);
      expect(cleared.nextEscapeIndex, isNull);
      expect(cleared.useHint().hintsUsed, 0);
    });

    test('restart produces a fresh state with no leftover hint credits', () {
      final state = _state({0: ArrowDirection.up}).useHint();
      expect(state.hintsUsed, 1);

      final restarted = state.restart();
      expect(restarted.hintsUsed, 0);
      expect(restarted.board, ArrowBoxState.initial(level: 1).board);
    });
  });
}
