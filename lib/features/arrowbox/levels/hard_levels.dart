import '../arrowbox_logic.dart';
import 'board_generator.dart';

class HardLevels {
  static List<ArrowDirection?> generate(
    int level, {
    Set<String> excludedLayouts = const {},
    BoardGenerationStats? stats,
  }) => generateSolvableBoard(
        arrowCount: 20 + ((level - 201) % 6),
        seed: level * 7919 + 211,
        minimumInitialChoices: 1,
        maximumInitialChoices: 6,
        minimumDependencyDepth: 3,
        minimumDirectionCount: 3,
        minimumForcedMoveRatio: 0.05,
        excludedLayouts: excludedLayouts,
        stats: stats,
      );
}
