import '../arrowbox_logic.dart';
import 'easy_levels.dart';
import 'hard_levels.dart';
import 'level_solver.dart';
import 'medium_levels.dart';
import 'ultra_hard_levels.dart';

class LevelCatalog {
  static const size = 500;
  static final List<ArrowBoxLevel> levels = _build();

  static ArrowBoxDifficulty difficultyFor(int level) {
    if (level <= 100) return ArrowBoxDifficulty.easy;
    if (level <= 200) return ArrowBoxDifficulty.medium;
    if (level <= 350) return ArrowBoxDifficulty.hard;
    return ArrowBoxDifficulty.ultraHard;
  }

  static List<ArrowBoxLevel> _build() {
    final layouts = <String>{};
    final result = <ArrowBoxLevel>[];
    for (var level = 1; level <= size; level++) {
      final difficulty = difficultyFor(level);
      final board = switch (difficulty) {
        ArrowBoxDifficulty.easy => EasyLevels.generate(
            level,
            excludedLayouts: layouts,
          ),
        ArrowBoxDifficulty.medium => MediumLevels.generate(
            level,
            excludedLayouts: layouts,
          ),
        ArrowBoxDifficulty.hard => HardLevels.generate(
            level,
            excludedLayouts: layouts,
          ),
        ArrowBoxDifficulty.ultraHard => UltraHardLevels.generate(
            level,
            excludedLayouts: layouts,
          ),
      };
      final key = board.map((arrow) => arrow?.index ?? -1).join(',');
      if (!layouts.add(key)) {
        throw StateError('Duplicate layout generated for level $level');
      }
      final metrics = LevelSolver.analyze(board);
      if (metrics == null || !metrics.solvable) {
        throw StateError('Unsolvable layout generated for level $level');
      }
      result.add(ArrowBoxLevel(
        board,
        difficulty: difficulty,
        difficultyScore: _score(board, metrics),
      ));
    }
    return List.unmodifiable(result);
  }

  static double _score(
    List<ArrowDirection?> board,
    LevelSolutionMetrics metrics,
  ) {
    final density = board.whereType<ArrowDirection>().length / 25;
    final constraint = 1 - (metrics.initialChoices / 25);
    return (density * 0.45 + constraint * 0.35 +
            (metrics.dependencyDepth / 25).clamp(0.0, 1.0) * 0.20)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}
