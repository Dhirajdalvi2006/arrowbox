import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../arrow_designs/arrow_designs.dart';
import '../../../core/services/reward_service.dart';

/// Full rewards & unlocks section replacing the old placeholder.
///
/// Displays:
/// - Section header "REWARDS & UNLOCKS"
/// - Summary cards for arrow skins and board themes
/// - Reward collection grid with lock/unlock/equipped states
/// - Next milestone card with progress bar
class MilestoneRewardsCard extends StatelessWidget {
  const MilestoneRewardsCard({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final completedCount = store.completedLevels.length;
    final skinsEarned = RewardService.calculateArrowSkinsEarned(completedCount);
    final themesEarned = RewardService.calculateBoardThemesEarned(
      completedCount,
    );
    final next = RewardService.nextMilestone(completedCount);
    final progress = RewardService.progressToNextMilestone(completedCount);
    final remaining = RewardService.remainingLevelsToNextMilestone(
      completedCount,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.violet.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.violet,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'REWARDS & UNLOCKS',
                style: TextStyle(
                  color: AppColors.violet,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary cards row
          Row(
            children: [
              Expanded(
                child: _RewardSummaryCard(
                  icon: Icons.brightness_7_rounded,
                  iconColor: AppColors.cyan,
                  title: 'Arrow Skins',
                  unlocked: skinsEarned,
                  total: RewardService.totalArrowSkinMilestones,
                  equippedId: store.arrowSkinId,
                  category: RewardCategory.arrowSkin,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RewardSummaryCard(
                  icon: Icons.layers_rounded,
                  iconColor: AppColors.cyan,
                  title: 'Board Themes',
                  unlocked: themesEarned,
                  total: RewardService.totalBoardThemeMilestones,
                  equippedId: store.boardThemeId,
                  category: RewardCategory.boardTheme,
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Reward collection heading
          Text(
            'Reward Collection',
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // Build reward cards for all non-default milestones
          ..._buildRewardCards(context, completedCount),

          const SizedBox(height: 20),

          // Next milestone section
          if (next != null) ...[
            _buildNextMilestoneCard(
              context,
              next,
              progress,
              remaining,
              completedCount,
            ),
          ] else ...[
            _buildAllCompleteCard(context),
          ],
        ],
      ),
    );
  }

  /// Builds reward cards for all non-default milestones.
  List<Widget> _buildRewardCards(BuildContext context, int completedCount) {
    final rewards = RewardService.getAllRewards()
        .where((r) => !r.isDefault)
        .toList(growable: false);

    return List.generate(rewards.length, (index) {
      final reward = rewards[index];
      final unlocked = store.isRewardUnlocked(reward);
      final equipped = _isEquipped(reward);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _RewardCard(
          reward: reward,
          unlocked: unlocked,
          equipped: equipped,
          onTap: unlocked && !equipped ? () => _equipReward(reward) : null,
        ),
      );
    });
  }

  /// Checks whether a reward's cosmetic is currently equipped.
  bool _isEquipped(RewardDefinition reward) {
    if (reward.category == RewardCategory.arrowSkin) {
      return store.arrowSkinId == reward.rewardReference;
    } else {
      return store.boardThemeId == reward.rewardReference;
    }
  }

  /// Equips a reward's cosmetic.
  void _equipReward(RewardDefinition reward) {
    if (reward.category == RewardCategory.arrowSkin) {
      store.setArrowSkin(reward.rewardReference as ArrowSkinId);
    } else {
      store.setBoardTheme(reward.rewardReference as BoardThemeId);
    }
  }

  /// Builds the next milestone card with progress bar.
  Widget _buildNextMilestoneCard(
    BuildContext context,
    RewardDefinition next,
    double progress,
    int remaining,
    int completedCount,
  ) {
    final categoryLabel = next.category == RewardCategory.arrowSkin
        ? 'Arrow Skin'
        : 'Board Theme';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.violet.withValues(alpha: 0.30),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.violet.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: AppColors.violet,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'NEXT REWARD',
                  style: TextStyle(
                    color: AppColors.violet,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reward preview
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.violet.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.violet.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Center(child: _buildRewardPreview(next)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$categoryLabel — Milestone '
                          '${next.requiredCompletedLevels}',
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.violet.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Lv. ${next.requiredCompletedLevels}',
                            style: TextStyle(
                              color: AppColors.violet,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      next.name,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCount / ${next.requiredCompletedLevels} '
                      'levels completed',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$remaining more levels to unlock this reward.',
                      style: TextStyle(
                        color: AppColors.getTextMuted(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.getBorder(context),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryBright,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Level $completedCount',
                  style: TextStyle(
                    color: AppColors.getTextMuted(context),
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Level ${next.requiredCompletedLevels}',
                  style: TextStyle(
                    color: AppColors.getTextMuted(context),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the "all complete" card when all milestones are unlocked.
  Widget _buildAllCompleteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.30),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Milestones Complete',
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Every arrow skin and board theme has been unlocked.',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the preview icon for a reward (skin arrow or theme circle).
  Widget _buildRewardPreview(RewardDefinition reward) {
    if (reward.category == RewardCategory.arrowSkin) {
      final skinId = reward.rewardReference as ArrowSkinId;
      final skin = ArrowSkinRegistry.byId(skinId);
      return skin.buildArrow(direction: ArrowDirection.up, size: 28);
    } else {
      final themeId = reward.rewardReference as BoardThemeId;
      final theme = BoardThemeRegistry.byId(themeId);
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: theme.background,
          shape: BoxShape.circle,
          border: Border.all(color: theme.border, width: 2),
        ),
      );
    }
  }
}

/// Summary card showing unlock count for a reward category.
class _RewardSummaryCard extends StatelessWidget {
  const _RewardSummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.unlocked,
    required this.total,
    required this.equippedId,
    required this.category,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final int unlocked;
  final int total;
  final dynamic equippedId;
  final RewardCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSkin = category == RewardCategory.arrowSkin;
    final equippedName = isSkin
        ? _skinName(equippedId as ArrowSkinId)
        : _themeName(equippedId as BoardThemeId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Text(
                '$unlocked / $total',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Equipped: $equippedName',
            style: TextStyle(
              color: AppColors.getTextMuted(context),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyan,
                side: BorderSide(
                  color: AppColors.cyan.withValues(alpha: 0.4),
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _skinName(ArrowSkinId id) {
    switch (id) {
      case ArrowSkinId.classic:
        return 'Classic';
      case ArrowSkinId.neon:
        return 'Neon';
      case ArrowSkinId.glass:
        return 'Glass';
      case ArrowSkinId.minimal:
        return 'Minimal';
      case ArrowSkinId.bold:
        return 'Bold';
      case ArrowSkinId.pastel:
        return 'Pastel';
      case ArrowSkinId.tech:
        return 'Tech';
      case ArrowSkinId.fantasy:
        return 'Fantasy';
      case ArrowSkinId.cyber:
        return 'Cyber';
      case ArrowSkinId.voidStyle:
        return 'Void';
      case ArrowSkinId.aurora:
        return 'Aurora';
    }
  }

  String _themeName(BoardThemeId id) {
    switch (id) {
      case BoardThemeId.midnight:
        return 'Midnight';
      case BoardThemeId.deepOcean:
        return 'Deep Ocean';
      case BoardThemeId.aurora:
        return 'Aurora';
      case BoardThemeId.graphite:
        return 'Graphite';
      case BoardThemeId.midnightNebula:
        return 'Midnight Nebula';
      case BoardThemeId.deepOceanAbyss:
        return 'Deep Ocean Abyss';
      case BoardThemeId.solarFlare:
        return 'Solar Flare';
      case BoardThemeId.neonVoid:
        return 'Neon Void';
    }
  }
}

/// Individual reward card showing lock/unlock/equipped state.
class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.unlocked,
    required this.equipped,
    required this.onTap,
  });

  final RewardDefinition reward;
  final bool unlocked;
  final bool equipped;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final categoryLabel = reward.category == RewardCategory.arrowSkin
        ? 'Arrow Skin'
        : 'Board Theme';
    final statusColor = equipped
        ? AppColors.success
        : unlocked
        ? AppColors.cyan
        : AppColors.getTextMuted(context);
    final statusText = equipped
        ? 'Equipped'
        : unlocked
        ? 'Unlocked'
        : 'Lock at Lv. ${reward.requiredCompletedLevels}';

    return Container(
      decoration: BoxDecoration(
        color: equipped
            ? AppColors.success.withValues(alpha: 0.10)
            : unlocked
            ? AppColors.cyan.withValues(alpha: 0.08)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: equipped
              ? AppColors.success.withValues(alpha: 0.50)
              : unlocked
              ? AppColors.cyan.withValues(alpha: 0.40)
              : AppColors.getBorder(context),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Preview icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? null
                        : AppColors.getTextMuted(context)
                              .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: unlocked
                        ? Border.all(
                            color: statusColor.withValues(alpha: 0.4),
                            width: 1.2,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: unlocked ? 1.0 : 0.5,
                      child: _buildRewardPreview(reward),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reward.name,
                              style: TextStyle(
                                color: unlocked
                                    ? AppColors.getTextPrimary(context)
                                    : AppColors.getTextMuted(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryLabel,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lv. ${reward.requiredCompletedLevels}',
                        style: TextStyle(
                          color: AppColors.getTextMuted(context),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unlocked && !equipped && onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.play_circle_rounded,
                    color: AppColors.cyan,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardPreview(RewardDefinition reward) {
    if (reward.category == RewardCategory.arrowSkin) {
      final skinId = reward.rewardReference as ArrowSkinId;
      final skin = ArrowSkinRegistry.byId(skinId);
      return skin.buildArrow(direction: ArrowDirection.up, size: 24);
    } else {
      final themeId = reward.rewardReference as BoardThemeId;
      final theme = BoardThemeRegistry.byId(themeId);
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: theme.background,
          shape: BoxShape.circle,
          border: Border.all(color: theme.border, width: 1.5),
        ),
      );
    }
  }
}

/// Extension on AppStore to check reward unlock state.
extension AppStoreRewardExtension on AppStore {
  /// Whether a reward's cosmetic is unlocked.
  bool isRewardUnlocked(RewardDefinition reward) {
    if (reward.category == RewardCategory.arrowSkin) {
      return isArrowSkinUnlocked(reward.rewardReference as ArrowSkinId);
    } else {
      return isBoardThemeUnlocked(reward.rewardReference as BoardThemeId);
    }
  }
}
