import 'package:flutter/material.dart';

import 'arrow_skin_utils.dart';

class ArrowDirectionIcon extends StatelessWidget {
  const ArrowDirectionIcon({
    required this.direction,
    required this.size,
    required this.color,
    this.shadow,
    super.key,
  });

  final ArrowDirection direction;
  final double size;
  final Color color;
  final List<Shadow>? shadow;

  @override
  Widget build(BuildContext context) =>
      Icon(directionIcon(direction), size: size, color: color, shadows: shadow);
}
