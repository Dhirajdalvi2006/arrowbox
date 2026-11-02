import 'package:flutter/material.dart';

import '../arrowbox_board_widgets.dart';

class GameplayControls extends StatelessWidget {
  const GameplayControls({
    required this.isBusy,
    required this.isGameOver,
    required this.isCleared,
    required this.hintsUsed,
    required this.hasValidHint,
    required this.onRestart,
    required this.onHint,
    super.key,
  });

  final bool isBusy;
  final bool isGameOver;
  final bool isCleared;
  final int hintsUsed;
  final bool hasValidHint;
  final VoidCallback onRestart;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GameplayControlButton(
              icon: Icons.refresh_rounded,
              label: 'Restart',
              enabled: !isBusy,
              onTap: onRestart,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GameplayControlButton(
              icon: Icons.lightbulb_rounded,
              label: 'Hint',
              badgeCount: hintsUsed < 3 ? (3 - hintsUsed) : null,
              enabled:
                  !isBusy &&
                  !isGameOver &&
                  !isCleared &&
                  hintsUsed < 3 &&
                  hasValidHint,
              onTap: onHint,
            ),
          ),
        ],
      ),
    );
  }
}
