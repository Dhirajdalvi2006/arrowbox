import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../shell/app_shell.dart';
import '../widgets/achievements_section.dart';
import '../widgets/journey_card.dart';
import '../widgets/player_stats_grid.dart';
import '../widgets/recent_activity_section.dart';
import 'activity_history_screen.dart';

/// Progress screen — gameplay statistics and level progression.
///
/// Sections (in order):
/// 1. Page header — back button + Progress title
/// 2. Your Journey card — animated progress ring and encouraging text
/// 3. Player Stats — responsive two-column grid
/// 4. Recent Activity — horizontal list of completed levels
/// 5. Personal Bests — streak, perfect clears, total completed
///
/// Listens to [AppStore] changes so the UI updates when progress is saved.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    required this.store,
    this.embedded = false,
    this.onBackPressed,
    super.key,
  });

  final AppStore store;
  final bool embedded;
  final VoidCallback? onBackPressed;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreChanged);
    // Reconcile any rewards that should be unlocked based on current progress.
    widget.store.reconcileRewards(widget.store.completedLevels.length);
  }

  @override
  void didUpdateWidget(covariant ProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      oldWidget.store.removeListener(_onStoreChanged);
      widget.store.addListener(_onStoreChanged);
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleBack() {
    if (widget.embedded) {
      // Rendered inside the AppShell bottom navigation: select the Home tab.
      widget.onBackPressed?.call();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    // Standalone route fallback: land on the app home shell.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AppShell(store: widget.store)),
      (route) => false,
    );
  }

  void _openActivityHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityHistoryScreen(store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            // Page header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBright.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBright.withValues(
                            alpha: 0.25,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 24,
                      color: AppColors.primaryBright,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Back',
                      onPressed: _handleBack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Progress',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44), // Visual balance for back button
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  widget.embedded ? 120 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // Your Journey card
                    JourneyCard(store: widget.store),

                    const SizedBox(height: 24),

                    // Player Stats
                    PlayerStatsGrid(store: widget.store),

                    const SizedBox(height: 24),

                    // Recent Activity
                    RecentActivitySection(
                      store: widget.store,
                      onViewAll: _openActivityHistory,
                    ),

                    const SizedBox(height: 24),

                    // Personal Bests
                    AchievementsSection(store: widget.store),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
