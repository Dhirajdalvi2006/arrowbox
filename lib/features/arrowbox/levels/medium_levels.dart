import '../arrowbox_logic.dart';
import 'board_generator.dart';

class MediumLevels {
  static List<ArrowDirection?> generate(
    int level, {
    Set<String> excludedLayouts = const {},
    BoardGenerationStats? stats,
  }) {
    final arrowCount = 16 + ((level - 101) * 7 ~/ 99);
    return generateSolvableBoard(
      arrowCount: arrowCount,
      seed: level * 7919 + 101,
      minimumInitialChoices: level <= 130 ? 2 : 1,
      maximumInitialChoices: 6,
      minimumDependencyDepth: level <= 130 ? 2 : 3,
      minimumDirectionCount: 2,
      minimumForcedMoveRatio: 0.05,
      excludedLayouts: excludedLayouts,
      stats: stats,
    );
  }
}
