import '../arrowbox_logic.dart';
import 'board_generator.dart';

class UltraHardLevels {
  static BoardGenerationResult generateOutcome(
    int level, {
    Set<String> excludedLayouts = const {},
    BoardGenerationStats? stats,
    int maxAttempts = 10000,
    int maxNodesPerAttempt = 50000,
  }) => generateSolvableBoardOutcome(
    arrowCount: 25,
    seed: level * 7919 + 307,
    minimumInitialChoices: 1,
    maximumInitialChoices: 8,
    minimumDependencyDepth: 3,
    minimumDirectionCount: 3,
    minimumForcedMoveRatio: 0.05,
    excludedLayouts: excludedLayouts,
    stats: stats,
    maxAttempts: maxAttempts,
    maxNodesPerAttempt: maxNodesPerAttempt,
    level: level,
    difficulty: ArrowBoxDifficulty.ultraHard.name,
  );

  static List<ArrowDirection?> generate(
    int level, {
    Set<String> excludedLayouts = const {},
    BoardGenerationStats? stats,
  }) => generateSolvableBoard(
    arrowCount: 25,
    seed: level * 7919 + 307,
    minimumInitialChoices: 1,
    maximumInitialChoices: 8,
    minimumDependencyDepth: 3,
    minimumDirectionCount: 3,
    minimumForcedMoveRatio: 0.05,
    excludedLayouts: excludedLayouts,
    stats: stats,
  );
}
