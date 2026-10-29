import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashArrowTile extends StatelessWidget {
  final IconData icon;
  final double size;
  final Offset position;
  final double rotation;

  const SplashArrowTile({
    required this.icon,
    required this.size,
    required this.position,
    required this.rotation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: position,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628),
            borderRadius: BorderRadius.circular(size * 0.2),
            border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, color: AppColors.cyan, size: size * 0.6),
          ),
        ),
      ),
    );
  }
}
