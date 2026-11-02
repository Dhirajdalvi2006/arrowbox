import 'package:locate/features/arrow_designs/arrow_designs.dart';

/// Category of a milestone reward.
enum RewardCategory {
  /// An arrow skin unlocked at a level milestone.
  arrowSkin,

  /// A board theme unlocked at a level milestone.
  boardTheme,
}

/// A definition of a single milestone reward.
///
/// [rewardReference] holds either an [ArrowSkinId] or a [BoardThemeId],
/// selected by [category].
class RewardDefinition {
  /// Creates a [RewardDefinition].
  const RewardDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.requiredCompletedLevels,
    required this.rewardReference,
    required this.description,
    required this.isDefault,
  });

  /// Stable unique identifier used to persist unlock state.
  final String id;

  /// Display name shown in the UI.
  final String name;

  /// Whether this reward is an arrow skin or board theme.
  final RewardCategory category;

  /// Number of completed levels required to unlock this reward.
  final int requiredCompletedLevels;

  /// Reference to the unlocked item — an [ArrowSkinId] or [BoardThemeId].
  final dynamic rewardReference;
  final String description;

  /// Whether this reward is the default (always unlocked).
  final bool isDefault;

  /// Whether this reward is already unlocked at [completedLevels].
  bool isUnlocked(int completedLevels) =>
      isDefault || requiredCompletedLevels <= completedLevels;
}

/// Centralized reward calculation service for the ArrowBox game.
///
/// Defines milestone rewards (arrow skins and board themes) that players
/// unlock as they complete levels, and provides pure, deterministic methods
/// for querying unlock state and progress toward the next milestone.
///
/// All calculations depend only on the supplied `completedLevels` value, so
/// results are idempotent and independent of widget build order. This is a
/// calculation/service class, not a [ChangeNotifier].
class RewardService {
  RewardService._();

  /// Interval (in completed levels) at which arrow skins are awarded.
  static const int _skinMilestoneInterval = 50;

  /// Maximum number of arrow skins that can be earned.
  static const int _maxArrowSkins = 10;

  /// Interval (in completed levels) at which board themes are awarded.
  static const int _boardThemeMilestoneInterval = 100;

  /// Maximum number of board themes that can be earned.
  static const int _maxBoardThemes = 5;

  /// All milestone rewards, ordered by unlock level then category.
  static const List<RewardDefinition> _allRewards = <RewardDefinition>[
    // Default rewards — always unlocked at level 0.
    RewardDefinition(
      id: 'reward_skin_classic',
      name: 'Classic',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 0,
      rewardReference: ArrowSkinId.classic,
      description: 'The original arrow skin.',
      isDefault: true,
    ),
    RewardDefinition(
      id: 'reward_theme_midnight',
      name: 'Midnight',
      category: RewardCategory.boardTheme,
      requiredCompletedLevels: 0,
      rewardReference: BoardThemeId.midnight,
      description: 'The original deep navy board.',
      isDefault: true,
    ),
    // Arrow skins — one every 50 completed levels (50 to 500).
    RewardDefinition(
      id: 'reward_skin_neon',
      name: 'Neon',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 50,
      rewardReference: ArrowSkinId.neon,
      description: 'A vibrant neon arrow.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_skin_glass',
      name: 'Glass',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 100,
      rewardReference: ArrowSkinId.glass,
      description: 'A translucent glass arrow.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_skin_minimal',
      name: 'Minimal',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 150,
      rewardReference: ArrowSkinId.minimal,
      description: 'Clean and understated.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_skin_bold',
      name: 'Bold',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 200,
      rewardReference: ArrowSkinId.bold,
      description: 'Strong, high-contrast lines.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_skin_pastel',
      name: 'Pastel',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 250,
      rewardReference: ArrowSkinId.pastel,
      description: 'Soft, muted colors.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_skin_tech',
      name: 'Tech',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 300,
      rewardReference: ArrowSkinId.tech,
      description: 'A futuristic circuitry look.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_skin_fantasy',
      name: 'Fantasy',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 350,
      rewardReference: ArrowSkinId.fantasy,
      description: 'A mystical, enchanted style.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_skin_cyber',
      name: 'Cyber',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 400,
      rewardReference: ArrowSkinId.cyber,
      description: 'Cyberpunk-inspired aesthetics.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_skin_void_style',
      name: 'Void',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 450,
      rewardReference: ArrowSkinId.voidStyle,
      description: 'Deep, empty darkness.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_skin_aurora',
      name: 'Aurora',
      category: RewardCategory.arrowSkin,
      requiredCompletedLevels: 500,
      rewardReference: ArrowSkinId.aurora,
      description: 'Shifting northern lights.',
      isDefault: false,
    ),
    // Board themes — one every 100 completed levels (100 to 500).
    RewardDefinition(
      id: 'reward_theme_deep_ocean',
      name: 'Deep Ocean',
      category: RewardCategory.boardTheme,
      requiredCompletedLevels: 100,
      rewardReference: BoardThemeId.deepOcean,
      description: 'Cool blue depth with crisp edges.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_theme_aurora',
      name: 'Aurora',
      category: RewardCategory.boardTheme,
      requiredCompletedLevels: 200,
      rewardReference: BoardThemeId.aurora,
      description: 'A quiet teal board with luminous accents.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_theme_graphite',
      name: 'Graphite',
      category: RewardCategory.boardTheme,
      requiredCompletedLevels: 300,
      rewardReference: BoardThemeId.graphite,
      description: 'A neutral slate surface for focused play.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_theme_midnight_nebula',
      name: 'Midnight Nebula',
      category: RewardCategory.boardTheme,
      requiredCompletedLevels: 400,
      rewardReference: BoardThemeId.midnightNebula,
      description: 'Deep space navy with stardust accents.',
      isDefault: false,
    ),
    RewardDefinition(
      id: 'reward_theme_deep_ocean_abyss',
      name: 'Deep Ocean Abyss',
      category: RewardCategory.boardTheme,
      requiredCompletedLevels: 500,
      rewardReference: BoardThemeId.deepOceanAbyss,
      description: 'Abyssal midnight with bioluminescent edges.',
      isDefault: false,
    ),
  ];

  /// Number of arrow skins earned at [completedLevels].
  ///
  /// Computed as `floor(completedLevels / 50)`, clamped to the range `0..10`.
  static int calculateArrowSkinsEarned(int completedLevels) {
    final earned = (completedLevels / _skinMilestoneInterval).floor();
    return earned.clamp(0, _maxArrowSkins);
  }

  /// Number of board themes earned at [completedLevels].
  ///
  /// Computed as `floor(completedLevels / 100)`, clamped to the range `0..5`.
  static int calculateBoardThemesEarned(int completedLevels) {
    final earned = (completedLevels / _boardThemeMilestoneInterval).floor();
    return earned.clamp(0, _maxBoardThemes);
  }

  /// Total number of additional arrow skin milestones (excluding default).
  static int get totalArrowSkinMilestones => _maxArrowSkins;

  /// Total number of additional board theme milestones (excluding default).
  static int get totalBoardThemeMilestones => _maxBoardThemes;

  /// All arrow skin milestones, ordered by unlock level.
  static List<RewardDefinition> get arrowSkinMilestones => _allRewards
      .where((r) => r.category == RewardCategory.arrowSkin && !r.isDefault)
      .toList(growable: false);

  /// All board theme milestones, ordered by unlock level.
  static List<RewardDefinition> get boardThemeMilestones => _allRewards
      .where((r) => r.category == RewardCategory.boardTheme && !r.isDefault)
      .toList(growable: false);

  /// All milestone rewards (including defaults), ordered by unlock level.
  static List<RewardDefinition> getAllRewards() =>
      List<RewardDefinition>.unmodifiable(_allRewards);

  /// Rewards unlocked at [completedLevels], including defaults.
  static List<RewardDefinition> getUnlockedRewards(int completedLevels) {
    return _allRewards
        .where((reward) => reward.isUnlocked(completedLevels))
        .toList(growable: false);
  }

  /// Whether the arrow skin [skinId] is unlocked at [completedLevels].
  static bool isSkinUnlocked(ArrowSkinId skinId, int completedLevels) {
    if (skinId == ArrowSkinId.classic) {
      return true;
    }
    return _allRewards.any((reward) {
      return reward.category == RewardCategory.arrowSkin &&
          reward.rewardReference == skinId &&
          reward.isUnlocked(completedLevels);
    });
  }

  /// Whether the board theme [themeId] is unlocked at [completedLevels].
  static bool isThemeUnlocked(BoardThemeId themeId, int completedLevels) {
    if (themeId == BoardThemeId.midnight) {
      return true;
    }
    return _allRewards.any((reward) {
      return reward.category == RewardCategory.boardTheme &&
          reward.rewardReference == themeId &&
          reward.isUnlocked(completedLevels);
    });
  }

  /// The next unreached milestone above [completedLevels], or `null` if none.
  static RewardDefinition? nextMilestone(int completedLevels) {
    RewardDefinition? best;
    for (final reward in _allRewards) {
      if (reward.isDefault ||
          reward.requiredCompletedLevels <= completedLevels) {
        continue;
      }
      if (best == null ||
          reward.requiredCompletedLevels < best.requiredCompletedLevels) {
        best = reward;
      }
    }
    return best;
  }

  /// Progress toward the next milestone, from `0.0` to `1.0`.
  ///
  /// Returns `1.0` when there is no next milestone.
  static double progressToNextMilestone(int completedLevels) {
    final next = nextMilestone(completedLevels);
    if (next == null) {
      return 1.0;
    }
    final previous = _previousMilestoneLevel(completedLevels);
    final range = next.requiredCompletedLevels - previous;
    if (range <= 0) {
      return 1.0;
    }
    return ((completedLevels - previous) / range).clamp(0.0, 1.0);
  }

  /// Levels remaining until the next milestone.
  ///
  /// Returns `0` when there is no next milestone.
  static int remainingLevelsToNextMilestone(int completedLevels) {
    final next = nextMilestone(completedLevels);
    if (next == null) {
      return 0;
    }
    return next.requiredCompletedLevels - completedLevels;
  }

  /// Rewards that unlock exactly at [milestoneLevel].
  static List<RewardDefinition> getRewardsAtMilestone(int milestoneLevel) {
    return _allRewards
        .where(
          (reward) =>
              !reward.isDefault &&
              reward.requiredCompletedLevels == milestoneLevel,
        )
        .toList(growable: false);
  }

  /// The level of the most recent milestone at or below [completedLevels],
  /// or `0` if none.
  static int _previousMilestoneLevel(int completedLevels) {
    int previous = 0;
    for (final reward in _allRewards) {
      if (!reward.isDefault &&
          reward.requiredCompletedLevels <= completedLevels &&
          reward.requiredCompletedLevels > previous) {
        previous = reward.requiredCompletedLevels;
      }
    }
    return previous;
  }
}
