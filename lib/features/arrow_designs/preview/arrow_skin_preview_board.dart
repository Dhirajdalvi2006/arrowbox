import 'package:flutter/material.dart';

import '../../arrowbox/arrowbox_logic.dart';
import '../../../core/theme/app_colors.dart';
import '../models/arrow_skin.dart';

class ArrowSkinPreviewBoard extends StatelessWidget {
  const ArrowSkinPreviewBoard({required this.skin, this.size = 260, super.key});

  final ArrowSkin skin;
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
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.boardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.boardCellBorder),
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
            ? Container(
                decoration: BoxDecoration(
                  color: AppColors.boardCell,
                  borderRadius: BorderRadius.circular(tile * .2),
                  border: Border.all(color: AppColors.boardCellBorder),
                ),
              )
            : skin.buildArrow(direction: sample[index]!, size: tile),
      ),
    );
  }
}
