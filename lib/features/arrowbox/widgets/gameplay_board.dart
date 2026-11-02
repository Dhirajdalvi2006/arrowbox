import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../arrow_designs/arrow_designs.dart';
import '../arrowbox_board_widgets.dart';
import '../arrowbox_logic.dart';

class ArrowBoxExitRecord {
  const ArrowBoxExitRecord({
    required this.id,
    required this.direction,
    required this.session,
    required this.duration,
  });

  final int id;
  final ArrowDirection direction;
  final int session;
  final Duration duration;
}

class GameplayBoard extends StatelessWidget {
  const GameplayBoard({
    required this.game,
    required this.boardTheme,
    required this.skin,
    required this.exiting,
    required this.hintIndex,
    required this.shakingIndex,
    required this.animationDuration,
    required this.onTap,
    super.key,
  });

  final ArrowBoxState game;
  final BoardTheme boardTheme;
  final ArrowSkin skin;
  final Map<int, ArrowBoxExitRecord> exiting;
  final int? hintIndex;
  final int? shakingIndex;
  final Duration animationDuration;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = (constraints.maxWidth - 4).clamp(0.0, 420.0);
        final escapeDistance = boardWidth;

        return Container(
          width: boardWidth,
          height: boardWidth,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? boardTheme.frame
                : AppColors.getSecondaryBackground(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? boardTheme.frameBorder
                  : AppColors.getBorder(context),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x33000000)
                    : const Color(0x12000000),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
              if (isDark)
                BoxShadow(
                  color: const Color(0xFF21D4FD).withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, boardConstraints) {
              const gap = 10.0;
              final calculatedTileSize =
                  (boardConstraints.maxWidth - gap * 4) / 5;
              final tileSize =
                  (calculatedTileSize <= 0.0 || calculatedTileSize.isNaN)
                  ? 60.0
                  : calculatedTileSize;
              final indexes = [for (var index = 0; index < 25; index++) index];

              return SizedBox.expand(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final index in indexes)
                      Positioned(
                        key: ValueKey(index),
                        left: (index % 5) * (tileSize + gap),
                        top: (index ~/ 5) * (tileSize + gap),
                        width: tileSize,
                        height: tileSize,
                        child: _buildCell(
                          index: index,
                          tileSize: tileSize,
                          escapeDistance: escapeDistance,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Builds a consistent cell widget for every grid position.
  ///
  /// Every cell position ALWAYS renders an [EmptyBoardCell] as its base layer,
  /// guaranteeing the empty-tile background, border, and rounded corners are
  /// always visible regardless of arrow state. The arrow (if present or
  /// escaping) is rendered on top via a [Stack].
  ///
  /// - Empty cell (no arrow) → [EmptyBoardCell] only
  /// - Occupied cell → [EmptyBoardCell] + [GradientArrowTile] on top
  /// - Escaping cell → [EmptyBoardCell] + escaping [GradientArrowTile] on top;
  ///   when the arrow fades out, [EmptyBoardCell] remains visible
  Widget _buildCell({
    required int index,
    required double tileSize,
    required double escapeDistance,
  }) {
    final isEmpty = game.board[index] == null;
    final isExiting = exiting[index] != null;

    return Stack(
      children: [
        // Base layer: always render the empty tile background.
        // SizedBox.expand guarantees EmptyBoardCell fills the entire cell
        // bounds (tileSize x tileSize) so every grid position always has a
        // visible tile decoration, even during escape animations when the
        // arrow tile fades to opacity 0.
        SizedBox.expand(child: EmptyBoardCell(theme: boardTheme)),

        // Overlay layer: arrow tile (occupied or escaping).
        if (!isEmpty)
          GradientArrowTile(
            direction: game.board[index]!,
            skin: skin,
            index: index,
            highlighted: index == hintIndex,
            isEscaping: false,
            isShaking: index == shakingIndex,
            onTap: () => onTap(index),
            escapeDuration: animationDuration,
            escapeDistance: escapeDistance,
            animationDelay: Duration(
              milliseconds: (index % 5 + index ~/ 5) * 50,
            ),
          )
        else if (isExiting)
          GradientArrowTile(
            direction: exiting[index]!.direction,
            skin: skin,
            index: index,
            highlighted: false,
            isEscaping: true,
            isShaking: false,
            onTap: () {},
            escapeDuration: exiting[index]!.duration,
            escapeDistance: escapeDistance,
          ),
      ],
    );
  }
}
