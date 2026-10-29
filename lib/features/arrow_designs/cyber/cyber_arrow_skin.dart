import 'package:flutter/material.dart';

import '../core/arrow_direction_icon.dart';
import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class CyberArrowSkin extends ArrowSkin {
  const CyberArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.cyber;
  @override
  String get name => 'Cyber';
  @override
  String get description => 'Hard-edged geometric style with circuit-like trails.';

  @override
  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  }) {
    final color = highlighted ? const Color(0xFF00FF9D) : const Color(0xFF00E5FF);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(size * 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: size * 0.1,
          ),
        ],
      ),
      child: Center(
        child: ArrowDirectionIcon(
          direction: direction,
          size: size * 0.5,
          color: color,
        ),
      ),
    );
  }
}
