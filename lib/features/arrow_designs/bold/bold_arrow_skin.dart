import 'package:flutter/material.dart';

import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class BoldArrowSkin extends ArrowSkin {
  const BoldArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.bold;
  @override
  String get name => 'Bold';
  @override
  String get description => 'Heavy silhouettes with uncompromising contrast.';

  @override
  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  }) {
    final colors = directionGradient(direction);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.first, colors.last],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * .16),
        border: Border.all(
          color: Colors.white.withValues(alpha: highlighted ? .9 : .6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: directionColor(direction).withValues(alpha: .25),
            blurRadius: size * .1,
            offset: Offset(0, size * .06),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          directionIcon(direction),
          size: size * .66,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 3)),
          ],
        ),
      ),
    );
  }
}
