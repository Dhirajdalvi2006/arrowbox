import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import 'stat_card.dart';

/// Responsive grid of player statistic cards.
class PlayerStatsGrid extends StatelessWidget {
  const PlayerStatsGrid({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(width: 4, height: 16, color: AppColors.cyan),
              const SizedBox(width: 10),
              Text(
                'PLAYER STATS',
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
              child: StatCard(
                icon: Icons.grid_view_rounded,
                iconColor: AppColors.primaryBright,
                label: 'Total Levels',
                value: '${AppStore.totalLevels}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.play_circle_rounded,
                iconColor: AppColors.violet,
                label: 'Next Level',
                value: '${store.unlockedLevel}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.sports_esports_rounded,
                iconColor: AppColors.success,
                label: 'Games Played',
                value: '${store.gamesPlayed}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.warning,
                label: 'Total Mistakes',
                value: '${store.totalMistakes}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
