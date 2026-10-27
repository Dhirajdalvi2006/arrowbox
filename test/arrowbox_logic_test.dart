import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';

void main() {
  group('ArrowDirection and Vector Tests', () {
    test('All four directions have correct vectors and descriptions', () {
      expect(ArrowDirection.up.vector, equals((-1, 0)));
      expect(ArrowDirection.right.vector, equals((0, 1)));
      expect(ArrowDirection.down.vector, equals((1, 0)));
      expect(ArrowDirection.left.vector, equals((0, -1)));

      expect(ArrowDirection.up.directionText, 'upward');
      expect(ArrowDirection.right.directionText, 'to the right');
      expect(ArrowDirection.down.directionText, 'downward');
      expect(ArrowDirection.left.directionText, 'to the left');
    });
  });

  group('Arrow Escape and Boundary Tests', () {
    test('Edge and corner arrows facing outward can escape immediately', () {
      final board = List<ArrowDirection?>.filled(25, null);
      board[0] = ArrowDirection.up; // top-left corner facing up
      board[4] = ArrowDirection.right; // top-right corner facing right
      board[20] = ArrowDirection.left; // bottom-left corner facing left
      board[24] = ArrowDirection.down; // bottom-right corner facing down

      final state = ArrowBoxState.fromJson({
        'level': 1,
        'lives': 3,
        'mistakes': 0,
        'board': board.map((a) => a?.name).toList(),
      });

      expect(state.canEscape(0), isTrue);
      expect(state.canEscape(4), isTrue);
      expect(state.canEscape(20), isTrue);
      expect(state.canEscape(24), isTrue);
    });

    test('Arrows blocked by another arrow cannot escape and decrement lives', () {
      final board = List<ArrowDirection?>.filled(25, null);
      // Row 2 Col 2 points right, but Row 2 Col 4 is occupied
      board[12] = ArrowDirection.right;
      board[14] = ArrowDirection.down;

      var state = ArrowBoxState.fromJson({
        'level': 1,
        'lives': 3,
        'mistakes': 0,
        'board': board.map((a) => a?.name).toList(),
      });

      expect(state.canEscape(12), isFalse);
      expect(state.canEscape(14), isTrue); // 14 points down to col 4 row 3, 4 (empty) -> can escape!

      // Attempt invalid move on blocked arrow
      final result = state.move(12);
      expect(result.wasValid, isFalse);
      expect(result.state.lives, 2);
      expect(result.state.mistakes, 1);
      expect(result.state.board[12], ArrowDirection.right); // still on board
    });

    test('Successful arrow removal after valid move', () {
      final board = List<ArrowDirection?>.filled(25, null);
      board[0] = ArrowDirection.up;

      final state = ArrowBoxState.fromJson({
        'level': 1,
        'lives': 3,
        'mistakes': 0,
        'board': board.map((a) => a?.name).toList(),
      });

      final result = state.move(0);
      expect(result.wasValid, isTrue);
      expect(result.reachedEndState, isTrue); // cleared!
      expect(result.state.board[0], isNull);
      expect(result.state.isCleared, isTrue);
    });

    test('Game over occurs when lives reach zero', () {
      final board = List<ArrowDirection?>.filled(25, null);
      board[0] = ArrowDirection.down;
      board[5] = ArrowDirection.up;

      var state = ArrowBoxState.fromJson({
        'level': 1,
        'lives': 1,
        'mistakes': 2,
        'board': board.map((a) => a?.name).toList(),
      });

      final result = state.move(0); // blocked by 5
      expect(result.wasValid, isFalse);
      expect(result.reachedEndState, isTrue);
      expect(result.state.isGameOver, isTrue);
      expect(result.state.lives, 0);
      expect(result.state.mistakes, 3);
    });

    test('Restart resets lives, mistakes, and board to initial state', () {
      var state = ArrowBoxState.initial(level: 1);
      final initialBoard = List<ArrowDirection?>.from(state.board);

      // Play move or mistake
      final invalidRes = state.move(0);
      state = invalidRes.state;

      final restarted = state.restart();
      expect(restarted.lives, 3);
      expect(restarted.mistakes, 0);
      expect(restarted.board, equals(initialBoard));
    });

    test('Undo restores previous state', () {
      var state = ArrowBoxState.initial(level: 1);
      final initialBoard = List<ArrowDirection?>.from(state.board);
      final escapeIdx = state.nextEscapeIndex!;

      final moveRes = state.move(escapeIdx);
      expect(moveRes.wasValid, isTrue);
      expect(moveRes.state.board[escapeIdx], isNull);

      final undone = moveRes.state.undo();
      expect(undone.board, equals(initialBoard));
      expect(undone.board[escapeIdx], isNotNull);
    });
  });

  group('Progress persistence', () {
    test('Completion awards and preserves the best star rating', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await AppStore.load();

      await store.recordCompletion(3, 2);
      expect(store.levelStars[3], 1);
      await store.recordCompletion(3, 0);
      expect(store.levelStars[3], 3);
      await store.recordCompletion(3, 1);
      expect(store.levelStars[3], 3);
      await store.recordCompletion(4, 0, hintsUsed: 1);
      expect(store.levelStars[4], 2);
      await store.recordCompletion(5, 0, hintsUsed: 2);
      expect(store.levelStars[5], 1);

      final reloaded = await AppStore.load();
      expect(reloaded.levelStars[3], 3);
      expect(reloaded.levelStars[4], 2);
      expect(reloaded.levelStars[5], 1);
    });

    test('Saved games preserve history, hints, and remain isolated by level', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await AppStore.load();
      final first = ArrowBoxState.initial(level: 1);
      final firstMoved = first.move(first.nextEscapeIndex!).state.useHint();
      final second = ArrowBoxState.initial(level: 2).withSeconds(9);

      await store.saveGame(firstMoved);
      await store.saveGame(second);
      final reloaded = await AppStore.load();

      expect(reloaded.savedGames[1]?.hintsUsed, 1);
      expect(reloaded.savedGames[1]?.history, isNotEmpty);
      expect(reloaded.savedGames[2]?.secondsElapsed, 9);
    });

    test('High-number levels persist progress and saved sessions', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await AppStore.load();
      await store.recordCompletion(250, 0);
      await store.saveGame(ArrowBoxState.initial(level: 417).withSeconds(12));

      final reloaded = await AppStore.load();
      expect(reloaded.completedLevels, contains(250));
      expect(reloaded.unlockedLevel, 251);
      expect(reloaded.savedGames[417]?.secondsElapsed, 12);
    });

    test('Clearing a level save does not resurrect it after queued writes', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await AppStore.load();
      final state = ArrowBoxState.initial(level: 1);

      final save = store.saveGame(state);
      final clear = store.clearSavedGame(level: 1);
      await Future.wait([save, clear]);
      final reloaded = await AppStore.load();

      expect(reloaded.savedGames, isEmpty);
      expect(reloaded.hasSavedGame, isFalse);
    });
  });

  group('500-level catalog', () {
    test('Catalog has 500 deterministic levels with mixed difficulty', () {
      expect(ArrowBoxLevel.count, 500);
      expect(ArrowBoxLevel.forNumber(1).occupiedCount, 8);
      expect(ArrowBoxLevel.forNumber(500).dependencyDepth, greaterThanOrEqualTo(3));
      expect(ArrowBoxLevel.forNumber(31).difficulty, isNotNull);
      expect(
        ArrowBoxLevel.forNumber(500).difficulty,
        isIn([ArrowBoxDifficulty.hard, ArrowBoxDifficulty.ultraHard]),
      );
      final difficulties = <ArrowBoxDifficulty>{
        for (var level = 1; level <= ArrowBoxLevel.count; level++)
          ArrowBoxLevel.forNumber(level).difficulty,
      };
      expect(difficulties, containsAll(ArrowBoxDifficulty.values));
    });

    test('Every catalog board has exactly 25 cells and unique layout', () {
      final layouts = <String>{};
      for (var level = 1; level <= ArrowBoxLevel.count; level++) {
        final catalogLevel = ArrowBoxLevel.forNumber(level);
        expect(catalogLevel.arrows, hasLength(25));
        expect(
          layouts.add(catalogLevel.arrows.map((arrow) => arrow?.name ?? '-').join(',')),
          isTrue,
          reason: 'Level $level duplicates another catalog board',
        );
      }
    });

    test('Dense difficulty profiles enforce branching constraints', () {
      for (var level = 1; level <= ArrowBoxLevel.count; level++) {
        final catalogLevel = ArrowBoxLevel.forNumber(level);
        if (catalogLevel.difficulty == ArrowBoxDifficulty.medium) continue;

        var state = ArrowBoxState.initial(level: level);
        final firstChoices = [
          for (var index = 0; index < state.board.length; index++)
            if (state.canEscape(index)) index,
        ].length;
        var forcedSteps = 0;
        var steps = 0;
        while (!state.isCleared) {
          final available = [
            for (var index = 0; index < state.board.length; index++)
              if (state.canEscape(index)) index,
          ];
          if (available.length == 1) forcedSteps++;
          final result = state.move(available.first);
          expect(result.wasValid, isTrue);
          state = result.state;
          steps++;
        }
        final forcedRatio = forcedSteps / steps;
        if (catalogLevel.difficulty == ArrowBoxDifficulty.hard) {
          expect(firstChoices, inInclusiveRange(2, 8), reason: 'Level $level');
          expect(forcedRatio, inInclusiveRange(0.10, 0.85), reason: 'Level $level');
        } else {
          expect(firstChoices, inInclusiveRange(1, 8), reason: 'Level $level');
          expect(forcedRatio, greaterThanOrEqualTo(0.10), reason: 'Level $level');
        }
      }
    });

    test('Every dense level has a real dependency after its first move', () {
      var foundDependency = false;
      for (var level = 1; level <= ArrowBoxLevel.count; level++) {
        final catalogLevel = ArrowBoxLevel.forNumber(level);
        if (catalogLevel.difficulty == ArrowBoxDifficulty.medium) continue;

        var state = ArrowBoxState.initial(level: level);
        final first = state.nextEscapeIndex;
        expect(first, isNotNull, reason: 'Level $level has no first move');
        final result = state.move(first!);
        expect(result.wasValid, isTrue, reason: 'Level $level first move is invalid');
        state = result.state;
        final blockedRemaining = [
          for (var index = 0; index < state.board.length; index++)
            if (state.board[index] != null && !state.canEscape(index)) index,
        ];
        if (blockedRemaining.isNotEmpty) foundDependency = true;
      }
      expect(foundDependency, isTrue);
    });

    test('Catalog generation is deterministic for every level', () {
      for (var level = 1; level <= ArrowBoxLevel.count; level++) {
        final first = ArrowBoxLevel.forNumber(level);
        final second = ArrowBoxLevel.forNumber(level);
        expect(second.arrows, equals(first.arrows), reason: 'Level $level changed');
        expect(second.difficulty, first.difficulty);
        expect(second.difficultyScore, first.difficultyScore);
      }
    });

    test('Hard and Ultra Hard levels fill every board cell', () {
      for (var level = 1; level <= ArrowBoxLevel.count; level++) {
        final catalogLevel = ArrowBoxLevel.forNumber(level);
        if (catalogLevel.difficulty == ArrowBoxDifficulty.medium) continue;
        expect(
          catalogLevel.arrows.whereType<ArrowDirection>().length,
          25,
          reason: 'Level $level must have no empty cells',
        );
      }
    });

    test('Every catalog level can be completely solved', () {
      for (var l = 1; l <= ArrowBoxLevel.count; l++) {
        var state = ArrowBoxState.initial(level: l);
        var moves = 0;
        while (!state.isCleared) {
          final hint = state.nextEscapeIndex;
          expect(hint, isNotNull, reason: 'Level $l should have a valid next move at step $moves');
          final result = state.move(hint!);
          expect(result.wasValid, isTrue);
          state = result.state;
          moves++;
        }
        expect(state.isCleared, isTrue, reason: 'Level $l should be completely cleared');
      }
    });

    test('Final level does not wrap to level 1', () {
      expect(ArrowBoxState.initial(level: 500).nextLevel(), isNull);
      expect(ArrowBoxState.initial(level: 499).nextLevel()?.level, 500);
    });

    test('Level 500 saved state round-trips and level 501 is rejected', () {
      final original = ArrowBoxState.initial(level: 500).withSeconds(12);
      final restored = ArrowBoxState.fromJson(original.toJson());
      expect(restored.level, 500);
      expect(restored.board, equals(original.board));
      expect(restored.secondsElapsed, 12);

      expect(
        () => ArrowBoxState.initial(level: 501),
        throwsA(isA<RangeError>()),
      );
    });

    test('Level 3 matches reference hint initially', () {
      final state = ArrowBoxState.initial(level: 3);
      expect(state.nextEscapeIndex, 0);
      expect(state.hintMessage, 'The blue arrow can escape upward.');
    });
  });
}
