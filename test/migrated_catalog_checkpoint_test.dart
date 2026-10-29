import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/levels/arrow_board_rules.dart';
import 'package:locate/features/arrowbox/levels/level_solver.dart';

void main() {
  test('migrated checkpoint independently validates all 500 levels', () {
    final file = File('tool/arrowbox_catalog_checkpoint_migrated.json');
    expect(file.existsSync(), isTrue);
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final rawResults = json['results'] as Map<String, dynamic>;
    expect(rawResults.length, 500);

    final layouts = <String>{};
    for (var level = 1; level <= 500; level++) {
      final result = rawResults['$level'] as Map<String, dynamic>;
      final difficulty = _difficultyFor(level);
      expect(result['level'], level);
      expect(result['difficulty'], difficulty.name);
      expect(result['status'], 'SUCCESS');
      expect(result['solverSolvable'], true);
      expect(result['replayVerified'], true);

      final layout = result['layout'] as String;
      expect(layouts.add(layout), isTrue, reason: 'Duplicate layout at $level');
      final values = layout.split(',');
      expect(values, hasLength(25));
      final board = [
        for (final value in values)
          _parseDirection(value, level),
      ];
      final metrics = LevelSolver.analyze(board);
      expect(metrics, isNotNull, reason: 'No solution at $level');
      final solution = metrics!.solution;
      final replay = List<ArrowDirection?>.of(board);
      for (final index in solution) {
        expect(arrowCanEscape(replay, index), isTrue, reason: 'Bad move at $level');
        replay[index] = null;
      }
      expect(replay.every((arrow) => arrow == null), isTrue);
      expect(result['initialChoices'], metrics.initialChoices);
      expect(result['dependencyDepth'], metrics.dependencyDepth);
      expect(
        (result['forcedMoveRatio'] as num).toDouble(),
        closeTo(metrics.forcedMoveRatio, 0.000001),
      );
      expect(result['directionCounts'], metrics.directionCounts);
      _expectProfile(level, difficulty, board, metrics);
    }
  });
}

ArrowDirection? _parseDirection(String value, int level) {
  final index = int.tryParse(value);
  expect(index, isNotNull, reason: 'Invalid cell at $level');
  expect(index, inInclusiveRange(-1, ArrowDirection.values.length - 1));
  return index == -1 ? null : ArrowDirection.values[index!];
}

void _expectProfile(
  int level,
  ArrowBoxDifficulty difficulty,
  List<ArrowDirection?> board,
  LevelSolutionMetrics metrics,
) {
  final occupied = board.whereType<ArrowDirection>().length;
  if (difficulty == ArrowBoxDifficulty.easy) {
    expect(occupied, level == 1 ? 8 : inInclusiveRange(8, 20));
    expect(metrics.initialChoices, inInclusiveRange(level <= 10 ? 2 : 1, level <= 10 ? 12 : 8));
    expect(metrics.dependencyDepth, greaterThanOrEqualTo(level <= 3 ? 0 : level <= 10 ? 1 : 2));
    expect(metrics.minimumDirectionCount, greaterThanOrEqualTo(level <= 3 ? 1 : 2));
    return;
  }
  if (difficulty == ArrowBoxDifficulty.medium) {
    expect(occupied, inInclusiveRange(16, 23));
    expect(metrics.initialChoices, inInclusiveRange(1, 6));
    expect(metrics.dependencyDepth, greaterThanOrEqualTo(level <= 130 ? 2 : 3));
    expect(metrics.minimumDirectionCount, greaterThanOrEqualTo(2));
    expect(metrics.forcedMoveRatio, greaterThanOrEqualTo(0.05));
    return;
  }
  expect(occupied, difficulty == ArrowBoxDifficulty.hard ? inInclusiveRange(20, 25) : 25);
  expect(metrics.initialChoices, inInclusiveRange(1, difficulty == ArrowBoxDifficulty.hard ? 6 : 8));
  expect(metrics.dependencyDepth, greaterThanOrEqualTo(3));
  expect(metrics.minimumDirectionCount, greaterThanOrEqualTo(3));
  expect(metrics.forcedMoveRatio, greaterThanOrEqualTo(0.05));
}

ArrowBoxDifficulty _difficultyFor(int level) {
  if (level <= 100) return ArrowBoxDifficulty.easy;
  if (level <= 200) return ArrowBoxDifficulty.medium;
  if (level <= 350) return ArrowBoxDifficulty.hard;
  return ArrowBoxDifficulty.ultraHard;
}
