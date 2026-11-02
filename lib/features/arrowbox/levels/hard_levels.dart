import '../arrowbox_logic.dart';
import 'board_generator.dart';

class HardLevels {
  static BoardGenerationResult generateOutcome(
    int level, {
    Set<String> excludedLayouts = const {},
    BoardGenerationStats? stats,
    int maxAttempts = 10000,
    int maxNodesPerAttempt = 50000,
  }) => generateSolvableBoardOutcome(
    arrowCount: 20 + ((level - 201) % 6),
    seed: level * 7919 + 211,
    minimumInitialChoices: 1,
    maximumInitialChoices: 5,
    minimumDependencyDepth: 4,
    minimumDirectionCount: 4,
    minimumForcedMoveRatio: 0.1,
    excludedLayouts: excludedLayouts,
    stats: stats,
    maxAttempts: maxAttempts,
    maxNodesPerAttempt: maxNodesPerAttempt,
    level: level,
    difficulty: ArrowBoxDifficulty.hard.name,
  );

  static List<ArrowDirection?> generate(
    int level, {
    Set<String> excludedLayouts = const {},
    BoardGenerationStats? stats,
  }) => generateSolvableBoard(
    arrowCount: 20 + ((level - 201) % 6),
    seed: level * 7919 + 211,
    minimumInitialChoices: 1,
    maximumInitialChoices: 5,
    minimumDependencyDepth: 4,
    minimumDirectionCount: 4,
    minimumForcedMoveRatio: 0.1,
    excludedLayouts: excludedLayouts,
    stats: stats,
  );
}
