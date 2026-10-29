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
              'Workbench',
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _WorkbenchHeroPanel(skin: selectedSkin, theme: selectedTheme),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Available Styles'),
            const SizedBox(height: 10),
            _VariantTray(
              items: ArrowSkinRegistry.all,
              selectedId: store.arrowSkinId,
              onTap: (id) => store.setArrowSkin(id as ArrowSkinId),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: 'Available Themes'),
            const SizedBox(height: 10),
            _VariantTray(
              items: BoardThemeRegistry.all,
              selectedId: store.boardThemeId,
              onTap: (id) => store.setBoardTheme(id as BoardThemeId),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkbenchHeroPanel extends StatelessWidget {
  const _WorkbenchHeroPanel({required this.skin, required this.theme});
  final ArrowSkin skin;
  final BoardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.getBorder(context)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.frame,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.frameBorder),
            ),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: Center(
                child: skin.buildArrow(direction: ArrowDirection.up, size: 80),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            skin.name,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            theme.name,
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantTray extends StatelessWidget {
  const _VariantTray({
    required this.items,
    required this.selectedId,
    required this.onTap,
  });
  final List<dynamic> items;
  final dynamic selectedId;
  final Function(dynamic) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.id == selectedId;
          return InkWell(
            onTap: () => onTap(item.id),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.getCard(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBright
                      : AppColors.getBorder(context),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  item.name[0],
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Text(
      title,
      style: TextStyle(
        color: AppColors.getTextMuted(context),
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );
}
