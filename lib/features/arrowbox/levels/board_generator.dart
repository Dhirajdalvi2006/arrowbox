import 'dart:math';

import '../arrowbox_logic.dart';
import 'arrow_board_rules.dart';
import 'level_solver.dart';

enum BoardGenerationStatus {
  success,
  unsolvable,
  budgetExhausted,
  invalidConfiguration,
}

class BoardGenerationResult {
  const BoardGenerationResult({
    required this.status,
    required this.board,
    required this.stats,
    required this.reason,
    this.level,
    this.difficulty,
  });

  final BoardGenerationStatus status;
  final List<ArrowDirection?>? board;
  final BoardGenerationStats stats;
  final String reason;
  final int? level;
  final String? difficulty;

  bool get isSuccess => status == BoardGenerationStatus.success;
}

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
  int solverCacheHits = 0;
  int solverCacheMisses = 0;
  int solverStatesVisited = 0;
  int solverRepeatedStates = 0;
  int solverChoiceScans = 0;
  int solverBoardCopies = 0;
  int solverElapsedMicroseconds = 0;
}

BoardGenerationResult generateSolvableBoardOutcome({
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
  int? level,
  String? difficulty,
}) {
  final resultStats = stats ?? BoardGenerationStats();
  if (arrowCount < 1 ||
      arrowCount > 25 ||
      minimumInitialChoices < 0 ||
      maximumInitialChoices < minimumInitialChoices ||
      minimumDependencyDepth < 0 ||
      minimumDirectionCount < 0 ||
      minimumDirectionCount > arrowCount ||
      minimumForcedMoveRatio < 0 ||
      minimumForcedMoveRatio > 1 ||
      maxAttempts < 1 ||
      maxNodesPerAttempt < 1) {
    return BoardGenerationResult(
      status: BoardGenerationStatus.invalidConfiguration,
      board: null,
      stats: resultStats,
      reason: 'Generation constraints or budgets are invalid',
      level: level,
      difficulty: difficulty,
    );
  }
  try {
    final board = generateSolvableBoard(
      arrowCount: arrowCount,
      seed: seed,
      minimumInitialChoices: minimumInitialChoices,
      maximumInitialChoices: maximumInitialChoices,
      minimumDependencyDepth: minimumDependencyDepth,
      minimumDirectionCount: minimumDirectionCount,
      minimumForcedMoveRatio: minimumForcedMoveRatio,
      excludedLayouts: excludedLayouts,
      stats: resultStats,
      maxAttempts: maxAttempts,
      maxNodesPerAttempt: maxNodesPerAttempt,
    );
    return BoardGenerationResult(
      status: BoardGenerationStatus.success,
      board: board,
      stats: resultStats,
      reason: 'Generated and verified successfully',
      level: level,
      difficulty: difficulty,
    );
  } on StateError catch (error) {
    return BoardGenerationResult(
      status: BoardGenerationStatus.budgetExhausted,
      board: null,
      stats: resultStats,
      reason: error.message,
      level: level,
      difficulty: difficulty,
    );
  }
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
        final solverDiagnostics = SolverDiagnostics();
        final metrics = LevelSolver.analyze(
          board,
          diagnostics: solverDiagnostics,
        );
        if (stats != null) {
          stats.solverCacheHits += solverDiagnostics.cacheHits;
          stats.solverCacheMisses += solverDiagnostics.cacheMisses;
          stats.solverStatesVisited += solverDiagnostics.statesVisited;
          stats.solverRepeatedStates += solverDiagnostics.repeatedStates;
          stats.solverChoiceScans += solverDiagnostics.choiceScans;
          stats.solverBoardCopies += solverDiagnostics.boardCopies;
          stats.solverElapsedMicroseconds +=
              solverDiagnostics.elapsedMicroseconds;
        }
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
          if (index != choice.$1 &&
              board[index] != null &&
              !arrowCanEscape(board, index)) {
            blocked++;
          }
        }
        final directionNeed =
            directionCounts[choice.$2.index] < minimumDirectionCount ? 1 : 0;
        final score = blocked * 10 + directionNeed;
        ranked.add((choice.$1, choice.$2, score));
        board[choice.$1] = null;
      }
      ranked.shuffle(Random(seed + attempt + placed));
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
      if (stats != null) {
        stats.elapsedMilliseconds = stopwatch.elapsedMilliseconds;
      }
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
