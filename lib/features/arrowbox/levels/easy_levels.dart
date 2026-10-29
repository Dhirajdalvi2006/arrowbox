import '../arrowbox_logic.dart';
import 'board_generator.dart';

class EasyLevels {
  static BoardGenerationResult generateOutcome(
    int level, {
    Set<String> excludedLayouts = const {},
    BoardGenerationStats? stats,
    int maxAttempts = 10000,
    int maxNodesPerAttempt = 50000,
  }) {
    final arrowCount = level == 1
        ? 8
        : level <= 10
        ? 8 + ((level - 1) * 4 ~/ 9)
        : level <= 30
        ? 10 + ((level - 11) * 5 ~/ 19)
        : level <= 60
        ? 12 + ((level - 31) * 6 ~/ 29)
        : 14 + ((level - 61) * 6 ~/ 39);
    return generateSolvableBoardOutcome(
      arrowCount: arrowCount,
      seed: level * 7919 + 17,
      minimumInitialChoices: level <= 10 ? 2 : 1,
      maximumInitialChoices: level <= 10 ? 12 : 8,
      minimumDependencyDepth: level <= 3
          ? 0
          : level <= 10
          ? 1
          : 2,
      minimumDirectionCount: level <= 3 ? 1 : 2,
      excludedLayouts: excludedLayouts,
      stats: stats,
      maxAttempts: maxAttempts,
      maxNodesPerAttempt: maxNodesPerAttempt,
      level: level,
      difficulty: ArrowBoxDifficulty.easy.name,
    );
  }

  static List<ArrowDirection?> generate(
    int level, {
    Set<String> excludedLayouts = const {},
    BoardGenerationStats? stats,
  }) {
    final arrowCount = level == 1
        ? 8
        : level <= 10
        ? 8 + ((level - 1) * 4 ~/ 9)
        : level <= 30
        ? 10 + ((level - 11) * 5 ~/ 19)
        : level <= 60
        ? 12 + ((level - 31) * 6 ~/ 29)
        : 14 + ((level - 61) * 6 ~/ 39);
    return generateSolvableBoard(
      arrowCount: arrowCount,
      seed: level * 7919 + 17,
      minimumInitialChoices: level <= 10 ? 2 : 1,
      maximumInitialChoices: level <= 10 ? 12 : 8,
      minimumDependencyDepth: level <= 3
          ? 0
          : level <= 10
          ? 1
          : 2,
      minimumDirectionCount: level <= 3 ? 1 : 2,
      excludedLayouts: excludedLayouts,
      stats: stats,
    );
  }
}
