import 'package:flutter/material.dart';

class SplashAnimations {
  static Animation<double> createEntranceAnimation(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
  }

  static Animation<double> createFloatingAnimation(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutSine,
    );
  }
}
