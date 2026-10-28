import 'package:flutter/material.dart';

import '../core/arrow_skin_painter.dart';
import '../core/arrow_skin_frame.dart';
import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class MinimalArrowSkin extends ArrowSkin {
  const MinimalArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.minimal;
  @override
  String get name => 'Minimal';
  @override
  String get description => 'A quiet outline that keeps the arrow central.';

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
        style: ArrowPainterStyle.minimal,
        highlighted: highlighted,
      ),
      child: skinIcon(direction: direction, size: size * .62, color: color),
    );
  }
}
