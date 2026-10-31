import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';
import '../../arrow_lab/arrow_lab_screen.dart';
import '../../arrowbox/arrowbox_screen.dart';
import '../../how_to_play/screens/how_to_play_screen.dart';
import '../../level_selection/screens/level_selection_screen.dart';
import '../widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.store, super.key});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final completedCount = store.completedLevels.length;
    final progressRatio = (completedCount / AppStore.totalLevels).clamp(
      0.0,
      1.0,
    );

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          // Ambient Glow Background Accents
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.primary : AppColors.cyan).withValues(
                  alpha: isDark ? 0.15 : 0.08,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withValues(alpha: isDark ? 0.12 : 0.06),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed Header outside ScrollView
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: HomeHeader(store: store),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Immersive Central Hero Card with Glowing Aura
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      AppColors.getCard(context)
                                          .withValues(alpha: 0.85),
                                      AppColors.getCard(context)
                                          .withValues(alpha: 0.4),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.9),
                                      Colors.white.withValues(alpha: 0.6),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: AppColors.getBorder(context)
                                  .withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0x441685FF)
                                    : const Color(0x181685FF),
                                blurRadius: 36,
                                spreadRadius: 2,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Floating Hero Artwork with Subtle Pulse
                              const ArrowBoxHeroArtwork(size: 190),
                              const SizedBox(height: 20),
                              const ArrowBoxTitle(fontSize: 30),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.cyan.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  '✨ THINK • AIM • ESCAPE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.cyan,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Clear the intricate vector grid by masterminding the exact escape path for every arrow.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(context),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Primary Play & Continue CTAs
                        ArrowBoxPrimaryButton(
                          label: 'Play Adventure',
                          icon: Icons.play_arrow_rounded,
                          showTrailingChevron: true,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LevelSelectionScreen(store: store),
                            ),
                          ),
                        ),

                        if (store.hasSavedGame) ...[
                          const SizedBox(height: 12),
                          ArrowBoxSecondaryButton(
                            label: 'Continue Level ${store.savedGame!.level}',
                            icon: Icons.refresh_rounded,
                            showTrailingChevron: true,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArrowBoxScreen(
                                  store: store,
                                  initialState: store.savedGame,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Quick Access Modes Grid (Arrow Lab, How to Play)
                        Row(
                          children: [
                            Expanded(
                              child: ArrowBoxPressScale(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ArrowLabScreen(store: store),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.getCard(context),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.getBorder(context),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: AppColors.cyan.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.palette_rounded,
                                            color: AppColors.cyan,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Arrow Lab',
                                          style: TextStyle(
                                            color: AppColors.getTextPrimary(
                                              context,
                                            ),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Custom skins & themes',
                                          style: TextStyle(
                                            color: AppColors.getTextSecondary(
                                              context,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ArrowBoxPressScale(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HowToPlayScreen(),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.getCard(context),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.getBorder(context),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.help_outline_rounded,
                                            color: AppColors.primaryBright,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'How to Play',
                                          style: TextStyle(
                                            color: AppColors.getTextPrimary(
                                              context,
                                            ),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Rules & guide',
                                          style: TextStyle(
                                            color: AppColors.getTextSecondary(
                                              context,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Progress Summary Card (Linked to Level Selection / Progress)
                        ArrowBoxPressScale(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LevelSelectionScreen(store: store),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.getCard(context),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.getBorder(context),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.18,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.emoji_events_rounded,
                                          color: AppColors.primaryBright,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Player Mastery Progress',
                                              style: TextStyle(
                                                color: AppColors.getTextPrimary(
                                                  context,
                                                ),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '$completedCount of ${AppStore.totalLevels} levels conquered',
                                              style: TextStyle(
                                                color:
                                                    AppColors.getTextSecondary(
                                                      context,
                                                    ),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.cyan.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${(progressRatio * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: AppColors.cyan,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progressRatio,
                                      backgroundColor: AppColors.getBorder(
                                        context,
                                      ).withValues(alpha: 0.4),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryBright,
                                          ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

typedef WelcomeScreen = HomeScreen;
