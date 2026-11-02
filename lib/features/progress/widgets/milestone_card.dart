// This file is deprecated. Use milestone_rewards_card.dart instead.
import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';

/// Deprecated placeholder — retained for backward compatibility.
/// All milestone reward logic is now in MilestoneRewardsCard.
class RewardMilestoneCard extends StatelessWidget {
  const RewardMilestoneCard({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
      ),
      child: const Center(
        child: Text(
          'Rewards',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Deprecated placeholder — retained for backward compatibility.
class MilestoneRoadmap extends StatelessWidget {
  const MilestoneRoadmap({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
