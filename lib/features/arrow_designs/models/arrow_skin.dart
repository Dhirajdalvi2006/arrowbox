import 'package:flutter/material.dart';

import '../core/arrow_skin_frame.dart';
import '../core/arrow_skin_utils.dart';
import 'arrow_skin_id.dart';

abstract class ArrowSkin {
  const ArrowSkin();

  ArrowSkinId get id;
  String get name;
  String get description;

  Widget buildArrow({
    required ArrowDirection direction,
    required double size,
    bool highlighted = false,
    bool isInteractive = false,
  });

  Widget buildPreview({required double size}) =>
      ArrowSkinFrame(skin: this, direction: ArrowDirection.up, size: size);
}
