import 'package:flutter/material.dart';

import 'arrow_skin_utils.dart';

class ArrowSkinPainter extends CustomPainter {
  const ArrowSkinPainter({
    required this.direction,
    required this.color,
    required this.style,
    this.highlighted = false,
  });

  final ArrowDirection direction;
  final Color color;
  final ArrowPainterStyle style;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = style == ArrowPainterStyle.tech ? 9.0 : 14.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(radius)),
      );
    final fill = Paint()
      ..color =
          style == ArrowPainterStyle.neon || style == ArrowPainterStyle.minimal
          ? Colors.transparent
          : color.withValues(alpha: 0.22);
    canvas.drawPath(path, fill);
    final border = Paint()
      ..color = color.withValues(
        alpha: style == ArrowPainterStyle.fantasy ? 0.95 : 0.75,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = style == ArrowPainterStyle.tech ? 2.0 : 1.2;
    canvas.drawPath(path, border);
    if (style == ArrowPainterStyle.tech) {
      final accent = Paint()..color = color;
      canvas.drawLine(
        const Offset(2, 12),
        const Offset(12, 2),
        accent..strokeWidth = 2,
      );
      canvas.drawLine(
        Offset(size.width - 12, size.height - 2),
        Offset(size.width - 2, size.height - 12),
        accent,
      );
    }
    if (style == ArrowPainterStyle.fantasy) {
      final spark = Paint()..color = color.withValues(alpha: 0.9);
      for (final point in [
        Offset(size.width * .18, size.height * .2),
        Offset(size.width * .8, size.height * .18),
        Offset(size.width * .82, size.height * .8),
      ]) {
        canvas.drawCircle(point, highlighted ? 2.2 : 1.3, spark);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArrowSkinPainter oldDelegate) =>
      oldDelegate.direction != direction ||
      oldDelegate.color != color ||
      oldDelegate.style != style ||
      oldDelegate.highlighted != highlighted;
}

enum ArrowPainterStyle { neon, minimal, tech, fantasy }
