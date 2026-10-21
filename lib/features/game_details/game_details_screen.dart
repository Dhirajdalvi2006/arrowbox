import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models.dart';
import '../arrowbox/arrowbox_screen.dart';

class GameDetailsScreen extends StatefulWidget {
  final GameModel game;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const GameDetailsScreen({
    super.key,
    required this.game,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFav ? AppColors.error : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() => _isFav = !_isFav);
              widget.onFavoriteToggle();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: _categoryColor(),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Center(child: Text(game.emoji, style: const TextStyle(fontSize: 80))),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(game.title, style: AppTextStyles.mainHeading),
            ),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                spacing: 8,
                children: [
                  _Tag(game.category, AppColors.primaryLight, AppColors.primary),
                  _Tag(game.difficulty, _difficultyBg(), _difficultyColor()),
                  _Tag('Offline', AppColors.categoryBoard, AppColors.success),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('About this game', style: AppTextStyles.sectionHeading),
            const SizedBox(height: 8),
            Text(game.description, style: AppTextStyles.body.copyWith(height: 1.7)),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Play Now',
              icon: Icons.play_arrow_rounded,
              fullWidth: true,
              onPressed: () {
                if (game.id == 'arrowbox') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ArrowBoxScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${game.title} coming soon!'), behavior: SnackBarBehavior.floating),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor() {
    switch (widget.game.category) {
      case 'Puzzle': return AppColors.categoryPuzzle;
      case 'Board': return AppColors.categoryBoard;
      case 'Arcade': return AppColors.categoryArcade;
      case 'Brain': return AppColors.categoryBrain;
      case 'Classic': return AppColors.categoryClassic;
      case 'Quick': return AppColors.categoryQuick;
      default: return AppColors.primaryLight;
    }
  }

  Color _difficultyColor() {
    switch (widget.game.difficulty) {
      case 'Easy': return AppColors.success;
      case 'Hard': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  Color _difficultyBg() {
    switch (widget.game.difficulty) {
      case 'Easy': return const Color(0xFFE8FAF2);
      case 'Hard': return const Color(0xFFFFEEEF);
      default: return const Color(0xFFFFF8E6);
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Tag(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTextStyles.label.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
