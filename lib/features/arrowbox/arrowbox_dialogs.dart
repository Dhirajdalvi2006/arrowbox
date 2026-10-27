import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/arrowbox_widgets.dart';

/// Pause Overlay Dialog matching Reference Screen 4
class ArrowBoxPauseDialog extends StatelessWidget {
  const ArrowBoxPauseDialog({
    required this.onResume,
    required this.onRestart,
    required this.onSettings,
    required this.onLevelSelection,
    required this.onMainMenu,
    super.key,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onSettings;
  final VoidCallback onLevelSelection;
  final VoidCallback onMainMenu;

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.isDark(context)
        ? const Color(0xFF091426)
        : AppColors.lightCardWhite;
    final borderColor = AppColors.getBorder(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.isDark(context)
                    ? const Color(0x66000000)
                    : const Color(0x22000000),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: onResume,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.getCard(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.getTextSecondary(context),
                      size: 18,
                    ),
                  ),
                ),
              ),
              Text(
                'Paused',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 22),
              ArrowBoxPrimaryButton(
                label: 'Resume',
                icon: Icons.play_arrow_rounded,
                onPressed: onResume,
              ),
              const SizedBox(height: 12),
              ArrowBoxSecondaryButton(
                label: 'Restart Level',
                icon: Icons.refresh_rounded,
                onPressed: onRestart,
              ),
              const SizedBox(height: 12),
              ArrowBoxSecondaryButton(
                label: 'Settings',
                icon: Icons.settings_outlined,
                onPressed: onSettings,
              ),
              const SizedBox(height: 12),
              ArrowBoxSecondaryButton(
                label: 'Level Selection',
                icon: Icons.grid_view_rounded,
                onPressed: onLevelSelection,
              ),
              const SizedBox(height: 12),
              ArrowBoxSecondaryButton(
                label: 'Main Menu',
                icon: Icons.home_rounded,
                isDanger: true,
                onPressed: onMainMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Level Complete Overlay Dialog matching Reference Screen 5
class ArrowBoxLevelCompleteDialog extends StatelessWidget {
  const ArrowBoxLevelCompleteDialog({
    required this.level,
    required this.moves,
    required this.mistakes,
    required this.hintsUsed,
    required this.stars,
    required this.seconds,
    required this.onNextLevel,
    required this.onReplayLevel,
    required this.onLevelSelection,
    required this.onMainMenu,
    super.key,
  });

  final int level;
  final int moves;
  final int mistakes;
  final int hintsUsed;
  final int stars;
  final int seconds;
  final VoidCallback onNextLevel;
  final VoidCallback onReplayLevel;
  final VoidCallback onLevelSelection;
  final VoidCallback onMainMenu;

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _ratingStar(BuildContext context, int index, double size) => Icon(
        index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
        color: index < stars
            ? AppColors.starGold
            : AppColors.getTextMuted(context),
        size: size,
      );

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.isDark(context)
        ? const Color(0xFF091426)
        : AppColors.lightCardWhite;
    final borderColor = AppColors.getBorder(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.isDark(context)
                      ? const Color(0x66000000)
                      : const Color(0x22000000),
                  blurRadius: 36,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3 Stars visual (center larger)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ratingStar(context, 0, 40),
                    const SizedBox(width: 4),
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: _ratingStar(context, 1, 56),
                    ),
                    const SizedBox(width: 4),
                    _ratingStar(context, 2, 40),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Level Complete!',
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Great job!',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                // Performance stats summary card
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.getSecondaryBackground(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      _StatRow(
                        icon: Icons.navigation_rounded,
                        iconColor: AppColors.warning,
                        label: 'Moves',
                        value: '$moves',
                      ),
                      Divider(color: borderColor, height: 16),
                      _StatRow(
                        icon: Icons.favorite_rounded,
                        iconColor: AppColors.error,
                        label: 'Mistakes',
                        value: '$mistakes',
                      ),
                      Divider(color: borderColor, height: 16),
                      _StatRow(
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: AppColors.warning,
                        label: 'Hints',
                        value: '$hintsUsed',
                      ),
                      Divider(color: borderColor, height: 16),
                      _StatRow(
                        icon: Icons.access_time_rounded,
                        iconColor: AppColors.cyan,
                        label: 'Time',
                        value: _formatTime(seconds),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                ArrowBoxPrimaryButton(
                  label: 'Next Level ➔',
                  onPressed: onNextLevel,
                ),
                const SizedBox(height: 12),
                ArrowBoxSecondaryButton(
                  label: 'Replay Level',
                  icon: Icons.refresh_rounded,
                  onPressed: onReplayLevel,
                ),
                const SizedBox(height: 12),
                ArrowBoxSecondaryButton(
                  label: 'Level Selection',
                  icon: Icons.grid_view_rounded,
                  onPressed: onLevelSelection,
                ),
                const SizedBox(height: 12),
                ArrowBoxSecondaryButton(
                  label: 'Main Menu',
                  icon: Icons.home_rounded,
                  onPressed: onMainMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Game Over Overlay Dialog matching Reference Screen 6
class ArrowBoxGameOverDialog extends StatelessWidget {
  const ArrowBoxGameOverDialog({
    required this.level,
    required this.mistakes,
    required this.onRestart,
    required this.onLevelSelection,
    required this.onMainMenu,
    super.key,
  });

  final int level;
  final int mistakes;
  final VoidCallback onRestart;
  final VoidCallback onLevelSelection;
  final VoidCallback onMainMenu;

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.isDark(context)
        ? const Color(0xFF091426)
        : AppColors.lightCardWhite;
    final borderColor = AppColors.getBorder(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.isDark(context)
                    ? const Color(0x66000000)
                    : const Color(0x22000000),
                blurRadius: 36,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x22FF4D6D),
                ),
                child: const Icon(
                  Icons.heart_broken_rounded,
                  color: AppColors.error,
                  size: 38,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Game Over',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You ran out of lives.',
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.getSecondaryBackground(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.flag_rounded,
                      iconColor: AppColors.primaryBright,
                      label: 'Level',
                      value: '$level',
                    ),
                    Divider(color: borderColor, height: 16),
                    _StatRow(
                      icon: Icons.favorite_border_rounded,
                      iconColor: AppColors.error,
                      label: 'Mistakes',
                      value: '$mistakes',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              ArrowBoxPrimaryButton(
                label: 'Restart Level',
                icon: Icons.refresh_rounded,
                onPressed: onRestart,
              ),
              const SizedBox(height: 12),
              ArrowBoxSecondaryButton(
                label: 'Level Selection',
                icon: Icons.grid_view_rounded,
                onPressed: onLevelSelection,
              ),
              const SizedBox(height: 12),
              ArrowBoxSecondaryButton(
                label: 'Main Menu',
                icon: Icons.home_rounded,
                onPressed: onMainMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
