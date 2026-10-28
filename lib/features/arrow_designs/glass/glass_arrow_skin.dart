import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/arrow_skin_utils.dart';
import '../models/arrow_skin.dart';
import '../models/arrow_skin_id.dart';

class GlassArrowSkin extends ArrowSkin {
  const GlassArrowSkin();
  @override
  ArrowSkinId get id => ArrowSkinId.glass;
  @override
  String get name => 'Glass';
  @override
  String get description => 'Translucent color with a light-catching edge.';

  @override
  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  }) {
    final color = directionColor(direction);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * .2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: .19),
                color.withValues(alpha: .3),
                color.withValues(alpha: .16),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * .2),
            border: Border.all(
              color: Colors.white.withValues(alpha: highlighted ? .75 : .42),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .2),
                blurRadius: size * .16,
                offset: Offset(0, size * .05),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: size * .12,
                right: size * .12,
                child: Container(
                  height: 2,
                  color: Colors.white.withValues(alpha: .65),
                ),
              ),
              Center(
                child: Icon(
                  directionIcon(direction),
                  size: size * .58,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
