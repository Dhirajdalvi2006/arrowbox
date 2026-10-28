import 'package:flutter/material.dart';

import '../../core/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../arrow_designs/arrow_designs.dart';

class ArrowLabScreen extends StatelessWidget {
  const ArrowLabScreen({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final selectedSkin = ArrowSkinRegistry.byId(store.arrowSkinId);
    final selectedTheme = BoardThemeRegistry.byId(store.boardThemeId);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Text(
              'Arrow Lab',
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Shape the board to match your style.',
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _PreviewPanel(skin: selectedSkin, theme: selectedTheme),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Arrow styles'),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 620
                    ? 4
                    : constraints.maxWidth >= 380
                    ? 2
                    : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ArrowSkinRegistry.all.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: columns == 1 ? 2.3 : 1.18,
                  ),
                  itemBuilder: (context, index) => _SkinCard(
                    skin: ArrowSkinRegistry.all[index],
                    selected:
                        ArrowSkinRegistry.all[index].id == store.arrowSkinId,
                    onTap: () =>
                        store.setArrowSkin(ArrowSkinRegistry.all[index].id),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Board surface'),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 620 ? 4 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: BoardThemeRegistry.all.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    final theme = BoardThemeRegistry.all[index];
                    return _ThemeCard(
                      theme: theme,
                      selected: theme.id == store.boardThemeId,
                      onTap: () => store.setBoardTheme(theme.id),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.skin, required this.theme});
  final ArrowSkin skin;
  final BoardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.getBorder(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.frame,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.frameBorder),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  children: [
                    skin.buildArrow(direction: ArrowDirection.up, size: 40),
                    _PreviewCell(theme: theme),
                    skin.buildArrow(direction: ArrowDirection.right, size: 40),
                    _PreviewCell(theme: theme),
                    _PreviewCell(theme: theme),
                    skin.buildArrow(direction: ArrowDirection.down, size: 40),
                    _PreviewCell(theme: theme),
                    skin.buildArrow(direction: ArrowDirection.left, size: 40),
                    _PreviewCell(theme: theme),
                    _PreviewCell(theme: theme),
                    skin.buildArrow(direction: ArrowDirection.up, size: 40),
                    _PreviewCell(theme: theme),
                    skin.buildArrow(direction: ArrowDirection.right, size: 40),
                    _PreviewCell(theme: theme),
                    skin.buildArrow(direction: ArrowDirection.down, size: 40),
                    _PreviewCell(theme: theme),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skin.name,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  skin.description,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  theme.name,
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _PreviewCell extends StatelessWidget {
  const _PreviewCell({required this.theme});
  final BoardTheme theme;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: theme.cell,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: theme.border),
    ),
  );
}

class _SkinCard extends StatelessWidget {
  const _SkinCard({
    required this.skin,
    required this.selected,
    required this.onTap,
  });
  final ArrowSkin skin;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '${skin.name} arrow style${selected ? ', selected' : ''}',
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.getCard(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primaryBright
                : AppColors.getBorder(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            skin.buildArrow(
              direction: ArrowDirection.right,
              size: 52,
              highlighted: selected,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    skin.name,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skin.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryBright,
                size: 22,
              ),
          ],
        ),
      ),
    ),
  );
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });
  final BoardTheme theme;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? AppColors.primaryBright
              : AppColors.getBorder(context),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.frame,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.frameBorder),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 34,
                  decoration: BoxDecoration(
                    color: theme.cell,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.border),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  theme.name,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryBright,
                  size: 18,
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      color: AppColors.getTextPrimary(context),
      fontSize: 18,
      fontWeight: FontWeight.w800,
    ),
  );
}
