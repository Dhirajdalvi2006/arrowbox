import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/search_bar_widget.dart';
import '../../core/widgets/game_thumbnail.dart';
import '../../data/game_data.dart';
import '../../data/models.dart';
import '../game_details/game_details_screen.dart';
import '../games/all_games_screen.dart';
import '../categories/categories_screen.dart';
import '../search/search_screen.dart';
import '../recent/recent_screen.dart';
import '../favorites/favorites_screen.dart';
import '../settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final List<GameModel> _favorites = [];
  final List<GameModel> _recent = [
    allGames[0], allGames[7], allGames[6], allGames[2], allGames[3],
  ];

  void _toggleFavorite(GameModel game) {
    setState(() {
      if (_favorites.any((f) => f.id == game.id)) {
        _favorites.removeWhere((f) => f.id == game.id);
      } else {
        _favorites.add(game);
      }
    });
  }

  void _addToRecent(GameModel game) {
    setState(() {
      _recent.removeWhere((g) => g.id == game.id);
      _recent.insert(0, game);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        favorites: _favorites,
        recent: _recent,
        onFavoriteToggle: _toggleFavorite,
        onGameTap: _addToRecent,
      ),
      AllGamesScreen(
        favorites: _favorites,
        onFavoriteToggle: _toggleFavorite,
        onGameTap: _addToRecent,
      ),
      FavoritesScreen(
        favorites: _favorites,
        onFavoriteToggle: _toggleFavorite,
        onGameTap: _addToRecent,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardWhite,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Games'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favorites'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<GameModel> favorites;
  final List<GameModel> recent;
  final ValueChanged<GameModel> onFavoriteToggle;
  final ValueChanged<GameModel> onGameTap;

  const HomeScreen({
    super.key,
    required this.favorites,
    required this.recent,
    required this.onFavoriteToggle,
    required this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    final popular = allGames.take(6).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: AppSearchBar(
                  readOnly: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildFeaturedBanner(context)),
            SliverToBoxAdapter(child: _buildCategories(context)),
            SliverToBoxAdapter(child: _buildPopularGames(context, popular)),
            SliverToBoxAdapter(child: _buildRecentGames(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF1A6FE0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('🎮', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Offline Games', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('Play anytime, anywhere', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: GestureDetector(
        onTap: () {
          onGameTap(allGames[0]);
          Navigator.push(context, MaterialPageRoute(builder: (_) => GameDetailsScreen(game: allGames[0], isFavorite: favorites.any((f) => f.id == allGames[0].id), onFavoriteToggle: () => onFavoriteToggle(allGames[0]))));
        },
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A6FE0), AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: -12,
                child: Text('🎯', style: TextStyle(fontSize: 80, shadows: [Shadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12)])),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 6),
                    const Text('ArrowBox', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    const Text('Slide arrows, clear the board', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Play Now', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final cats = [
      ('🧩', 'Puzzle', AppColors.categoryPuzzle),
      ('♟️', 'Board', AppColors.categoryBoard),
      ('🕹️', 'Arcade', AppColors.categoryArcade),
      ('🧠', 'Brain', AppColors.categoryBrain),
      ('♠️', 'Classic', AppColors.categoryClassic),
      ('⚡', 'Quick', AppColors.categoryQuick),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Categories',
            actionLabel: 'See All',
            onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: cats.map((cat) => GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
              child: Container(
                decoration: BoxDecoration(
                  color: cat.$3,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cat.$1, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(cat.$2, style: AppTextStyles.label.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularGames(BuildContext context, List<GameModel> popular) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SectionHeader(
              title: 'Popular Games',
              actionLabel: 'See All',
              onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllGamesScreen(favorites: favorites, onFavoriteToggle: onFavoriteToggle, onGameTap: onGameTap))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popular.length,
              itemBuilder: (ctx, i) {
                final game = popular[i];
                return Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 10, right: i == popular.length - 1 ? 16 : 0),
                  child: SizedBox(
                    width: 110,
                    child: GameCard(
                      game: game,
                      isFavorite: favorites.any((f) => f.id == game.id),
                      onTap: () {
                        onGameTap(game);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => GameDetailsScreen(game: game, isFavorite: favorites.any((f) => f.id == game.id), onFavoriteToggle: () => onFavoriteToggle(game))));
                      },
                      onFavoriteTap: () => onFavoriteToggle(game),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGames(BuildContext context) {
    if (recent.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SectionHeader(
              title: 'Recently Played',
              actionLabel: 'See All',
              onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecentScreen(recent: recent, onGameTap: (g) { onGameTap(g); }))),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recent.take(8).length,
              itemBuilder: (ctx, i) {
                final game = recent[i];
                return Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 10, right: i == recent.length - 1 ? 16 : 0),
                  child: GestureDetector(
                    onTap: () {
                      onGameTap(game);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => GameDetailsScreen(game: game, isFavorite: favorites.any((f) => f.id == game.id), onFavoriteToggle: () => onFavoriteToggle(game))));
                    },
                    child: GameThumbnail(emoji: game.emoji, size: 72),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
