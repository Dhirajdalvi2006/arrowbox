import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';

/// Full activity history screen displaying all completed levels.
class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final completedLevels = store.completedLevels.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  ArrowBoxHeaderIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    size: 44,
                    iconColor: AppColors.primaryBright,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Activity History',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: completedLevels.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: AppColors.getTextMuted(context),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No completed levels yet',
                            style: TextStyle(
                              color: AppColors.getTextPrimary(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete levels to build your activity history.',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      itemCount: completedLevels.length,
                      itemBuilder: (context, index) {
                        final level = completedLevels[index];
                        final stars = store.levelStars[level] ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.getCard(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.getBorder(context),
                              width: 1.1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBright.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: AppColors.primaryBright,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Level $level Completed',
                                      style: TextStyle(
                                        color: AppColors.getTextPrimary(
                                          context,
                                        ),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: List.generate(
                                        3,
                                        (starIndex) => Icon(
                                          starIndex < stars
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          color: AppColors.starGold,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
