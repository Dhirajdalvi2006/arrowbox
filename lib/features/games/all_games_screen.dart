import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/search_bar_widget.dart';
import '../../core/widgets/filter_chip_row.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/game_data.dart';
import '../../data/models.dart';
import '../game_details/game_details_screen.dart';

class AllGamesScreen extends StatefulWidget {
  final List<GameModel> favorites;
  final ValueChanged<GameModel> onFavoriteToggle;
  final ValueChanged<GameModel> onGameTap;

  const AllGamesScreen({
    super.key,
    required this.favorites,
    required this.onFavoriteToggle,
    required this.onGameTap,
  });

  @override
  State<AllGamesScreen> createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen> {
  String _selectedFilter = 'All';
  String _query = '';
  final _controller = TextEditingController();

  final _filters = ['All', 'Puzzle', 'Board', 'Arcade', 'Brain', 'Classic', 'Quick'];

  List<GameModel> get _filtered {
    var games = allGames.where((g) {
      final matchesCat = _selectedFilter == 'All' || g.category == _selectedFilter;
      final matchesQ = _query.isEmpty || g.title.toLowerCase().contains(_query.toLowerCase());
      return matchesCat && matchesQ;
    }).toList();
    return games;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final games = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Games'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AppSearchBar(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: FilterChipRow(
              options: _filters,
              selected: _selectedFilter,
              onSelected: (f) => setState(() => _selectedFilter = f),
            ),
          ),
          Expanded(
            child: games.isEmpty
                ? EmptyState(
                    emoji: '🔍',
                    heading: 'No games found',
                    message: 'Try a different name or category.',
                    buttonLabel: 'Clear Filter',
                    onButton: () => setState(() { _selectedFilter = 'All'; _query = ''; _controller.clear(); }),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: games.length,
                    itemBuilder: (ctx, i) {
                      final game = games[i];
                      return GameCard(
                        game: game,
                        isFavorite: widget.favorites.any((f) => f.id == game.id),
                        onTap: () {
                          widget.onGameTap(game);
                          Navigator.push(ctx, MaterialPageRoute(builder: (_) => GameDetailsScreen(
                            game: game,
                            isFavorite: widget.favorites.any((f) => f.id == game.id),
                            onFavoriteToggle: () => widget.onFavoriteToggle(game),
                          )));
                        },
                        onFavoriteTap: () => widget.onFavoriteToggle(game),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
