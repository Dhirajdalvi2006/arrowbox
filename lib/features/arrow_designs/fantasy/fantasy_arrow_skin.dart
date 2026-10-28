import 'package:flutter/material.dart';

import '../core/arrow_skin_painter.dart';
import '../core/arrow_skin_frame.dart';
import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class FantasyArrowSkin extends ArrowSkin {
  const FantasyArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.fantasy;
  @override
  String get name => 'Fantasy';
  @override
  String get description => 'A luminous, magical finish with tiny sparks.';

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
            color: color.withValues(alpha: .42),
            blurRadius: size * .18,
          ),
          BoxShadow(color: color.withValues(alpha: .18), blurRadius: size * .4),
        ],
      ),
      child: CustomPaint(
        painter: ArrowSkinPainter(
          direction: direction,
          color: color,
          style: ArrowPainterStyle.fantasy,
          highlighted: highlighted,
        ),
        child: Stack(
          children: [
            skinIcon(
              direction: direction,
              size: size * .62,
              color: Colors.white,
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _FantasyTracePainter(color: color)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FantasyTracePainter extends CustomPainter {
  const _FantasyTracePainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * .18,
        size.height * .18,
        size.width * .64,
        size.height * .64,
      ),
      -.6,
      1.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FantasyTracePainter oldDelegate) =>
      oldDelegate.color != color;
}
