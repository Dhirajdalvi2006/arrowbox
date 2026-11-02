import 'package:flutter/material.dart';

import '../../core/app_store.dart';
import '../../core/services/reward_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/arrowbox_widgets.dart';
import '../arrow_designs/arrow_designs.dart';
import '../auth/login_profile_button.dart';
import '../shell/app_shell.dart';

/// Arrow Lab — premium appearance customization screen.
///
/// Provides a unified catalog of arrow skins and board themes with
/// milestone-based unlocking driven by completed level count.
class ArrowLabScreen extends StatelessWidget {
  const ArrowLabScreen({
    required this.store,
    this.embedded = false,
    this.onBackPressed,
    super.key,
  });

  final AppStore store;
  final bool embedded;
  final VoidCallback? onBackPressed;

  static const double _bottomPadding = 140.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final selectedSkin = ArrowSkinRegistry.byId(store.arrowSkinId);
          final selectedTheme = BoardThemeRegistry.byId(store.boardThemeId);
          final completed = store.completedLevels.length;
          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Text(
                          'Arrow Appearance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                        child: Text(
                          'Personalize your puzzle experience.',
                          style: TextStyle(
                            color: Color(0xFF8AA0BE),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ArrowSkinPreviewBoard(
                          skin: selectedSkin,
                          theme: selectedTheme,
                          size: _previewBoardSize(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SubHeader(title: 'ARROW STYLE'),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                _SkinGrid(store: store, completed: completed),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: const _SubHeader(title: 'BOARD THEME'),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                _ThemeGrid(store: store, completed: completed),
                const SliverToBoxAdapter(
                  child: SizedBox(height: _bottomPadding),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _previewBoardSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width.toDouble();
    final heightCap = MediaQuery.of(context).size.height * 0.22;
    final size = (width - 90).clamp(160.0, 440.0);
    final maxByHeight = heightCap.clamp(160.0, double.infinity);
    return size.clamp(160.0, maxByHeight);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          ArrowBoxHeaderIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back to Home',
            size: 44,
            iconColor: AppColors.primaryBright,
            onPressed: () {
              if (onBackPressed != null) {
                onBackPressed!();
              } else if (embedded) {
                // embedded default
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AppShell(store: store)),
                );
              }
            },
          ),
          const SizedBox(width: 12),
          const ArrowBoxTitle(fontSize: 22),
          const Spacer(),
          const LoginProfileButton(),
        ],
      ),
    );
  }
}

/// ── Arrow Style grid ──────────────────────────────────────────────────────

class _SkinGrid extends StatelessWidget {
  const _SkinGrid({required this.store, required this.completed});

  final AppStore store;
  final int completed;

  int _requiredLevel(ArrowSkinId id) {
    try {
      return RewardService.arrowSkinMilestones
          .firstWhere((r) => r.rewardReference == id)
          .requiredCompletedLevels;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width < 480 ? 2 : 3;
    final skins = ArrowSkinRegistry.all;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 2 ? 1.2 : 1.1,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final skin = skins[index];
        final isSelected = skin.id == store.arrowSkinId;
        final isUnlocked = store.isArrowSkinUnlocked(skin.id);
        return _SkinCard(
          store: store,
          skin: skin,
          isSelected: isSelected,
          isUnlocked: isUnlocked,
          requiredLevel: _requiredLevel(skin.id),
          completed: completed,
        );
      }, childCount: skins.length),
    );
  }
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.store,
    required this.skin,
    required this.isSelected,
    required this.isUnlocked,
    required this.requiredLevel,
    required this.completed,
  });

  final AppStore store;
  final ArrowSkin skin;
  final bool isSelected;
  final bool isUnlocked;
  final int requiredLevel;
  final int completed;

  bool get canEquip => isUnlocked && !isSelected;

  @override
  Widget build(BuildContext context) {
    final isLocked = !isUnlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryBright.withValues(alpha: 0.15)
            : AppColors.getCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryBright
              : isLocked
              ? AppColors.getBorder(context).withValues(alpha: 0.35)
              : AppColors.getBorder(context),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryBright.withValues(alpha: 0.30),
                  blurRadius: 12,
                  spreadRadius: -2,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: canEquip ? () => store.setArrowSkin(skin.id) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.getCard(context)
                        .withValues(alpha: isUnlocked ? 0.5 : 0.22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.getBorder(context)
                          .withValues(alpha: isUnlocked ? 0.5 : 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: isUnlocked ? 1.0 : 0.5,
                      child: skin.buildArrow(
                        direction: ArrowDirection.up,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  skin.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryBright
                        : isUnlocked
                        ? AppColors.getTextPrimary(context)
                        : AppColors.getTextMuted(context),
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBright.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'EQUIPPED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isUnlocked)
                  Text(
                    'Unlocked',
                    style: TextStyle(
                      color: AppColors.primaryBright,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Locked',
                        style: TextStyle(
                          color: AppColors.getTextMuted(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (requiredLevel > 0)
                        Text(
                          'Unlocks at Level $requiredLevel',
                          style: TextStyle(
                            color: AppColors.getTextMuted(context),
                            fontSize: 9,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ── Board Theme grid ──────────────────────────────────────────────────────

class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({required this.store, required this.completed});

  final AppStore store;
  final int completed;

  int _requiredLevel(BoardThemeId id) {
    try {
      return RewardService.boardThemeMilestones
          .firstWhere((r) => r.rewardReference == id)
          .requiredCompletedLevels;
    } catch (_) {
      return 0;
    }
  }

  double _themeAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 480 ? 2.1 : 2.4;
  }

  @override
  Widget build(BuildContext context) {
    final themes = BoardThemeRegistry.all;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _themeAspectRatio(context),
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final theme = themes[index];
        final isSelected = theme.id == store.boardThemeId;
        final isUnlocked = store.isBoardThemeUnlocked(theme.id);
        return _ThemeCard(
          store: store,
          theme: theme,
          isSelected: isSelected,
          isUnlocked: isUnlocked,
          requiredLevel: _requiredLevel(theme.id),
          completed: completed,
        );
      }, childCount: themes.length),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.store,
    required this.theme,
    required this.isSelected,
    required this.isUnlocked,
    required this.requiredLevel,
    required this.completed,
  });

  final AppStore store;
  final BoardTheme theme;
  final bool isSelected;
  final bool isUnlocked;
  final int requiredLevel;
  final int completed;

  bool get canEquip => isUnlocked && !isSelected;

  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final isLocked = !isUnlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF15243D)
            : AppColors.getCard(context),
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: isSelected
              ? AppColors.cyan
              : isLocked
              ? AppColors.getBorder(context).withValues(alpha: 0.35)
              : AppColors.getBorder(context),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canEquip ? () => store.setBoardTheme(theme.id) : null,
          borderRadius: BorderRadius.circular(_radius),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _ThemeMiniBoard(theme: theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        theme.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isUnlocked
                              ? const Color(0xFFC5D2E6)
                              : AppColors.getTextMuted(context),
                          fontSize: 13.5,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isSelected)
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                color: AppColors.cyan,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'EQUIPPED',
                                style: TextStyle(
                                  color: AppColors.cyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isUnlocked)
                        const Text(
                          'Unlocked',
                          style: TextStyle(
                            color: AppColors.primaryBright,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Locked',
                              style: TextStyle(
                                color: Color(0xFF8AA0BE),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (requiredLevel > 0)
                              Text(
                                'Level $requiredLevel',
                                style: TextStyle(
                                  color: AppColors.getTextMuted(context),
                                  fontSize: 9,
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
        ),
      ),
    );
  }
}

/// Compact miniature 3x3 board preview reflecting the theme's exact colors.
class _ThemeMiniBoard extends StatelessWidget {
  const _ThemeMiniBoard({required this.theme});

  final BoardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 1.2),
      ),
      padding: const EdgeInsets.all(4),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (index) {
          final isCenter = index == 4;
          return Container(
            decoration: BoxDecoration(
              color: isCenter ? theme.frame : theme.cell,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  const _SubHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF6E86A6),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}
