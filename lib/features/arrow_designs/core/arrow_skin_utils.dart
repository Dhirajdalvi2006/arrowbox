import 'package:flutter/material.dart';

import '../../arrowbox/arrowbox_logic.dart';

export '../../arrowbox/arrowbox_logic.dart' show ArrowDirection;

Color directionColor(ArrowDirection direction) => switch (direction) {
  ArrowDirection.up => const Color(0xFF21D4FD),
  ArrowDirection.right => const Color(0xFFFFB547),
  ArrowDirection.down => const Color(0xFFFF5277),
  ArrowDirection.left => const Color(0xFF21D98B),
};

List<Color> directionGradient(ArrowDirection direction) => switch (direction) {
  ArrowDirection.up => const [
    Color(0xFF21D4FF),
    Color(0xFF0879FF),
    Color(0xFF064BE8),
  ],
  ArrowDirection.right => const [
    Color(0xFFFFD86B),
    Color(0xFFFF9E00),
    Color(0xFFF66A00),
  ],
  ArrowDirection.down => const [
    Color(0xFFFF779A),
    Color(0xFFFF3268),
    Color(0xFFE8004F),
  ],
  ArrowDirection.left => const [
    Color(0xFF75F8CF),
    Color(0xFF12D9A4),
    Color(0xFF00B98E),
  ],
};

IconData directionIcon(ArrowDirection direction) => switch (direction) {
  ArrowDirection.up => Icons.arrow_upward_rounded,
  ArrowDirection.right => Icons.arrow_forward_rounded,
  ArrowDirection.down => Icons.arrow_downward_rounded,
  ArrowDirection.left => Icons.arrow_back_rounded,
};
