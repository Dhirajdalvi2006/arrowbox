import 'package:flutter/material.dart';

import '../../../core/admin_access_service.dart';
import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';
import '../../arrowbox/arrowbox_logic.dart';
import '../../arrowbox/arrowbox_screen.dart';
import '../../arrowbox/levels/level_catalog.dart';
import '../../shell/app_shell.dart';
import '../widgets/level_tile.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({
    required this.store,
    this.embedded = false,
    this.onBackPressed,
    super.key,
  });
  final AppStore store;
  final bool embedded;
  final VoidCallback? onBackPressed;

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final _searchController = TextEditingController();
  ArrowBoxDifficulty? _difficultyFilter;

  AppStore get store => widget.store;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else if (widget.embedded) {
      // Embedded without callback
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppShell(store: store)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = store.completedLevels.length;
    final query = _searchController.text.trim();
    final filteredLevels =
        List<int>.generate(AppStore.totalLevels, (index) => index + 1).where((
          level,
        ) {
          final matchesQuery =
              query.isEmpty || level.toString().contains(query);
          final difficulty = LevelCatalog.difficultyFor(level);
          return matchesQuery &&
              (_difficultyFilter == null || difficulty == _difficultyFilter);
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  ArrowBoxHeaderIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: _handleBack,
                  ),
                  Expanded(
                    child: Text(
                      'Select Level',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Completed Level Progress Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getCard(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.getBorder(context),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x22FFC107),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: AppColors.starGold,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$completedCount / ${AppStore.totalLevels}',
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Levels Completed',
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search level',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: AppColors.getCard(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.getBorder(context),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.getBorder(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<int>(
                    tooltip: 'Filter difficulty',
                    initialValue: _difficultyFilter?.index ?? -1,
                    onSelected: (value) => setState(
                      () => _difficultyFilter = value < 0
                          ? null
                          : ArrowBoxDifficulty.values[value],
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: -1, child: Text('All levels')),
                      ...ArrowBoxDifficulty.values.map(
                        (difficulty) => PopupMenuItem(
                          value: difficulty.index,
                          child: Text(difficulty.label),
                        ),
                      ),
                    ],
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.getCard(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.getBorder(context)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(Icons.tune_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: filteredLevels.length,
                itemBuilder: (context, index) {
                  final level = filteredLevels[index];
                  final isCompleted = store.completedLevels.contains(level);
                  final isCurrent =
                      level == store.unlockedLevel && !isCompleted;
                  final isLocked =
                      !AdminAccessService.isAdmin &&
                      level > store.unlockedLevel;
                  final difficulty = LevelCatalog.difficultyFor(level);

                  return Semantics(
                    label:
                        'Level $level, ${difficulty.label}${isLocked ? ', locked' : ''}',
                    button: !isLocked,
                    child: LevelTile(
                      level: level,
                      difficulty: difficulty,
                      isCompleted: isCompleted,
                      stars: store.levelStars[level] ?? 0,
                      isCurrent: isCurrent,
                      isLocked: isLocked,
                      onTap: isLocked
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArrowBoxScreen(
                                  store: store,
                                  initialState:
                                      store.savedGames[level] ??
                                      ArrowBoxState.initial(level: level),
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
