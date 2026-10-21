import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models.dart';
import '../game_details/game_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<GameModel> favorites;
  final ValueChanged<GameModel> onFavoriteToggle;
  final ValueChanged<GameModel> onGameTap;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onFavoriteToggle,
    required this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const EmptyState(
              emoji: '❤️',
              heading: 'No favorites yet',
              message: 'Tap the heart icon on any game to save it here.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: favorites.length,
              itemBuilder: (ctx, i) {
                final game = favorites[i];
                return GameCard(
                  game: game,
                  isFavorite: true,
                  onTap: () {
                    onGameTap(game);
                    Navigator.push(ctx, MaterialPageRoute(builder: (_) => GameDetailsScreen(
                      game: game,
                      isFavorite: true,
                      onFavoriteToggle: () => onFavoriteToggle(game),
                    )));
                  },
                  onFavoriteTap: () => onFavoriteToggle(game),
                );
              },
            ),
    );
  }
}
