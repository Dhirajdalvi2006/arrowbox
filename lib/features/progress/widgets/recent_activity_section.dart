import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import 'activity_card.dart';

/// Recently completed levels activity section with a properly constrained
/// horizontal carousel that never clips cards at the edges.
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final completedLevels = store.completedLevels.toList()
      ..sort((a, b) => b.compareTo(a));
    final recentLevels = completedLevels.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(width: 4, height: 16, color: AppColors.cyan),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'RECENT ACTIVITY',
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // View All placeholder - no dedicated history screen exists yet.
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VIEW ALL',
                      style: TextStyle(
                        color: AppColors.primaryBright,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryBright,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (recentLevels.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.getCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.getBorder(context),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timeline_rounded,
                  color: AppColors.getTextMuted(context),
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent activity',
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete your first level to see it here.',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          // Use a constrained horizontal list with proper padding so cards
          // are never clipped at the left or right edges.
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Left padding equals page padding so first card starts at
              // the correct position; right padding previews the next card.
              padding: const EdgeInsets.only(left: 20, right: 20),
              itemCount: recentLevels.length,
              itemBuilder: (context, index) {
                final level = recentLevels[index];
                final stars = store.levelStars[level] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ActivityCard(
                    level: level,
                    stars: stars,
                    label: '#${index + 1} most recent',
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
