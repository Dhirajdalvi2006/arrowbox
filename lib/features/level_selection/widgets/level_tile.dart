import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../arrowbox/arrowbox_logic.dart';

class LevelTile extends StatelessWidget {
  const LevelTile({
    required this.level,
    required this.difficulty,
    required this.isCompleted,
    required this.stars,
    required this.isCurrent,
    required this.isLocked,
    required this.onTap,
    super.key,
  });

  final int level;
  final ArrowBoxDifficulty difficulty;
  final bool isCompleted;
  final int stars;
  final bool isCurrent;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Border? border;

    if (isCompleted) {
      bg = AppColors.primary;
    } else if (isCurrent) {
      bg = AppColors.getSurfaceElevated(context);
      border = Border.all(color: AppColors.primaryBright, width: 2);
    } else {
      bg = AppColors.getCard(context);
      border = Border.all(color: AppColors.getBorder(context), width: 1);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: border,
            boxShadow: isCompleted
                ? const [
                    BoxShadow(
                      color: Color(0x40247BFF),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$level',
                style: TextStyle(
                  color: isLocked
                      ? AppColors.getTextMuted(context)
                      : AppColors.getTextPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                difficulty == ArrowBoxDifficulty.ultraHard
                    ? 'Ultra'
                    : difficulty.label,
                style: TextStyle(
                  color: isLocked
                      ? AppColors.getTextMuted(context)
                      : AppColors.getTextSecondary(context),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              if (isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: index < stars
                          ? AppColors.starGold
                          : AppColors.getTextMuted(context),
                      size: 13,
                    ),
                  ),
                )
              else if (isLocked)
                Icon(
                  Icons.lock_rounded,
                  color: AppColors.getTextMuted(context),
                  size: 14,
                )
              else
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
