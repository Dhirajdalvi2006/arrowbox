import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import 'progress_ring.dart';

/// Hero card showing overall journey progress with an animated ring and an
/// encouraging message. The standalone continue button was removed from the
/// gameplay journey card; level launching remains available through the level
/// selection and home screens.
class JourneyCard extends StatelessWidget {
  const JourneyCard({required this.store, super.key});

  final AppStore store;

  String _getMotivationalMessage(double progressRatio) {
    if (progressRatio >= 1.0) {
      return 'Congratulations! You have mastered every level.';
    }
    if (progressRatio >= 0.75) {
      return 'Almost there! Keep pushing forward.';
    }
    if (progressRatio >= 0.5) {
      return 'Halfway there! You are doing great.';
    }
    if (progressRatio >= 0.25) {
      return 'Great start! Keep the momentum going.';
    }
    return 'Every move gets you closer to mastery.';
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = store.completedLevels.length;
    final totalLevels = AppStore.totalLevels;
    final progressRatio = (completedCount / totalLevels).clamp(0.0, 1.0);
    final isComplete = progressRatio >= 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBright.withValues(alpha: 0.10),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBright.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.primaryBright,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'YOUR JOURNEY',
                style: TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final double ringSize = constraints.maxWidth
                  .clamp(90.0, 130.0)
                  .toDouble();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ProgressRing(
                          progress: progressRatio,
                          size: ringSize,
                          strokeWidth: 10,
                        ),
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.starGold,
                                  size: 32,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$completedCount / $totalLevels',
                                  style: TextStyle(
                                    color: AppColors.getTextPrimary(context),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Levels Completed',
                                  style: TextStyle(
                                    color: AppColors.getTextSecondary(context),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getMotivationalMessage(progressRatio),
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                        if (isComplete) ...[
                          const SizedBox(height: 16),
                          Container(
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                            ),
                            child: const Text(
                              'All Levels Complete! 🎉',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
