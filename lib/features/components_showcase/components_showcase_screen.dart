import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/filter_chip_row.dart';
import '../../core/widgets/search_bar_widget.dart';
import '../../data/game_data.dart';

class ComponentsShowcaseScreen extends StatelessWidget {
  const ComponentsShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('UI Components')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section('Buttons', [
            PrimaryButton(label: 'Primary Button', icon: Icons.play_arrow_rounded, onPressed: () {}),
            const SizedBox(height: 10),
            SecondaryButton(label: 'Secondary Button', onPressed: () {}),
          ]),
          _Section('Search', [
            const AppSearchBar(),
          ]),
          _Section('Filter Chips', [
            FilterChipRow(
              options: const ['All', 'Puzzle', 'Board', 'Arcade'],
              selected: 'All',
              onSelected: (_) {},
            ),
          ]),
          _Section('Game Cards', [
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (_, i) => Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                  child: SizedBox(
                    width: 110,
                    child: GameCard(game: allGames[i], onTap: () {}),
                  ),
                ),
              ),
            ),
          ]),
          _Section('Empty State', [
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const EmptyState(
                emoji: '🔍',
                heading: 'No games found',
                message: 'Try a different name or explore our categories.',
              ),
            ),
          ]),
          _Section('Color Palette', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorSwatch('Primary', AppColors.primary),
                _ColorSwatch('Success', AppColors.success),
                _ColorSwatch('Warning', AppColors.warning),
                _ColorSwatch('Error', AppColors.error),
                _ColorSwatch('Purple', AppColors.purple),
                _ColorSwatch('Board', AppColors.boardDark),
              ],
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionHeading),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String name;
  final Color color;
  const _ColorSwatch(this.name, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
