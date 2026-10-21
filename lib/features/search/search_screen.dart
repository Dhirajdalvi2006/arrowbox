import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/game_data.dart';
import '../../data/models.dart';
import '../game_details/game_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  final _recent = ['ArrowBox', 'Chess', 'Snake'];

  List<GameModel> get _results {
    if (_query.length < 2) return [];
    return allGames.where((g) => g.title.toLowerCase().contains(_query.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search games...',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            fillColor: Colors.transparent,
            filled: true,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () { _controller.clear(); setState(() => _query = ''); },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _buildInitialState()
          : results.isEmpty
              ? EmptyState(
                  emoji: '🔍',
                  heading: 'No games found',
                  message: 'Try a different name or explore our categories.',
                  buttonLabel: 'Browse All Games',
                  onButton: () => Navigator.pop(context),
                )
              : _buildResults(results),
    );
  }

  Widget _buildInitialState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_recent.isNotEmpty) ...[
          Text('Recent Searches', style: AppTextStyles.sectionHeading),
          const SizedBox(height: 12),
          ..._recent.map((r) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, color: AppColors.textSecondary, size: 20),
            title: Text(r, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
            trailing: const Icon(Icons.north_west, size: 16, color: AppColors.textSecondary),
            onTap: () { _controller.text = r; setState(() => _query = r); },
          )),
          const SizedBox(height: 24),
        ],
        Text('Suggested Games', style: AppTextStyles.sectionHeading),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allGames.take(8).map((g) => GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GameDetailsScreen(game: g, isFavorite: false, onFavoriteToggle: () {}))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(g.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(g.title, style: AppTextStyles.chipLabel.copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildResults(List<GameModel> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (ctx, i) {
        final game = results[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(game.emoji, style: const TextStyle(fontSize: 24))),
            ),
            title: Text(game.title, style: AppTextStyles.gameTitle.copyWith(fontSize: 15)),
            subtitle: Text('${game.category} · ${game.difficulty}', style: AppTextStyles.label),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => GameDetailsScreen(game: game, isFavorite: false, onFavoriteToggle: () {}))),
          ),
        );
      },
    );
  }
}
