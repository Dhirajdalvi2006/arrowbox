import 'package:flutter/material.dart';

import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class VoidArrowSkin extends ArrowSkin {
  const VoidArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.voidStyle;
  @override
  String get name => 'Void';
  @override
  String get description => 'Deep, shadowy silhouette with a faint, ominous inner glow.';

  @override
  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  }) {
    final color = highlighted ? const Color(0xFF6A1B9A) : const Color(0xFF263238);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: size * 0.2,
            spreadRadius: -size * 0.05,
          ),
        ],
      ),
      child: Center(
        child: Icon(directionIcon(direction), size: size * 0.5, color: highlighted ? Colors.white : color),
      ),
    );
  }
}
