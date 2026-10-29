import 'package:flutter/material.dart';

import '../core/arrow_direction_icon.dart';
import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class AuroraArrowSkin extends ArrowSkin {
  const AuroraArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.aurora;
  @override
  String get name => 'Aurora';
  @override
  String get description => 'Ethereal, flowing light patterns.';

  @override
  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: highlighted
              ? [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)]
              : [const Color(0xFF21D4FD), const Color(0xFFB721FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withValues(alpha: 0.3),
            blurRadius: size * 0.2,
          ),
        ],
      ),
      child: Center(
        child: ArrowDirectionIcon(
          direction: direction,
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}
