import 'dart:math';

import '../arrowbox_logic.dart';
import 'arrow_board_rules.dart';
import 'level_solver.dart';

class BoardGenerationStats {
  int attempts = 0;
  int nodesExpanded = 0;
  int backtracks = 0;
  int candidatesExamined = 0;
  int solverInvocations = 0;
  int duplicateRejections = 0;
  int constraintRejections = 0;
  int initialChoiceRejections = 0;
  int solverInconclusive = 0;
  int replayRejections = 0;
  int dependencyRejections = 0;
  int forcedRatioRejections = 0;
  int directionRejections = 0;
  int maxDepth = 0;
  int elapsedMilliseconds = 0;
}

List<ArrowDirection?> generateSolvableBoard({
  required int arrowCount,
  required int seed,
  required int minimumInitialChoices,
  required int maximumInitialChoices,
  required int minimumDependencyDepth,
  int minimumDirectionCount = 0,
  double minimumForcedMoveRatio = 0,
  Set<String> excludedLayouts = const {},
  BoardGenerationStats? stats,
  int maxAttempts = 10000,
  int maxNodesPerAttempt = 50000,
}) {
  final stopwatch = Stopwatch()..start();
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    stats?.attempts++;
    final rng = Random(seed + attempt);
    final board = List<ArrowDirection?>.filled(25, null);
    final directionCounts = List<int>.filled(ArrowDirection.values.length, 0);
    final failedStates = <String>{};
    var nodes = 0;

    bool build(int placed) {
      final stateKey = board.map((arrow) => arrow?.index ?? -1).join(',');
      if (failedStates.contains(stateKey)) return false;
      if (stats != null) stats.maxDepth = max(stats.maxDepth, placed);
      if (placed == arrowCount) {
        final layoutKey = stateKey;
        if (excludedLayouts.contains(layoutKey)) {
          stats?.duplicateRejections++;
          return false;
        }
        final initialChoices = _escapeCount(board);
        if (initialChoices < minimumInitialChoices ||
            initialChoices > maximumInitialChoices) {
          stats?.initialChoiceRejections++;
          return false;
        }
        stats?.solverInvocations++;
        final metrics = LevelSolver.analyze(board);
        if (metrics == null) {
          stats?.solverInconclusive++;
          return false;
        }
        if (!_replaysSolution(board, metrics.solution)) {
          stats?.replayRejections++;
          return false;
        }
        if (metrics.dependencyDepth < minimumDependencyDepth) {
          stats?.dependencyRejections++;
          return false;
        }
        if (metrics.minimumDirectionCount < minimumDirectionCount) {
          stats?.directionRejections++;
          return false;
        }
        if (metrics.forcedMoveRatio < minimumForcedMoveRatio) {
          stats?.forcedRatioRejections++;
          return false;
        }
        return true;
      }
      if (++nodes > maxNodesPerAttempt) return false;
      stats?.nodesExpanded++;
      final remaining = arrowCount - placed;
      final missingDirections = directionCounts
          .where((count) => count < minimumDirectionCount)
          .length;
      if (missingDirections > remaining) return false;

      final choices = <(int, ArrowDirection)>[];
      for (var index = 0; index < 25; index++) {
        if (board[index] != null) continue;
        for (final direction in ArrowDirection.values) {
          board[index] = direction;
          if (arrowCanEscape(board, index)) {
            choices.add((index, direction));
          }
        }
        board[index] = null;
      }
      if (choices.isEmpty) {
        failedStates.add(stateKey);
        return false;
      }
      if (minimumDirectionCount > 0) {
        for (final direction in ArrowDirection.values) {
          final available = choices
              .where((choice) => choice.$2 == direction)
              .length;
          if (directionCounts[direction.index] + available <
              minimumDirectionCount) {
            failedStates.add(stateKey);
            return false;
          }
        }
      }

      final ranked = <(int, ArrowDirection, int)>[];
      for (final choice in choices) {
        board[choice.$1] = choice.$2;
        var blocked = 0;
        for (var index = 0; index < 25; index++) {
          if (index != choice.$1 && board[index] != null &&
              !arrowCanEscape(board, index)) {
            blocked++;
          }
        }
        final directionNeed =
            directionCounts[choice.$2.index] < minimumDirectionCount ? 1 : 0;
        ranked.add((choice.$1, choice.$2, blocked * 10 + directionNeed));
        board[choice.$1] = null;
      }
      ranked.shuffle(rng);
      ranked.sort((a, b) => b.$3.compareTo(a.$3));
      final branchCount = min(4, ranked.length);
      for (var branch = 0; branch < branchCount; branch++) {
        final choice = ranked[branch];
        stats?.candidatesExamined++;
        board[choice.$1] = choice.$2;
        directionCounts[choice.$2.index]++;
        if (build(placed + 1)) return true;
        stats?.backtracks++;
        directionCounts[choice.$2.index]--;
        board[choice.$1] = null;
      }
      failedStates.add(stateKey);
      return false;
    }

    if (build(0)) {
      if (stats != null) stats.elapsedMilliseconds = stopwatch.elapsedMilliseconds;
      return List.unmodifiable(board);
    }
  }
  if (stats != null) stats.elapsedMilliseconds = stopwatch.elapsedMilliseconds;
  throw StateError('Unable to generate solvable board for seed $seed');
}

int _escapeCount(List<ArrowDirection?> board) => [
      for (var index = 0; index < board.length; index++)
        if (arrowCanEscape(board, index)) index,
    ].length;

bool _replaysSolution(List<ArrowDirection?> board, List<int> solution) {
  final current = List<ArrowDirection?>.of(board);
  for (final index in solution) {
    if (!arrowCanEscape(current, index)) return false;
    current[index] = null;
  }
  return current.every((arrow) => arrow == null);
}
