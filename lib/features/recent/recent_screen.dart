import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models.dart';
import '../game_details/game_details_screen.dart';

class RecentScreen extends StatelessWidget {
  final List<GameModel> recent;
  final ValueChanged<GameModel> onGameTap;

  const RecentScreen({super.key, required this.recent, required this.onGameTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Recently Played')),
      body: recent.isEmpty
          ? const EmptyState(
              emoji: '🕹️',
              heading: 'No recent games',
              message: 'Games you play will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recent.length,
              itemBuilder: (ctx, i) {
                final game = recent[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(game.emoji, style: const TextStyle(fontSize: 26))),
                    ),
                    title: Text(game.title, style: AppTextStyles.gameTitle.copyWith(fontSize: 15)),
                    subtitle: Text(
                      i == 0 ? 'Just now' : '${i + 1}h ago',
                      style: AppTextStyles.label,
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        onGameTap(game);
                        Navigator.push(ctx, MaterialPageRoute(builder: (_) => GameDetailsScreen(game: game, isFavorite: false, onFavoriteToggle: () {})));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Play', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
