import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/levels/arrow_board_rules.dart';
import 'package:locate/features/arrowbox/levels/level_solver.dart';

void main() {
  test('shared escape rules handle all four boundary directions', () {
    final boards = <ArrowDirection, List<ArrowDirection?>>{
      ArrowDirection.up: [
        ArrowDirection.up,
        ...List<ArrowDirection?>.filled(24, null),
      ],
      ArrowDirection.right: [
        ...List<ArrowDirection?>.filled(4, null),
        ArrowDirection.right,
        ...List<ArrowDirection?>.filled(20, null),
      ],
      ArrowDirection.down: [
        ...List<ArrowDirection?>.filled(20, null),
        ArrowDirection.down,
        ...List<ArrowDirection?>.filled(4, null),
      ],
      ArrowDirection.left: [
        ...List<ArrowDirection?>.filled(4, null),
        ArrowDirection.left,
        ...List<ArrowDirection?>.filled(20, null),
      ],
    };

    for (final entry in boards.entries) {
      final index = entry.value.indexOf(entry.key);
      expect(arrowCanEscape(entry.value, index), isTrue);
    }
  });

  test('solver distinguishes a blocked two-arrow cycle from a solution', () {
    final board = List<ArrowDirection?>.filled(25, null)
      ..[0] = ArrowDirection.right
      ..[1] = ArrowDirection.left;

    expect(LevelSolver.analyze(board), isNull);
    expect(LevelSolver.isSolvable(board), isFalse);
  });

  test('solver solution replays through shared escape rules', () {
    final board = List<ArrowDirection?>.filled(25, null)
      ..[0] = ArrowDirection.right
      ..[1] = ArrowDirection.right
      ..[5] = ArrowDirection.down;
    final metrics = LevelSolver.analyze(board);

    expect(metrics, isNotNull);
    final replay = List<ArrowDirection?>.of(board);
    for (final index in metrics!.solution) {
      expect(arrowCanEscape(replay, index), isTrue);
      replay[index] = null;
    }
    expect(replay.every((arrow) => arrow == null), isTrue);
  });

  test('every catalog level has a replayable independent solution', () {
    final layouts = <String>{};
    for (var level = 1; level <= ArrowBoxLevel.count; level++) {
      final board = ArrowBoxLevel.forNumber(level).arrows;
      expect(
        board,
        hasLength(25),
        reason: 'Level $level has invalid dimensions',
      );
      expect(
        layouts.add(board.map((arrow) => arrow?.name ?? '-').join(',')),
        isTrue,
      );

      final metrics = LevelSolver.analyze(board);
      expect(metrics, isNotNull, reason: 'Level $level has no solution');
      final replay = List<ArrowDirection?>.of(board);
      for (final index in metrics!.solution) {
        expect(
          arrowCanEscape(replay, index),
          isTrue,
          reason: 'Level $level step $index',
        );
        replay[index] = null;
      }
      expect(
        replay.every((arrow) => arrow == null),
        isTrue,
        reason: 'Level $level remained occupied',
      );
    }
  });
}
