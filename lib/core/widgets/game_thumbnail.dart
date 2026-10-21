import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GameThumbnail extends StatelessWidget {
  final String emoji;
  final double size;
  final Color? background;
  final double borderRadius;

  const GameThumbnail({
    super.key,
    required this.emoji,
    this.size = 80,
    this.background,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.isFinite ? size : null,
      height: size.isFinite ? size : null,
      decoration: BoxDecoration(
        color: background ?? AppColors.primaryLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolved = constraints.biggest.shortestSide;
          final fontSize = resolved.isFinite && resolved > 0
              ? resolved * 0.45
              : 36.0;
          return Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: fontSize),
            ),
          );
        },
      ),
    );
  }
}
