import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';
import '../widgets/how_to_play_widgets.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  ArrowBoxHeaderIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'How to Play',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: const [
                  TutorialStepCard(
                    step: 1,
                    title: 'Each block has a direction',
                    subtitle:
                        'Arrows can only move in the direction they point.',
                    visual: Step1Visual(),
                  ),
                  SizedBox(height: 16),
                  TutorialStepCard(
                    step: 2,
                    title: 'Clear path to the edge',
                    subtitle:
                        'An arrow escapes if there are no blocks in its path.',
                    visual: Step2Visual(),
                  ),
                  SizedBox(height: 16),
                  TutorialStepCard(
                    step: 3,
                    title: 'Remove the block',
                    subtitle:
                        'When an arrow escapes, it is removed from the board.',
                    visual: Step3Visual(),
                  ),
                  SizedBox(height: 16),
                  TutorialStepCard(
                    step: 4,
                    title: 'Complete the level',
                    subtitle: 'Clear all arrows to complete the level.',
                    visual: Step4Visual(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
