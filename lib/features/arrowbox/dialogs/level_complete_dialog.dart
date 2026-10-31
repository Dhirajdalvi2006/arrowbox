import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';

/// Level Complete Overlay Dialog matching Reference Screen 5 with animations & animated hearts
class ArrowBoxLevelCompleteDialog extends StatefulWidget {
  const ArrowBoxLevelCompleteDialog({
    required this.level,
    required this.moves,
    required this.mistakes,
    required this.hintsUsed,
    required this.lives,
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
  final int lives;
  final int stars;
  final int seconds;
  final VoidCallback onNextLevel;
  final VoidCallback onReplayLevel;
  final VoidCallback onLevelSelection;
  final VoidCallback onMainMenu;

  @override
  State<ArrowBoxLevelCompleteDialog> createState() =>
      _ArrowBoxLevelCompleteDialogState();
}

class _ArrowBoxLevelCompleteDialogState
    extends State<ArrowBoxLevelCompleteDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _heartPulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _heartPulseAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heartPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _heartPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartPulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _heartPulseController.dispose();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _ratingStar(BuildContext context, int index, double size) {
    final active = index < widget.stars;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: active ? 1.0 : 0.6),
      duration: Duration(milliseconds: 600 + (index * 150)),
      curve: Curves.elasticOut,
      builder: (context, val, child) {
        return Transform.scale(
          scale: val,
          child: Icon(
            active ? Icons.star_rounded : Icons.star_outline_rounded,
            color: active
                ? AppColors.starGold
                : AppColors.getTextMuted(context),
            size: size,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.isDark(context)
        ? const Color(0xFF091426)
        : AppColors.lightCardWhite;
    final borderColor = AppColors.getBorder(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 330,
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.isDark(context)
                          ? const Color(0x77000000)
                          : const Color(0x28000000),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stars visual
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _ratingStar(context, 0, 42),
                        const SizedBox(width: 6),
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: _ratingStar(context, 1, 60),
                        ),
                        const SizedBox(width: 6),
                        _ratingStar(context, 2, 42),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Level Complete!',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Outstanding puzzle solve!',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Animated Hearts / Lives Left Section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.isDark(context)
                              ? [
                                  const Color(0xFF1E1128),
                                  const Color(0xFF0F172A),
                                ]
                              : [
                                  const Color(0xFFFFEEEE),
                                  const Color(0xFFFFF5F5),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hearts Left:',
                              style: TextStyle(
                                color: AppColors.getTextSecondary(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (index) {
                                final hasHeart = index < widget.lives;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: hasHeart
                                      ? ScaleTransition(
                                          scale: _heartPulseAnimation,
                                          child: const Icon(
                                            Icons.favorite_rounded,
                                            color: AppColors.error,
                                            size: 26,
                                          ),
                                        )
                                      : Icon(
                                          Icons.favorite_outline_rounded,
                                          color: AppColors.getTextMuted(context)
                                              .withValues(alpha: 0.5),
                                          size: 22,
                                        ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Performance stats summary card
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
                            icon: Icons.navigation_rounded,
                            iconColor: AppColors.warning,
                            label: 'Moves',
                            value: '${widget.moves}',
                          ),
                          Divider(color: borderColor, height: 16),
                          _StatRow(
                            icon: Icons.favorite_rounded,
                            iconColor: AppColors.error,
                            label: 'Mistakes',
                            value: '${widget.mistakes}',
                          ),
                          Divider(color: borderColor, height: 16),
                          _StatRow(
                            icon: Icons.lightbulb_outline_rounded,
                            iconColor: AppColors.warning,
                            label: 'Hints',
                            value: '${widget.hintsUsed}',
                          ),
                          Divider(color: borderColor, height: 16),
                          _StatRow(
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.cyan,
                            label: 'Time',
                            value: _formatTime(widget.seconds),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    ArrowBoxPrimaryButton(
                      label: 'Next Level ➔',
                      onPressed: widget.onNextLevel,
                    ),
                    const SizedBox(height: 12),
                    ArrowBoxSecondaryButton(
                      label: 'Replay Level',
                      icon: Icons.refresh_rounded,
                      onPressed: widget.onReplayLevel,
                    ),
                    const SizedBox(height: 12),
                    ArrowBoxSecondaryButton(
                      label: 'Level Selection',
                      icon: Icons.grid_view_rounded,
                      onPressed: widget.onLevelSelection,
                    ),
                    const SizedBox(height: 12),
                    ArrowBoxSecondaryButton(
                      label: 'Main Menu',
                      icon: Icons.home_rounded,
                      onPressed: widget.onMainMenu,
                    ),
                  ],
                ),
              ),
            ),
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
