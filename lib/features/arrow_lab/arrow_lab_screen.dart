import 'package:flutter/material.dart';

import '../../core/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/arrowbox_widgets.dart';
import '../arrow_designs/arrow_designs.dart';
import '../auth/login_profile_button.dart';

/// Arrow Lab is only the appearance editor. The same [AppStore] skin and
/// board theme drive the live preview and the real gameplay board.
class ArrowLabScreen extends StatelessWidget {
  const ArrowLabScreen({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final selectedSkin = ArrowSkinRegistry.byId(store.arrowSkinId);
          final selectedTheme = BoardThemeRegistry.byId(store.boardThemeId);
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth < 340 ? 2 : 3;
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
                        children: [
                          const Text(
                            'Arrow Appearance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Personalize your puzzle experience.',
                            style: TextStyle(
                              color: Color(0xFF8AA0BE),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ArrowSkinPreviewBoard(
                              skin: selectedSkin,
                              theme: selectedTheme,
                              size: (constraints.maxWidth - 80).clamp(160, 240),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _SubHeader(title: 'ARROW STYLE'),
                          const SizedBox(height: 12),
                          _SkinSelector(store: store, columns: columns),
                          const SizedBox(height: 20),
                          const _SubHeader(title: 'BOARD THEME'),
                          const SizedBox(height: 10),
                          _ThemeSelector(store: store),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          ArrowBoxLogoMark(size: 32),
          SizedBox(width: 12),
          ArrowBoxTitle(fontSize: 22),
          Spacer(),
          LoginProfileButton(),
        ],
      ),
    );
  }
}

class _SkinSelector extends StatelessWidget {
  const _SkinSelector({required this.store, required this.columns});

  final AppStore store;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final skins = ArrowSkinRegistry.all.take(6).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: skins.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: columns == 2 ? 1.15 : 0.9,
      ),
      itemBuilder: (context, index) {
        final skin = skins[index];
        final isSelected = skin.id == store.arrowSkinId;
        return _SelectionCard(
          isSelected: isSelected,
          onTap: () => store.setArrowSkin(skin.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              skin.buildArrow(direction: ArrowDirection.up, size: 32),
              const SizedBox(height: 8),
              Text(
                skin.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF8AA0BE),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final themes = BoardThemeRegistry.all;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: themes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.05,
      ),
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = theme.id == store.boardThemeId;
        return _ThemeSelectionCard(
          isSelected: isSelected,
          onTap: () => store.setBoardTheme(theme.id),
          theme: theme,
        );
      },
    );
  }
}

class _ThemeSelectionCard extends StatelessWidget {
  const _ThemeSelectionCard({
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final BoardTheme theme;

  static const _radius = 14.0;
  static const _badgeSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF15243D) : AppColors.darkCard,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: isSelected ? AppColors.cyan : const Color(0xFF243656),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_radius),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 32, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: theme.background,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.border, width: 2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            theme.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFC5D2E6),
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ThemeStrip(theme: theme),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: const _SelectionBadge(size: _badgeSize),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A short sample of the theme's board, cell, and frame colors.
class _ThemeStrip extends StatelessWidget {
  const _ThemeStrip({required this.theme});

  final BoardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: theme.border),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.cell,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.frame,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  const _SelectionBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.cyan,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
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

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0x141685FF) : const Color(0xFF14223B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.cyan : const Color(0xFF243656),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.28),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: child,
        ),
      ),
    );
  }
}
