import 'package:flutter/material.dart';

import '../core/arrow_skin_frame.dart';
import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class ClassicArrowSkin extends ArrowSkin {
  const ClassicArrowSkin();

  @override
  ArrowSkinId get id => ArrowSkinId.classic;
  @override
  String get name => 'Classic';
  @override
  String get description => 'Polished gradients for everyday play.';

  @override
  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  }) {
    final radius = size * .2;
    final colors = directionGradient(direction);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: highlighted ? .8 : .35),
          width: highlighted ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: directionColor(direction).withValues(alpha: .32),
            blurRadius: size * .18,
            offset: Offset(0, size * .06),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: size * .1,
            right: size * .1,
            child: Container(
              height: size * .16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: Colors.white.withValues(alpha: .16),
              ),
            ),
          ),
          skinIcon(direction: direction, size: size * .58, color: Colors.white),
        ],
      ),
    );
  }
}
