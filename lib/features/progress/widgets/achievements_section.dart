import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';

/// Personal bests and achievements derived from actual application data.
class AchievementsSection extends StatelessWidget {
  const AchievementsSection({required this.store, super.key});

  final AppStore store;

  /// Longest consecutive run of completed levels starting from level 1.
  int _computeBestStreak() {
    final completed = store.completedLevels;
    int streak = 0;
    int best = 0;
    for (var i = 1; i <= AppStore.totalLevels; i++) {
      if (completed.contains(i)) {
        streak++;
        if (streak > best) best = streak;
      } else {
        streak = 0;
      }
    }
    return best;
  }

  /// Count of levels completed with a perfect 3-star rating.
  int _computePerfectClears() {
    return store.levelStars.values.where((stars) => stars == 3).length;
  }

  @override
  Widget build(BuildContext context) {
    final bestStreak = _computeBestStreak();
    final perfectClears = _computePerfectClears();
    final completedCount = store.completedLevels.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(width: 4, height: 16, color: AppColors.violet),
              const SizedBox(width: 10),
              Text(
                'PERSONAL BESTS',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AchievementCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.success,
                title: 'Best Streak',
                value: '$bestStreak',
                subtitle: 'levels',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AchievementCard(
                icon: Icons.star_rounded,
                iconColor: AppColors.starGold,
                title: 'Perfect Clears',
                value: '$perfectClears',
                subtitle: 'levels',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AchievementCard(
                icon: Icons.emoji_events_rounded,
                iconColor: AppColors.violet,
                title: 'Total Completed',
                value: '$completedCount',
                subtitle: 'levels',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Single achievement metric card.
class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.getTextMuted(context),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
