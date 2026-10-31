import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';
import '../arrowbox_logic.dart';

class GameplayHud extends StatelessWidget {
  const GameplayHud({
    required this.level,
    required this.difficulty,
    required this.lives,
    required this.mistakes,
    required this.seconds,
    required this.onBack,
    required this.onPause,
    super.key,
  });

  final int level;
  final ArrowBoxDifficulty difficulty;
  final int lives;
  final int mistakes;
  final int seconds;
  final VoidCallback onBack;
  final VoidCallback onPause;

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ArrowBoxHeaderIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: onBack,
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          ArrowBoxLogoMark(size: 26),
                          SizedBox(width: 10),
                          ArrowBoxTitle(fontSize: 22),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Level $level',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Semantics(
                            label: 'Level $level, ${difficulty.label}',
                            child: DifficultyBadge(difficulty: difficulty),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ArrowBoxHeaderIconButton(
                icon: Icons.pause_rounded,
                tooltip: 'Pause',
                onPressed: onPause,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(3, (i) {
                      final hasLife = i < lives;
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Icon(
                          hasLife
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: hasLife
                              ? const Color(0xFFFF4D6D)
                              : (isDark
                                    ? const Color(0xFF33445D)
                                    : const Color(0xFFCAD6E6)),
                          size: 27,
                          shadows: hasLife
                              ? const [
                                  Shadow(
                                    color: Color(0x66FF365F),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 28,
                      color: AppColors.getBorder(context),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$mistakes mistakes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.getCard(context).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.getBorder(context).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: AppColors.cyan,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(seconds),
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({required this.difficulty, super.key});
  final ArrowBoxDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      ArrowBoxDifficulty.easy => AppColors.success,
      ArrowBoxDifficulty.medium => AppColors.cyan,
      ArrowBoxDifficulty.hard => AppColors.warning,
      ArrowBoxDifficulty.ultraHard => AppColors.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        difficulty == ArrowBoxDifficulty.ultraHard
            ? 'ULTRA'
            : difficulty.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
