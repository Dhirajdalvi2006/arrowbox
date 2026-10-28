import 'package:flutter/material.dart';

import '../core/arrow_skin_painter.dart';
import '../core/arrow_skin_frame.dart';
import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class TechArrowSkin extends ArrowSkin {
  const TechArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.tech;
  @override
  String get name => 'Tech';
  @override
  String get description => 'Angular precision with restrained edge accents.';

  @override
  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  }) {
    final color = directionColor(direction);
    return CustomPaint(
      size: Size.square(size),
      painter: ArrowSkinPainter(
        direction: direction,
        color: color,
        style: ArrowPainterStyle.tech,
        highlighted: highlighted,
      ),
      child: skinIcon(
        direction: direction,
        size: size * .58,
        color: Colors.white,
      ),
    );
  }
}
