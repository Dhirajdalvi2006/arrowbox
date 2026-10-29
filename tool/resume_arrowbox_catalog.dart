import 'dart:convert';
import 'dart:io';

import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/levels/arrow_board_rules.dart';
import 'package:locate/features/arrowbox/levels/board_generator.dart';
import 'package:locate/features/arrowbox/levels/easy_levels.dart';
import 'package:locate/features/arrowbox/levels/hard_levels.dart';
import 'package:locate/features/arrowbox/levels/medium_levels.dart';
import 'package:locate/features/arrowbox/levels/level_solver.dart';
import 'package:locate/features/arrowbox/levels/ultra_hard_levels.dart';

import 'catalog_checkpoint.dart';

void main(List<String> args) {
  final options = _Options.parse(args);
  final configuration = [
    'schema=1',
    'start=${options.start}',
    'end=${options.end}',
    'maxAttempts=${options.maxAttempts}',
    'maxNodes=${options.maxNodes}',
  ].join(';');
  final file = File(options.checkpoint);
  CatalogCheckpoint.recover(file);
  final checkpoint = _load(file, configuration, options);

  for (var level = options.start; level <= options.end; level++) {
    final previous = checkpoint.results[level];
    final difficulty = _difficultyFor(level);
    if (previous != null &&
        _enrichLegacySuccess(previous, level, difficulty, checkpoint)) {
      checkpoint.save(file);
      stdout.writeln('level=$level status=SUCCESS source=checkpoint');
      continue;
    }
    if (previous != null &&
        _isReusableSuccess(previous, level, difficulty, checkpoint)) {
      continue;
    }

    final stats = BoardGenerationStats();
    final watch = Stopwatch()..start();
    final outcome = _generate(
      difficulty,
      level,
      stats,
      options.maxAttempts,
      options.maxNodes,
      checkpoint.results.values
          .map((result) => result['layout'])
          .whereType<String>()
          .toSet(),
    );
    final status = _validateOutcome(outcome, difficulty, level, checkpoint);
    final metrics = outcome.board == null ? null : LevelSolver.analyze(outcome.board!);
    checkpoint.results[level] = {
      'level': level,
      'difficulty': difficulty.name,
      'status': status,
      'reason': outcome.reason,
      'elapsedMs': watch.elapsedMilliseconds,
      'attempts': stats.attempts,
      'nodes': stats.nodesExpanded,
      'backtracks': stats.backtracks,
      'solverInvocations': stats.solverInvocations,
      'solverSolvable': status == 'SUCCESS' && metrics?.solvable == true,
      'replayVerified': status == 'SUCCESS' && metrics != null &&
          _replays(outcome.board!, metrics.solution),
      if (metrics != null) ...{
        'initialChoices': metrics.initialChoices,
        'dependencyDepth': metrics.dependencyDepth,
        'forcedMoveRatio': metrics.forcedMoveRatio,
        'directionCounts': metrics.directionCounts,
      },
      if (outcome.board != null)
        'layout': outcome.board!.map((arrow) => arrow?.index ?? -1).join(','),
    };
    checkpoint.save(file);
    stdout.writeln(
      'level=$level status=$status elapsed=${watch.elapsedMilliseconds}ms',
    );
  }

  final expected = options.end - options.start + 1;
  final successful = checkpoint.results.values
      .where((result) => result['status'] == 'SUCCESS')
      .length;
  final complete = successful == expected;
  stdout.writeln(
    'complete=$complete validated=$successful expected=$expected '
    'range=${options.start}-${options.end} checkpoint=${file.path}',
  );
  if (!complete) exitCode = 2;
}

CatalogCheckpoint _load(File file, String configuration, _Options options) {
  if (!file.existsSync()) {
    return CatalogCheckpoint.empty(
      configuration: configuration,
      start: options.start,
      end: options.end,
    );
  }
  final checkpoint = CatalogCheckpoint.fromJson(
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
  );
  if (checkpoint.configuration != configuration ||
      checkpoint.start != options.start ||
      checkpoint.end != options.end) {
    throw StateError('Checkpoint configuration or range does not match');
  }
  for (final level in checkpoint.results.keys) {
    if (level < options.start || level > options.end) {
      throw StateError('Checkpoint contains out-of-range level $level');
    }
  }
  return checkpoint;
}

BoardGenerationResult _generate(
  ArrowBoxDifficulty difficulty,
  int level,
  BoardGenerationStats stats,
  int maxAttempts,
  int maxNodes,
  Set<String> excludedLayouts,
) => switch (difficulty) {
  ArrowBoxDifficulty.easy => EasyLevels.generateOutcome(
    level,
    excludedLayouts: excludedLayouts,
    stats: stats,
    maxAttempts: maxAttempts,
    maxNodesPerAttempt: maxNodes,
  ),
  ArrowBoxDifficulty.medium => MediumLevels.generateOutcome(
    level,
    excludedLayouts: excludedLayouts,
    stats: stats,
    maxAttempts: maxAttempts,
    maxNodesPerAttempt: maxNodes,
  ),
  ArrowBoxDifficulty.hard => HardLevels.generateOutcome(
    level,
    excludedLayouts: excludedLayouts,
    stats: stats,
    maxAttempts: maxAttempts,
    maxNodesPerAttempt: maxNodes,
  ),
  ArrowBoxDifficulty.ultraHard => UltraHardLevels.generateOutcome(
    level,
    excludedLayouts: excludedLayouts,
    stats: stats,
    maxAttempts: maxAttempts,
    maxNodesPerAttempt: maxNodes,
  ),
};

bool _enrichLegacySuccess(
  Map<String, Object?> result,
  int level,
  ArrowBoxDifficulty difficulty,
  CatalogCheckpoint checkpoint,
) {
  if (result['status'] != 'SUCCESS' || result['level'] != level ||
      result['difficulty'] != difficulty.name || result['layout'] is! String) {
    return false;
  }
  final board = _parseLayout(result['layout'] as String);
  if (board == null || checkpoint.results.values.any(
      (other) => other['level'] != level && other['layout'] == result['layout'])) {
    return false;
  }
  final metrics = LevelSolver.analyze(board);
  if (metrics == null || !metrics.solvable ||
      !_matchesProfile(board, metrics, level, difficulty) ||
      !_replays(board, metrics.solution)) {
    return false;
  }
  result.addAll({
    'solverSolvable': true,
    'replayVerified': true,
    'initialChoices': metrics.initialChoices,
    'dependencyDepth': metrics.dependencyDepth,
    'forcedMoveRatio': metrics.forcedMoveRatio,
    'directionCounts': metrics.directionCounts,
  });
  return true;
}

bool _isReusableSuccess(
  Map<String, Object?> result,
  int level,
  ArrowBoxDifficulty difficulty,
  CatalogCheckpoint checkpoint,
) {
  if (result['status'] != 'SUCCESS' || result['level'] != level ||
      result['difficulty'] != difficulty.name || result['layout'] is! String ||
      result['initialChoices'] is! int || result['dependencyDepth'] is! int ||
      result['forcedMoveRatio'] is! num || result['directionCounts'] is! List ||
      result['solverSolvable'] != true || result['replayVerified'] != true) {
    return false;
  }
  final layout = result['layout'] as String;
  final board = _parseLayout(layout);
  if (board == null || checkpoint.results.values.any(
      (other) => other['level'] != level && other['layout'] == layout)) {
    return false;
  }
  final metrics = LevelSolver.analyze(board);
  if (metrics == null || !metrics.solvable ||
      !_matchesProfile(board, metrics, level, difficulty) ||
      metrics.initialChoices != result['initialChoices'] ||
      metrics.dependencyDepth != result['dependencyDepth'] ||
      (metrics.forcedMoveRatio - (result['forcedMoveRatio'] as num).toDouble()).abs() > 0.000001 ||
      metrics.directionCounts.join(',') != (result['directionCounts'] as List).join(',')) {
    return false;
  }
  return _replays(board, metrics.solution);
}

bool _matchesProfile(
  List<ArrowDirection?> board,
  LevelSolutionMetrics metrics,
  int level,
  ArrowBoxDifficulty difficulty,
) {
  final occupied = board.whereType<ArrowDirection>().length;
  final minimumInitialChoices = difficulty == ArrowBoxDifficulty.easy && level <= 10
      ? 2
      : 1;
  final maximumInitialChoices = switch (difficulty) {
    ArrowBoxDifficulty.easy => level <= 10 ? 12 : 8,
    ArrowBoxDifficulty.medium => 6,
    ArrowBoxDifficulty.hard => 6,
    ArrowBoxDifficulty.ultraHard => 8,
  };
  final minimumDepth = switch (difficulty) {
    ArrowBoxDifficulty.easy => level <= 3 ? 0 : level <= 10 ? 1 : 2,
    ArrowBoxDifficulty.medium => level <= 130 ? 2 : 3,
    ArrowBoxDifficulty.hard || ArrowBoxDifficulty.ultraHard => 3,
  };
  final minimumDirections = difficulty == ArrowBoxDifficulty.easy && level <= 3 ? 1 :
      difficulty == ArrowBoxDifficulty.easy ? 2 :
      difficulty == ArrowBoxDifficulty.medium ? 2 : 3;
  final minimumForcedRatio = difficulty == ArrowBoxDifficulty.easy ? 0 : 0.05;
  final minimumArrows = switch (difficulty) {
    ArrowBoxDifficulty.easy => level == 1 ? 8 :
        level <= 10 ? 8 + ((level - 1) * 4 ~/ 9) :
        level <= 30 ? 10 + ((level - 11) * 5 ~/ 19) :
        level <= 60 ? 12 + ((level - 31) * 6 ~/ 29) : 14 + ((level - 61) * 6 ~/ 39),
    ArrowBoxDifficulty.medium => 16 + ((level - 101) * 7 ~/ 99),
    ArrowBoxDifficulty.hard => 20 + ((level - 201) % 6),
    ArrowBoxDifficulty.ultraHard => 25,
  };
  return occupied == minimumArrows &&
      metrics.initialChoices >= minimumInitialChoices &&
      metrics.initialChoices <= maximumInitialChoices &&
      metrics.dependencyDepth >= minimumDepth &&
      metrics.minimumDirectionCount >= minimumDirections &&
      metrics.forcedMoveRatio >= minimumForcedRatio;
}

List<ArrowDirection?>? _parseLayout(String layout) {
  final values = layout.split(',');
  if (values.length != 25) return null;
  final board = <ArrowDirection?>[];
  for (final value in values) {
    final index = int.tryParse(value);
    if (index == null || index < -1 || index >= ArrowDirection.values.length) {
      return null;
    }
    board.add(index == -1 ? null : ArrowDirection.values[index]);
  }
  return board;
}

bool _replays(List<ArrowDirection?> board, List<int> solution) {
  final current = List<ArrowDirection?>.of(board);
  for (final index in solution) {
    if (!arrowCanEscape(current, index)) return false;
    current[index] = null;
  }
  return current.every((arrow) => arrow == null);
}

String _validateOutcome(
  BoardGenerationResult outcome,
  ArrowBoxDifficulty difficulty,
  int level,
  CatalogCheckpoint checkpoint,
) {
  switch (outcome.status) {
    case BoardGenerationStatus.unsolvable:
      return 'UNSOLVABLE';
    case BoardGenerationStatus.budgetExhausted:
      return 'BUDGET_EXHAUSTED';
    case BoardGenerationStatus.invalidConfiguration:
      return 'INVALID_CONFIGURATION';
    case BoardGenerationStatus.success:
      final board = outcome.board!;
      if (board.length != 25) return 'INVALID_CONFIGURATION';
      final metrics = LevelSolver.analyze(board);
      if (metrics == null || !metrics.solvable) return 'BUDGET_EXHAUSTED';
      final replay = List<ArrowDirection?>.of(board);
      for (final index in metrics.solution) {
        if (!arrowCanEscape(replay, index)) return 'INVALID_CONFIGURATION';
        replay[index] = null;
      }
      if (replay.any((arrow) => arrow != null)) return 'INVALID_CONFIGURATION';
      final key = board.map((arrow) => arrow?.index ?? -1).join(',');
      final duplicate = checkpoint.results.values.any(
        (result) => result['layout'] == key && result['level'] != level,
      );
      if (duplicate) return 'INVALID_CONFIGURATION';
      return 'SUCCESS';
  }
}

ArrowBoxDifficulty _difficultyFor(int level) {
  if (level <= 100) return ArrowBoxDifficulty.easy;
  if (level <= 200) return ArrowBoxDifficulty.medium;
  if (level <= 350) return ArrowBoxDifficulty.hard;
  return ArrowBoxDifficulty.ultraHard;
}

class _Options {
  _Options({
    required this.start,
    required this.end,
    required this.checkpoint,
    required this.maxAttempts,
    required this.maxNodes,
  });

  final int start;
  final int end;
  final String checkpoint;
  final int maxAttempts;
  final int maxNodes;

  static _Options parse(List<String> args) {
    String text(String name, String fallback) {
      final prefix = '--$name=';
      for (final arg in args) {
        if (arg.startsWith(prefix)) return arg.substring(prefix.length);
      }
      return fallback;
    }

    int number(String name, int fallback) =>
        int.tryParse(text(name, '$fallback')) ?? fallback;

    final start = number('start', 1);
    final end = number('end', ArrowBoxLevel.count);
    if (start < 1 || end < start || end > ArrowBoxLevel.count) {
      throw ArgumentError('Invalid validation range');
    }
    return _Options(
      start: start,
      end: end,
      checkpoint: text('checkpoint', 'tool/arrowbox_catalog_checkpoint.json'),
      maxAttempts: number('maxAttempts', 10000),
      maxNodes: number('maxNodes', 50000),
    );
  }
}
