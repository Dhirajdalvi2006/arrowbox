import 'package:flutter/material.dart';

import 'arrow_skin_utils.dart';

class ArrowSkinColors {
  const ArrowSkinColors._();

  static Color primary(ArrowDirection direction) => directionColor(direction);
  static Color soft(ArrowDirection direction) =>
      directionColor(direction).withValues(alpha: 0.28);
  static Color pastel(ArrowDirection direction) =>
      Color.lerp(directionColor(direction), Colors.white, 0.58)!;
}
