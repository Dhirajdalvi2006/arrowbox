import 'package:flutter/material.dart';

import '../../arrowbox/arrowbox_board_widgets.dart';
import '../../arrowbox/arrowbox_logic.dart';
import '../models/arrow_skin.dart';

import '../models/board_theme.dart';
import '../registry/board_theme_registry.dart';

class ArrowSkinPreviewBoard extends StatelessWidget {
  const ArrowSkinPreviewBoard({
    required this.skin,
    this.theme,
    this.size = 260,
    super.key,
  });

  final ArrowSkin skin;
  final BoardTheme? theme;
  final double size;

  static const sample = <ArrowDirection?>[
    ArrowDirection.right,
    null,
    ArrowDirection.down,
    null,
    ArrowDirection.left,
    null,
    ArrowDirection.up,
    ArrowDirection.right,
    null,
    ArrowDirection.down,
    ArrowDirection.left,
    null,
    null,
    ArrowDirection.up,
    ArrowDirection.right,
    null,
    ArrowDirection.down,
    ArrowDirection.left,
    null,
    ArrowDirection.up,
    ArrowDirection.right,
    null,
    ArrowDirection.down,
    ArrowDirection.left,
    null,
  ];

  @override
  Widget build(BuildContext context) {
    const gap = 6.0;
    final tile = (size - 12 - gap * 4) / 5;
    final boardTheme =
        theme ??
        BoardThemeRegistry.byId(BoardThemeId.midnight); // Fallback to midnight

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: boardTheme.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: boardTheme.border),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sample.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
        ),
        itemBuilder: (context, index) => sample[index] == null
            ? EmptyBoardCell(theme: boardTheme)
            : skin.buildArrow(direction: sample[index]!, size: tile),
      ),
    );
  }
}
