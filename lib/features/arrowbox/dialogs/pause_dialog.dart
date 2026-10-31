import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';

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
