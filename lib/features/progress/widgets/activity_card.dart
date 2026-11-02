import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Individual recently-completed level activity card.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.level,
    required this.stars,
    required this.label,
    super.key,
  });

  final int level;
  final int stars;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 16,
                ),
              ),
              const Spacer(),
              Text(
                'Lv. $level',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Completed',
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.star_rounded,
                  color: index < stars
                      ? AppColors.starGold
                      : AppColors.getTextMuted(context),
                  size: 14,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.getTextMuted(context),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
