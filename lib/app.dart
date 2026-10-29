import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/app_store.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/arrowbox_widgets.dart';
import 'features/arrowbox/arrowbox_dialogs.dart';
import 'features/arrowbox/arrowbox_logic.dart';
import 'features/arrowbox/arrowbox_screen.dart';
import 'features/arrowbox/levels/level_catalog.dart';
import 'features/shell/app_shell.dart';

class ArrowBoxApp extends StatelessWidget {
  const ArrowBoxApp({required this.store, super.key});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final screen = Uri.base.queryParameters['screen'];

    Widget getHome() {
      switch (screen) {
        case 'levels':
          return LevelSelectionScreen(store: store);
        case 'gameplay':
          return ArrowBoxScreen(
            store: store,
            initialState: ArrowBoxState.initial(level: 3),
          );
        case 'pause':
          return Scaffold(
            backgroundColor: Colors.black87,
            body: ArrowBoxPauseDialog(
              onResume: () {},
              onRestart: () {},
              onSettings: () {},
              onLevelSelection: () {},
              onMainMenu: () {},
            ),
          );
        case 'complete':
          return Scaffold(
            backgroundColor: Colors.black87,
            body: ArrowBoxLevelCompleteDialog(
              level: 3,
              moves: 6,
              mistakes: 0,
              hintsUsed: 0,
              stars: 3,
              seconds: 42,
              onNextLevel: () {},
              onReplayLevel: () {},
              onLevelSelection: () {},
              onMainMenu: () {},
            ),
          );
        case 'gameover':
          return Scaffold(
            backgroundColor: Colors.black87,
            body: ArrowBoxGameOverDialog(
              level: 3,
              mistakes: 3,
              onRestart: () {},
              onLevelSelection: () {},
              onMainMenu: () {},
            ),
          );
        case 'settings':
          return SettingsScreen(store: store);
        case 'progress':
          return ProgressScreen(store: store);
        case 'howtoplay':
          return const HowToPlayScreen();
        case 'about':
          return const AboutScreen();
        default:
          return AppShell(store: store);
      }
    }

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => MaterialApp(
        title: 'ArrowBox',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: store.themeMode,
        // Fix Flutter web text underlines globally
        builder: (context, child) => DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'Inter',
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          ),
          child: child!,
        ),
        home: getHome(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. LANDING SCREEN (Reference Screen 1)
// ---------------------------------------------------------------------------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({required this.store, super.key});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Mini Logo + Title and Theme Toggle + Settings
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 360;
                  final controlSize = compact ? 44.0 : 56.0;
                  return Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ArrowBoxLogoMark(size: 28),
                              SizedBox(width: 8),
                              ArrowBoxTitle(fontSize: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ArrowBoxHeaderIconButton(
                            size: controlSize,
                            icon: isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            tooltip: 'Toggle Theme',
                            onPressed: () {
                              final current = store.themeMode;
                              if (current == ThemeMode.dark) {
                                store.setThemeMode(ThemeMode.light);
                              } else {
                                store.setThemeMode(ThemeMode.dark);
                              }
                            },
                          ),
                          SizedBox(width: compact ? 4 : 8),
                          ArrowBoxHeaderIconButton(
                            size: controlSize,
                            icon: Icons.settings_rounded,
                            tooltip: 'Settings',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SettingsScreen(store: store),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 14),

              // Central app logo
              LayoutBuilder(
                builder: (context, constraints) {
                  final logoSize = (constraints.maxWidth * 0.48).clamp(
                    128.0,
                    180.0,
                  );
                  return Center(child: ArrowBoxLogoMark(size: logoSize));
                },
              ),

              const SizedBox(height: 18),

              // Title and Taglines
              const ArrowBoxTitle(fontSize: 34),
              const SizedBox(height: 6),
              const Text(
                'Think. Aim. Escape.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBright.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Clear the board by finding the right path\nfor every arrow.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Primary Play Button
              ArrowBoxPrimaryButton(
                label: 'Play Now',
                icon: Icons.play_arrow_rounded,
                showTrailingChevron: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LevelSelectionScreen(store: store),
                  ),
                ),
              ),

              // Secondary Continue Button (if saved progress exists)
              if (store.hasSavedGame) ...[
                const SizedBox(height: 12),
                ArrowBoxSecondaryButton(
                  label: 'Continue Level ${store.savedGame!.level}',
                  icon: Icons.refresh_rounded,
                  showTrailingChevron: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArrowBoxScreen(
                        store: store,
                        initialState: store.savedGame,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Bottom 3 Action Cards (Progress, How to Play, About)
              Row(
                children: [
                  ArrowBoxActionCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Progress',
                    subtitle:
                        '${store.completedLevels.length} / ${AppStore.totalLevels} levels',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgressScreen(store: store),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ArrowBoxActionCard(
                    icon: Icons.menu_book_rounded,
                    title: 'How to Play',
                    subtitle: 'Learn the rules',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HowToPlayScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ArrowBoxActionCard(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'Game info',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. LEVEL SELECTION SCREEN (Reference Screen 2)
// ---------------------------------------------------------------------------
class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({
    required this.store,
    this.embedded = false,
    super.key,
  });
  final AppStore store;
  final bool embedded;

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final _searchController = TextEditingController();
  ArrowBoxDifficulty? _difficultyFilter;

  AppStore get store => widget.store;

  Future<void> _openDebugLevel() async {
    final controller = TextEditingController();
    final level = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Open level'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '1-${AppStore.totalLevels}'),
          onSubmitted: (_) => Navigator.pop(
            dialogContext,
            int.tryParse(controller.text.trim()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              int.tryParse(controller.text.trim()),
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted ||
        level == null ||
        level < 1 ||
        level > AppStore.totalLevels) {
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArrowBoxScreen(
          store: store,
          initialState:
              store.savedGames[level] ?? ArrowBoxState.initial(level: level),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    onPressed: () => Navigator.pop(context),
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
                  if (kDebugMode)
                    IconButton(
                      tooltip: 'Debug: open level',
                      icon: const Icon(Icons.developer_mode_rounded),
                      onPressed: _openDebugLevel,
                    )
                  else
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
                  final isLocked = level > store.unlockedLevel;
                  final difficulty = LevelCatalog.difficultyFor(level);

                  return Semantics(
                    label:
                        'Level $level, ${difficulty.label}${isLocked ? ', locked' : ''}',
                    button: !isLocked,
                    child: _LevelTile(
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

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.difficulty,
    required this.isCompleted,
    required this.stars,
    required this.isCurrent,
    required this.isLocked,
    required this.onTap,
  });

  final int level;
  final ArrowBoxDifficulty difficulty;
  final bool isCompleted;
  final int stars;
  final bool isCurrent;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Border? border;

    if (isCompleted) {
      bg = AppColors.primary;
    } else if (isCurrent) {
      bg = AppColors.getSurfaceElevated(context);
      border = Border.all(color: AppColors.primaryBright, width: 2);
    } else {
      bg = AppColors.getCard(context);
      border = Border.all(color: AppColors.getBorder(context), width: 1);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: border,
            boxShadow: isCompleted
                ? const [
                    BoxShadow(
                      color: Color(0x40247BFF),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$level',
                style: TextStyle(
                  color: isLocked
                      ? AppColors.getTextMuted(context)
                      : AppColors.getTextPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                difficulty == ArrowBoxDifficulty.ultraHard
                    ? 'Ultra'
                    : difficulty.label,
                style: TextStyle(
                  color: isLocked
                      ? AppColors.getTextMuted(context)
                      : AppColors.getTextSecondary(context),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              if (isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: index < stars
                          ? AppColors.starGold
                          : AppColors.getTextMuted(context),
                      size: 13,
                    ),
                  ),
                )
              else if (isLocked)
                Icon(
                  Icons.lock_rounded,
                  color: AppColors.getTextMuted(context),
                  size: 14,
                )
              else
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. SETTINGS SCREEN (Reference Screen 7)
// ---------------------------------------------------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.store, this.embedded = false, super.key});
  final AppStore store;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
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
                    onPressed: embedded ? () {} : () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Settings',
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

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: [
                  // GAMEPLAY SECTION
                  const _SettingsSectionHeader(title: 'GAMEPLAY'),
                  _SettingsContainer(
                    children: [
                      _SettingsSwitchRow(
                        icon: Icons.vibration_rounded,
                        title: 'Haptic feedback',
                        value: store.hapticsEnabled,
                        onChanged: (v) => store.setBool('hapticsEnabled', v),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      _SettingsSwitchRow(
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'Show hints',
                        value: store.hintsEnabled,
                        onChanged: (v) => store.setBool('hintsEnabled', v),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      _SettingsSwitchRow(
                        icon: Icons.help_outline_rounded,
                        title: 'Confirm before restart',
                        value: store.confirmRestart,
                        onChanged: (v) => store.setBool('confirmRestart', v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // AUDIO SECTION
                  const _SettingsSectionHeader(title: 'AUDIO'),
                  _SettingsContainer(
                    children: [
                      _SettingsSwitchRow(
                        icon: Icons.music_note_rounded,
                        title: 'Sound effects',
                        value: store.soundEnabled,
                        onChanged: (v) => store.setBool('soundEnabled', v),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      _SettingsSwitchRow(
                        icon: Icons.queue_music_rounded,
                        title: 'Background music',
                        value: store.musicEnabled,
                        onChanged: (v) => store.setBool('musicEnabled', v),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.volume_up_rounded,
                              color: AppColors.primaryBright,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Music volume',
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.primaryBright,
                                  inactiveTrackColor: AppColors.getBorder(
                                    context,
                                  ),
                                  thumbColor: AppColors.getTextPrimary(context),
                                  overlayColor: const Color(0x33247BFF),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: store.musicVolume,
                                  onChanged: (val) =>
                                      store.setDouble('musicVolume', val),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // APPEARANCE SECTION
                  const _SettingsSectionHeader(title: 'APPEARANCE'),
                  _SettingsContainer(
                    children: [
                      _SettingsRadioRow(
                        title: 'System theme',
                        selected: store.themeMode == ThemeMode.system,
                        onTap: () => store.setThemeMode(ThemeMode.system),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      _SettingsRadioRow(
                        title: 'Light theme',
                        selected: store.themeMode == ThemeMode.light,
                        onTap: () => store.setThemeMode(ThemeMode.light),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      _SettingsRadioRow(
                        title: 'Dark theme',
                        selected: store.themeMode == ThemeMode.dark,
                        onTap: () => store.setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // DATA SECTION
                  const _SettingsSectionHeader(title: 'DATA'),
                  Row(
                    children: [
                      Expanded(
                        child: ArrowBoxSecondaryButton(
                          label: 'Reset Settings',
                          icon: Icons.restore_rounded,
                          onPressed: () => _confirm(
                            context,
                            'Reset settings?',
                            'All settings will return to defaults. Progress is kept.',
                            store.resetSettings,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ArrowBoxSecondaryButton(
                          label: 'Reset Progress',
                          icon: Icons.delete_outline_rounded,
                          isDanger: true,
                          onPressed: () => _confirm(
                            context,
                            'Reset progress?',
                            'All completed levels and saved games will be permanently erased.',
                            store.resetProgress,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'ArrowBox 1.0.0',
                      style: TextStyle(
                        color: AppColors.getTextMuted(context),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    String title,
    String message,
    Future<void> Function() action,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.getBorder(context)),
        ),
        title: Text(
          title,
          style: TextStyle(color: AppColors.getTextPrimary(context)),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.getTextSecondary(context)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await action();
    }
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryBright,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsContainer extends StatelessWidget {
  const _SettingsContainer({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBright, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.primary,
            activeThumbColor: AppColors.getTextPrimary(context),
            inactiveTrackColor: AppColors.getBorder(context),
            inactiveThumbColor: AppColors.getTextMuted(context),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsRadioRow extends StatelessWidget {
  const _SettingsRadioRow({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primaryBright
                      : AppColors.getTextMuted(context),
                  width: selected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? AppColors.getTextPrimary(context)
                    : AppColors.getTextSecondary(context),
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. PROGRESS SCREEN (Reference Screen 8)
// ---------------------------------------------------------------------------
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({required this.store, this.embedded = false, super.key});
  final AppStore store;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final completedCount = store.completedLevels.length;
    final progressRatio = (completedCount / AppStore.totalLevels).clamp(
      0.0,
      1.0,
    );

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
                    onPressed: embedded ? () {} : () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Progress',
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

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: [
                  // Circular Progress Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: AppColors.getCard(context),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.getBorder(context),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(140, 140),
                                painter: _CircularProgressPainter(
                                  progress: progressRatio,
                                  trackColor: AppColors.getBorder(context),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.starGold,
                                    size: 36,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$completedCount / ${AppStore.totalLevels}',
                                    style: TextStyle(
                                      color: AppColors.getTextPrimary(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Levels Completed',
                                    style: TextStyle(
                                      color: AppColors.getTextSecondary(
                                        context,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2x2 Metric Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.grid_view_rounded,
                          iconColor: AppColors.primaryBright,
                          label: 'Total Levels',
                          value: '${AppStore.totalLevels}',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.flag_rounded,
                          iconColor: AppColors.error,
                          label: 'Current Level',
                          value: '${store.unlockedLevel}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.sports_esports_rounded,
                          iconColor: AppColors.cyan,
                          label: 'Games Played',
                          value: '${store.gamesPlayed}',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _MetricCard(
                          icon: Icons.warning_amber_rounded,
                          iconColor: AppColors.warning,
                          label: 'Total Mistakes',
                          value: '${store.totalMistakes}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  const _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
  });
  final double progress;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    if (sweepAngle > 0) {
      final progressPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF247BFF), Color(0xFF21D4FD)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.trackColor != trackColor;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 9. HOW TO PLAY SCREEN (Reference Screen 9)
// ---------------------------------------------------------------------------
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'How to Play',
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

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: const [
                  _TutorialStepCard(
                    step: 1,
                    title: 'Each block has a direction',
                    subtitle:
                        'Arrows can only move in the direction they point.',
                    visual: _Step1Visual(),
                  ),
                  SizedBox(height: 16),
                  _TutorialStepCard(
                    step: 2,
                    title: 'Clear path to the edge',
                    subtitle:
                        'An arrow escapes if there are no blocks in its path.',
                    visual: _Step2Visual(),
                  ),
                  SizedBox(height: 16),
                  _TutorialStepCard(
                    step: 3,
                    title: 'Remove the block',
                    subtitle:
                        'When an arrow escapes, it is removed from the board.',
                    visual: _Step3Visual(),
                  ),
                  SizedBox(height: 16),
                  _TutorialStepCard(
                    step: 4,
                    title: 'Complete the level',
                    subtitle: 'Clear all arrows to complete the level.',
                    visual: _Step4Visual(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStepCard extends StatelessWidget {
  const _TutorialStepCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.visual,
  });

  final int step;
  final String title;
  final String subtitle;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceElevated(context),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(child: visual),
        ],
      ),
    );
  }
}

class _Step1Visual extends StatelessWidget {
  const _Step1Visual();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.arrowUpGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.arrow_upward_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class _Step2Visual extends StatelessWidget {
  const _Step2Visual();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _miniTile(AppColors.arrowUpGradient, Icons.arrow_upward_rounded),
        const SizedBox(width: 8),
        _miniEmpty(context),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.cyan,
          size: 18,
        ),
        const SizedBox(width: 8),
        _miniTile(AppColors.arrowUpGradient, Icons.arrow_upward_rounded),
      ],
    );
  }

  Widget _miniTile(List<Color> colors, IconData icon) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );

  Widget _miniEmpty(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: AppColors.getSecondaryBackground(context),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.getBorder(context)),
    ),
  );
}

class _Step3Visual extends StatelessWidget {
  const _Step3Visual();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.arrowRightGradient,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        _miniEmpty(context),
        const SizedBox(width: 8),
        _miniEmpty(context),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.warning,
          size: 18,
        ),
      ],
    );
  }

  Widget _miniEmpty(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: AppColors.getSecondaryBackground(context),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.getBorder(context)),
    ),
  );
}

class _Step4Visual extends StatelessWidget {
  const _Step4Visual();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x2221D98B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4421D98B)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          SizedBox(width: 8),
          Text(
            'Board Cleared!',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 10. ABOUT SCREEN (Reference Screen 10)
// ---------------------------------------------------------------------------
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'About',
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                child: Column(
                  children: [
                    const ArrowBoxHeroArtwork(size: 160),
                    const SizedBox(height: 18),
                    Text(
                      'ArrowBox',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Think. Aim. Escape.',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A minimalist puzzle game where you clear\nthe board by finding the right paths for each arrow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Version Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.getCard(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.getBorder(context),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: AppColors.getTextPrimary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '© 2026 ArrowBox',
                            style: TextStyle(
                              color: AppColors.getTextMuted(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Privacy Policy Row
                    _AboutActionRow(
                      icon: Icons.description_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _showTextDialog(
                        context,
                        'Privacy Policy',
                        'ArrowBox operates entirely offline. No personal data, tracking, or device identifiers are collected or transmitted.',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Credits Row
                    _AboutActionRow(
                      icon: Icons.people_outline_rounded,
                      title: 'Credits',
                      onTap: () => _showTextDialog(
                        context,
                        'Credits',
                        'ArrowBox was crafted with love as a modern Flutter puzzle game experience.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextDialog(BuildContext context, String title, String content) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.getBorder(context)),
        ),
        title: Text(
          title,
          style: TextStyle(color: AppColors.getTextPrimary(context)),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryBright),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutActionRow extends StatelessWidget {
  const _AboutActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.getBorder(context), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryBright, size: 22),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.getTextMuted(context),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
