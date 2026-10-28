import 'package:flutter/material.dart';

import '../models/arrow_skin.dart';
import 'arrow_direction_icon.dart';
import 'arrow_skin_utils.dart';

class ArrowSkinFrame extends StatelessWidget {
  const ArrowSkinFrame({
    required this.skin,
    required this.direction,
    required this.size,
    this.highlighted = false,
    this.isInteractive = false,
    super.key,
  });

  final ArrowSkin skin;
  final ArrowDirection direction;
  final double size;
  final bool highlighted;
  final bool isInteractive;

  @override
  Widget build(BuildContext context) => skin.buildArrow(
    direction: direction,
    size: size,
    highlighted: highlighted,
    isInteractive: isInteractive,
  );
}

Widget skinIcon({
  required ArrowDirection direction,
  required double size,
  required Color color,
}) => Center(
  child: ArrowDirectionIcon(
    direction: direction,
    size: size,
    color: color,
    shadow: const [
      Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 4),
    ],
  ),
);
