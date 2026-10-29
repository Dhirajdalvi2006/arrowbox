import 'dart:io';

import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/levels/board_generator.dart';
import 'package:locate/features/arrowbox/levels/easy_levels.dart';
import 'package:locate/features/arrowbox/levels/hard_levels.dart';
import 'package:locate/features/arrowbox/levels/medium_levels.dart';
import 'package:locate/features/arrowbox/levels/ultra_hard_levels.dart';

void main(List<String> args) {
  final start = args.isEmpty ? 1 : int.parse(args[0]);
  final end = args.length < 2 ? start : int.parse(args[1]);
  final layouts = <String>{};
  final total = Stopwatch()..start();

  for (var level = 1; level <= end; level++) {
    if (level < start) {
      final board = _generate(level, layouts: layouts);
      layouts.add(_key(board));
      continue;
    }

    final stats = BoardGenerationStats();
    final watch = Stopwatch()..start();
    try {
      final board = _generate(level, layouts: layouts, stats: stats);
      final key = _key(board);
      final duplicate = !layouts.add(key);
      stdout.writeln(
        'level=$level arrows=${board.whereType<ArrowDirection>().length} '
        'ms=${watch.elapsedMilliseconds} duplicate=$duplicate '
        'attempts=${stats.attempts} nodes=${stats.nodesExpanded} '
        'backtracks=${stats.backtracks} solvers=${stats.solverInvocations} '
        'initialRejects=${stats.initialChoiceRejections} '
        'dependencyRejects=${stats.dependencyRejections} '
        'solverMs=${stats.solverElapsedMicroseconds / 1000} '
        'solverMisses=${stats.solverCacheMisses} '
        'solverHits=${stats.solverCacheHits} '
        'solverStates=${stats.solverStatesVisited}',
      );
      if (duplicate) exitCode = 2;
    } catch (error) {
      stderr.writeln(
        'level=$level ERROR=$error ms=${watch.elapsedMilliseconds} '
        'attempts=${stats.attempts} nodes=${stats.nodesExpanded} '
        'backtracks=${stats.backtracks} solvers=${stats.solverInvocations} '
        'initialRejects=${stats.initialChoiceRejections} '
        'dependencyRejects=${stats.dependencyRejections} '
        'solverMs=${stats.solverElapsedMicroseconds / 1000} '
        'solverMisses=${stats.solverCacheMisses} '
        'solverHits=${stats.solverCacheHits} '
        'solverStates=${stats.solverStatesVisited}',
      );
      exitCode = 2;
      break;
    }
  }
  stdout.writeln('requested=$start..$end elapsedMs=${total.elapsedMilliseconds}');
}

List<ArrowDirection?> _generate(
  int level, {
  required Set<String> layouts,
  BoardGenerationStats? stats,
}) {
  final difficulty = level <= 100
      ? ArrowBoxDifficulty.easy
      : level <= 200
          ? ArrowBoxDifficulty.medium
          : level <= 350
              ? ArrowBoxDifficulty.hard
              : ArrowBoxDifficulty.ultraHard;
  return switch (difficulty) {
    ArrowBoxDifficulty.easy => EasyLevels.generate(
        level,
        excludedLayouts: layouts,
        stats: stats,
      ),
    ArrowBoxDifficulty.medium => MediumLevels.generate(
        level,
        excludedLayouts: layouts,
        stats: stats,
      ),
    ArrowBoxDifficulty.hard => HardLevels.generate(
        level,
        excludedLayouts: layouts,
        stats: stats,
      ),
    ArrowBoxDifficulty.ultraHard => UltraHardLevels.generate(
        level,
        excludedLayouts: layouts,
        stats: stats,
      ),
  };
}

String _key(List<ArrowDirection?> board) =>
    board.map((arrow) => arrow?.index ?? -1).join(',');
