import 'dart:math';

import '../arrowbox_logic.dart';
import 'arrow_board_rules.dart';

class LevelSolutionMetrics {
  const LevelSolutionMetrics({
    required this.solvable,
    required this.initialChoices,
    required this.minimumChoices,
    required this.dependencyDepth,
    required this.forcedMoveRatio,
    required this.directionCounts,
    required this.solution,
  });

  final bool solvable;
  final int initialChoices;
  final int minimumChoices;
  final int dependencyDepth;
  final double forcedMoveRatio;
  final List<int> directionCounts;
  final List<int> solution;

  int get directionKinds => directionCounts.where((count) => count > 0).length;
  int get minimumDirectionCount => directionCounts.reduce(min);
}

class LevelSolver {
  static final Map<String, LevelSolutionMetrics?> _cache = {};

  static LevelSolutionMetrics? analyze(List<ArrowDirection?> board) {
    final key = board.map((arrow) => arrow?.index ?? -1).join(',');
    return _cache.putIfAbsent(key, () => _analyze(board));
  }

  static bool isSolvable(List<ArrowDirection?> board) =>
      analyze(board)?.solvable ?? false;

  static LevelSolutionMetrics? _analyze(List<ArrowDirection?> board) {
    if (board.length != 25) return null;
    final initialChoices = _choices(board).length;
    final visited = <String>{};
    var dependencyDepth = 0;
    var forcedMoves = 0;
    var solvedMoves = 0;
    List<int>? solution;

    bool search(List<ArrowDirection?> current, int forcedStreak, int depth) {
      if (current.every((arrow) => arrow == null)) {
        solution = <int>[];
        return true;
      }
      final key = current.map((arrow) => arrow?.index ?? -1).join(',');
      if (!visited.add(key)) return false;
      final choices = _choices(current);
      if (choices.isEmpty) return false;
      final nextStreak = choices.length == 1 ? forcedStreak + 1 : 0;
      dependencyDepth = max(dependencyDepth, nextStreak);
      if (choices.length == 1) forcedMoves++;
      solvedMoves++;
      for (final index in choices) {
        final next = List<ArrowDirection?>.of(current)..[index] = null;
        if (search(next, nextStreak, depth + 1)) {
          solution = [index, ...?solution];
          return true;
        }
      }
      return false;
    }

    if (!search(List<ArrowDirection?>.of(board), 0, 0)) return null;
    final directionCounts = List<int>.filled(ArrowDirection.values.length, 0);
    for (final arrow in board) {
      if (arrow != null) directionCounts[arrow.index]++;
    }
    return LevelSolutionMetrics(
      solvable: true,
      initialChoices: initialChoices,
      minimumChoices: board.whereType<ArrowDirection>().length,
      dependencyDepth: dependencyDepth,
      forcedMoveRatio: solvedMoves == 0 ? 0 : forcedMoves / solvedMoves,
      directionCounts: List.unmodifiable(directionCounts),
      solution: List.unmodifiable(solution!),
    );
  }

  static int max(int a, int b) => a > b ? a : b;

  static List<int> _choices(List<ArrowDirection?> board) => [
    for (var index = 0; index < board.length; index++)
      if (arrowCanEscape(board, index)) index,
  ];
}
