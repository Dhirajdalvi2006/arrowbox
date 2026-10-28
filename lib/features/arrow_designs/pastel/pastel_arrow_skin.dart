import 'package:flutter/material.dart';

import '../core/arrow_skin_colors.dart';
import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class PastelArrowSkin extends ArrowSkin {
  const PastelArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.pastel;
  @override
  String get name => 'Pastel';
  @override
  String get description => 'Soft directional colors with calm clarity.';

  @override
  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  }) {
    final color = ArrowSkinColors.pastel(direction);
    final arrowColor = color.computeLuminance() > .55
        ? const Color(0xFF24334D)
        : Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * .2),
        border: Border.all(
          color: Colors.white.withValues(alpha: .72),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .32),
            blurRadius: size * .12,
            offset: Offset(0, size * .04),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          directionIcon(direction),
          size: size * .58,
          color: arrowColor,
        ),
      ),
    );
  }
}
