import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/levels/arrow_board_rules.dart';
import 'package:locate/features/arrowbox/levels/level_solver.dart';

/// Independent escape-path oracle.
///
/// Traces the ray from an arrow to the board boundary using explicit row and
/// column arithmetic (row 0 is the top edge, column 0 is the left edge, screen
/// Y grows downward), without delegating to the production
/// [arrowCanEscape] implementation.
bool referenceCanEscape(List<ArrowDirection?> board, int index) {
  if (index < 0 || index >= board.length) return false;
  final arrow = board[index];
  if (arrow == null) return false;
  final row = index ~/ 5;
  final column = index % 5;
  final rowStep = arrow.vector.$1;
  final columnStep = arrow.vector.$2;
  var nextRow = row + rowStep;
  var nextColumn = column + columnStep;
  while (nextRow >= 0 && nextRow < 5 && nextColumn >= 0 && nextColumn < 5) {
    if (board[nextRow * 5 + nextColumn] != null) return false;
    nextRow += rowStep;
    nextColumn += columnStep;
  }
  return true;
}

/// Independent solvability oracle: exhaustive depth-first search over legal
/// escape removals with board-state de-duplication.
bool referenceCanClear(List<ArrowDirection?> board) {
  final current = List<ArrowDirection?>.of(board);
  return _clearBoard(current);
}

bool _clearBoard(List<ArrowDirection?> board) {
  if (board.every((arrow) => arrow == null)) return true;
  for (var index = 0; index < board.length; index++) {
    if (board[index] == null) continue;
    if (!referenceCanEscape(board, index)) continue;
    final next = List<ArrowDirection?>.of(board)..[index] = null;
    if (_clearBoard(next)) return true;
  }
  return false;
}

void main() {
  test(
    'all 500 catalog levels pass geometry, escape-oracle and solvability audit',
    () {
      expect(ArrowBoxLevel.count, 500);

      var loadedLevels = 0;
      var solvableLevels = 0;
      var unsolvableLevels = 0;
      var geometryFailures = 0;

      for (var level = 1; level <= ArrowBoxLevel.count; level++) {
        final levelObject = ArrowBoxLevel.forNumber(level);
        final board = levelObject.arrows;
        loadedLevels++;
        expect(board, hasLength(25), reason: 'Level $level geometry');

        var invalidGeometry = false;
        for (final arrow in board.whereType<ArrowDirection>()) {
          if (arrow.index < 0 || arrow.index > 3) {
            invalidGeometry = true;
          }
        }
        if (invalidGeometry) geometryFailures++;

        final metrics = LevelSolver.analyze(board);
        final solvableByOracle = referenceCanClear(board);
        expect(
          solvableByOracle,
          isTrue,
          reason: 'Level $level should be solvable per independent oracle',
        );
        expect(metrics, isNotNull, reason: 'Level $level has no solver result');
        expect(
          metrics!.solvable,
          isTrue,
          reason: 'Level $level solver disagrees with independent oracle',
        );
        solvableLevels++;

        // Per-arrow escape agreement between production and reference oracle.
        final legalChoices = <int>[];
        for (var index = 0; index < board.length; index++) {
          final production = arrowCanEscape(board, index);
          final reference = referenceCanEscape(board, index);
          expect(
            production,
            reference,
            reason: 'Level $level arrow $index escape disagreement',
          );
          if (reference) legalChoices.add(index);
        }
        expect(legalChoices.length, metrics.initialChoices);
      }

      expect(loadedLevels, 500);
      expect(solvableLevels, 500);
      expect(geometryFailures, 0);
      expect(unsolvableLevels, 0);
    },
  );
}
