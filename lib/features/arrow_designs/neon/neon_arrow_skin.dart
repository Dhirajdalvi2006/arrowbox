import 'package:flutter/material.dart';

import '../core/arrow_skin_painter.dart';
import '../core/arrow_skin_frame.dart';
import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class NeonArrowSkin extends ArrowSkin {
  const NeonArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.neon;
  @override
  String get name => 'Neon';
  @override
  String get description => 'Controlled cyber glow on a dark frame.';

  @override
  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  }) {
    final color = directionColor(direction);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: highlighted ? .42 : .22),
            blurRadius: size * .22,
          ),
          BoxShadow(
            color: color.withValues(alpha: .12),
            blurRadius: size * .45,
          ),
        ],
      ),
      child: CustomPaint(
        painter: ArrowSkinPainter(
          direction: direction,
          color: color,
          style: ArrowPainterStyle.neon,
          highlighted: highlighted,
        ),
        child: skinIcon(direction: direction, size: size * .62, color: color),
      ),
    );
  }
}
