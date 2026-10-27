import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ArrowBoxPressScale extends StatefulWidget {
  const ArrowBoxPressScale({required this.child, super.key});

  final Widget child;

  @override
  State<ArrowBoxPressScale> createState() => _ArrowBoxPressScaleState();
}

class _ArrowBoxPressScaleState extends State<ArrowBoxPressScale> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (!mounted || MediaQuery.maybeOf(context)?.disableAnimations == true) {
      return;
    }
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Listener(
      onPointerDown: reduceMotion ? null : (_) => _setPressed(true),
      onPointerUp: reduceMotion ? null : (_) => _setPressed(false),
      onPointerCancel: reduceMotion ? null : (_) => _setPressed(false),
      child: AnimatedScale(
        scale: reduceMotion || !_pressed ? 1 : 0.975,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}


/// Distinctive ArrowBox branding Title with dual-color "Arrow" (White/Dark) and "Box" (Blue)
class ArrowBoxTitle extends StatelessWidget {
  const ArrowBoxTitle({
    this.fontSize = 32,
    this.letterSpacing = -0.5,
    this.showTagline = false,
    super.key,
  });

  final double fontSize;
  final double letterSpacing;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final arrowColor = isDark ? Colors.white : AppColors.lightTextPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Arrow',
                style: TextStyle(
                  color: arrowColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: letterSpacing,
                  fontFamily: 'Inter',
                ),
              ),
              TextSpan(
                text: 'Box',
                style: TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: letterSpacing,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          const Text(
            'Think. Aim. Escape.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Reusable vector / asset logo mark of the ArrowBox isometric cube
class ArrowBoxLogoMark extends StatelessWidget {
  const ArrowBoxLogoMark({this.size = 36, super.key});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33247BFF),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/images/arrowbox_cube_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Tooltip(
            message: 'ArrowBox logo asset failed to load',
            child: ColoredBox(
              color: const Color(0xFF070D1A),
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.cyan,
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hero Artwork Widget for Landing and About screens matching Reference 3
class ArrowBoxHeroArtwork extends StatelessWidget {
  const ArrowBoxHeroArtwork({this.size = 230, super.key});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.isDark(context)
                  ? const Color(0x55247BFF)
                  : const Color(0x33247BFF),
              blurRadius: 40,
              spreadRadius: -4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/images/arrowbox_hero.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.getCard(context),
              padding: const EdgeInsets.all(24),
              child: ArrowBoxLogoMark(size: size * 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary pill action button (e.g. "▶ Play Now >>")
class ArrowBoxPrimaryButton extends StatelessWidget {
  const ArrowBoxPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.showTrailingChevron = false,
    this.height = 54,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool showTrailingChevron;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          colors: [Color(0xFF2884FF), Color(0xFF1B6AE5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55247BFF),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ArrowBoxPressScale(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(27),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  if (showTrailingChevron) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary translucent pill action button (e.g. "↻ Continue Level 5 >")
class ArrowBoxSecondaryButton extends StatelessWidget {
  const ArrowBoxSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.showTrailingChevron = false,
    this.height = 52,
    this.isDanger = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool showTrailingChevron;
  final double height;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.getCard(context);
    final borderColor = isDanger
        ? const Color(0x44FF4D6D)
        : AppColors.getBorder(context);
    final textColor = isDanger
        ? const Color(0xFFFF6B84)
        : AppColors.getTextPrimary(context);
    final iconColor = isDanger
        ? const Color(0xFFFF6B84)
        : AppColors.primaryBright;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: ArrowBoxPressScale(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: iconColor, size: 19),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (showTrailingChevron) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.getTextMuted(context),
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact rounded action card button (Landing bottom: Progress, How to Play, About)
/// Displays Icon, Bold Title, and Subtitle matching Reference 3!
class ArrowBoxActionCard extends StatelessWidget {
  const ArrowBoxActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.getCard(context);
    final borderColor = AppColors.getBorder(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1.1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.primaryBright, size: 24),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.getTextMuted(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header Icon Button in dark / light circular pill
class ArrowBoxHeaderIconButton extends StatelessWidget {
  const ArrowBoxHeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconColor,
    this.size = 56,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xCC091A31) : AppColors.lightCardWhite,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xAA247BFF) : AppColors.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x55247BFF) : const Color(0x18000000),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: size * 0.55,
          tooltip: tooltip,
          icon: Icon(
            icon,
            color: iconColor ?? AppColors.getTextPrimary(context),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
