import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'arrowbox_logic.dart';

Offset arrowEscapeOffset(ArrowDirection direction, double distance) {
  final (rowStep, columnStep) = direction.vector;
  return Offset(columnStep * distance, rowStep * distance);
}

class GradientArrowTile extends StatefulWidget {
  const GradientArrowTile({
    required this.direction,
    required this.index,
    required this.highlighted,
    required this.isEscaping,
    required this.isShaking,
    required this.onTap,
    this.animationDelay = Duration.zero,
    this.escapeDistance = 280,
    super.key,
  });

  final ArrowDirection direction;
  final int index;
  final bool highlighted;
  final bool isEscaping;
  final bool isShaking;
  final VoidCallback onTap;
  final Duration animationDelay;
  final double escapeDistance;

  @override
  State<GradientArrowTile> createState() => _GradientArrowTileState();
}

class _GradientArrowTileState extends State<GradientArrowTile>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _escapeController;
  late final AnimationController _shakeController;
  late final AnimationController _entryController;
  late final AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _escapeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 1.0,
      lowerBound: 0.9,
      upperBound: 1.0,
    );

    if (widget.highlighted) {
      _pulseController.repeat(reverse: true);
    }

    Future.delayed(widget.animationDelay, () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void didUpdateWidget(covariant GradientArrowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlighted && !oldWidget.highlighted) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.highlighted && oldWidget.highlighted) {
      _pulseController.stop();
      _pulseController.reset();
    }

    if (widget.isEscaping && !oldWidget.isEscaping) {
      _escapeController.forward(from: 0.0);
    }

    if (widget.isShaking && !oldWidget.isShaking) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _escapeController.dispose();
    _shakeController.dispose();
    _entryController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, gradientColors, glowColor) = switch (widget.direction) {
      ArrowDirection.up => (
        Icons.arrow_upward_rounded,
        AppColors.arrowUpGradient,
        const Color(0x7721D4FD),
      ),
      ArrowDirection.right => (
        Icons.arrow_forward_rounded,
        AppColors.arrowRightGradient,
        const Color(0x77FFB547),
      ),
      ArrowDirection.down => (
        Icons.arrow_downward_rounded,
        AppColors.arrowDownGradient,
        const Color(0x77FF5277),
      ),
      ArrowDirection.left => (
        Icons.arrow_back_rounded,
        AppColors.arrowLeftGradient,
        const Color(0x7721D98B),
      ),
    };

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _escapeController,
        _shakeController,
        _entryController,
        _tapController,
      ]),
      builder: (context, child) {
        final entryVal = reduceMotion
            ? 1.0
            : Curves.easeOutBack.transform(_entryController.value);
        final scaleVal = reduceMotion ? 1.0 : entryVal * _tapController.value;

        final escapeVal = reduceMotion
            ? _escapeController.value
            : Curves.easeInCubic.transform(_escapeController.value);
        final escapeOffset = arrowEscapeOffset(
          widget.direction,
          escapeVal * widget.escapeDistance,
        );
        final offsetX = escapeOffset.dx;
        final offsetY = escapeOffset.dy;
        final opacity = (1.0 - escapeVal).clamp(0.0, 1.0);
        final entryOpacity = reduceMotion ? 1.0 : _entryController.value;

        final shakeVal = _shakeController.value;
        final shakeOffset = reduceMotion
            ? 0.0
            : math.sin(shakeVal * math.pi * 5) * (1.0 - shakeVal) * 8.0;

        return Transform.scale(
          scale: scaleVal,
          child: Transform.translate(
            offset: Offset(offsetX + shakeOffset, offsetY),
            child: Opacity(
              opacity: opacity * entryOpacity,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: Listener(
                  onPointerDown: (_) => _tapController.reverse(),
                  onPointerUp: (_) => _tapController.forward(),
                  onPointerCancel: (_) => _tapController.forward(),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: widget.isEscaping ? null : widget.onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.highlighted
                              ? Color.lerp(
                                  Colors.white,
                                  const Color(0xFF21D4FD),
                                  _pulseController.value,
                                )!
                              : Colors.white.withValues(alpha: 0.35),
                          width: widget.highlighted ? 2.5 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 0,
                            spreadRadius: -2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 2,
                            left: 4,
                            right: 4,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 32,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Empty Board Cell with centered dot matching Reference 1
class EmptyBoardCell extends StatelessWidget {
  const EmptyBoardCell({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bgColor = isDark ? const Color(0xFF0A1628) : const Color(0xFFE2EAF4);
    final borderColor = isDark
        ? const Color(0xFF142640)
        : const Color(0xFFD0DCED);
    final dotColor = AppColors.getBoardDot(context).withValues(alpha: 0.4);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [
              if (isDark)
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hint Panel matching Reference 1 with glowing bulb and right chevron
class GameplayHintPanel extends StatelessWidget {
  const GameplayHintPanel({
    required this.message,
    required this.onTapHint,
    super.key,
  });

  final String message;
  final VoidCallback onTapHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.getCard(context).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getBorder(context).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTapHint,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB547).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB547).withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFFFFCC33),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hint',
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          message,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.getTextMuted(context)
                        .withValues(alpha: 0.6),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gameplay control button with optional badge count (e.g. Undo 2, Hint 3)
class GameplayControlButton extends StatelessWidget {
  const GameplayControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount,
    this.enabled = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppColors.getTextPrimary(context)
        : AppColors.getTextMuted(context);
    final iconColor = enabled
        ? AppColors.primaryBright
        : AppColors.getTextMuted(context);

    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.getCard(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.getBorder(context),
                width: 1.1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: enabled ? onTap : null,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: iconColor, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (badgeCount != null)
            Positioned(
              top: 6,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFF1D5CC9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
