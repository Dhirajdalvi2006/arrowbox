import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
