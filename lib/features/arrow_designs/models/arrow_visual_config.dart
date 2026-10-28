import 'package:flutter/material.dart';

class ArrowVisualConfig {
  const ArrowVisualConfig({
    required this.background,
    required this.foreground,
    required this.border,
    this.secondary,
    this.glow,
    this.radius = 14,
    this.borderWidth = 1,
    this.arrowScale = 0.58,
    this.shadow = true,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color? secondary;
  final Color? glow;
  final double radius;
  final double borderWidth;
  final double arrowScale;
  final bool shadow;
}
