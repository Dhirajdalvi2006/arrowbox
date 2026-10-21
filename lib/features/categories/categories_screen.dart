import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/game_data.dart';
import '../../data/models.dart';
import '../games/all_games_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allCategories.length,
        itemBuilder: (ctx, i) {
          final cat = allCategories[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CategoryCard(category: cat),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  const _CategoryCard({required this.category});

  Color get _bgColor {
    switch (category.id) {
      case 'puzzle': return AppColors.categoryPuzzle;
      case 'board': return AppColors.categoryBoard;
      case 'arcade': return AppColors.categoryArcade;
      case 'brain': return AppColors.categoryBrain;
      case 'classic': return AppColors.categoryClassic;
      case 'quick': return AppColors.categoryQuick;
      default: return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => AllGamesScreen(
          favorites: const [],
          onFavoriteToggle: (_) {},
          onGameTap: (_) {},
        ),
      )),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(category.emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: AppTextStyles.sectionHeading),
                  const SizedBox(height: 3),
                  Text(category.description, style: AppTextStyles.body),
                  const SizedBox(height: 6),
                  Text('${category.gameCount} games', style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
