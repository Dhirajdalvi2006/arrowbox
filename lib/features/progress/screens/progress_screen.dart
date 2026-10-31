import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';
import '../widgets/progress_widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({required this.store, this.embedded = false, super.key});
  final AppStore store;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final completedCount = store.completedLevels.length;
    final progressRatio = (completedCount / AppStore.totalLevels).clamp(
      0.0,
      1.0,
    );

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
                    onPressed: embedded ? () {} : () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Progress',
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
                children: [
                  // Circular Progress Card
                  CircularProgressCard(
                    completedCount: completedCount,
                    totalLevels: AppStore.totalLevels,
                    progressRatio: progressRatio,
                  ),

                  const SizedBox(height: 20),

                  // 2x2 Metric Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          icon: Icons.grid_view_rounded,
                          iconColor: AppColors.primaryBright,
                          label: 'Total Levels',
                          value: '${AppStore.totalLevels}',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MetricCard(
                          icon: Icons.flag_rounded,
                          iconColor: AppColors.error,
                          label: 'Current Level',
                          value: '${store.unlockedLevel}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          icon: Icons.sports_esports_rounded,
                          iconColor: AppColors.cyan,
                          label: 'Games Played',
                          value: '${store.gamesPlayed}',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MetricCard(
                          icon: Icons.warning_amber_rounded,
                          iconColor: AppColors.warning,
                          label: 'Total Mistakes',
                          value: '${store.totalMistakes}',
                        ),
                      ),
                    ],
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
