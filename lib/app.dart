import 'dart:async';

import 'package:flutter/material.dart';

import 'core/app_store.dart';
import 'core/services/audio_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/about/screens/about_screen.dart';
import 'features/arrowbox/arrowbox_dialogs.dart';
import 'features/arrowbox/arrowbox_logic.dart';
import 'features/arrowbox/arrowbox_screen.dart';
import 'features/how_to_play/screens/how_to_play_screen.dart';
import 'features/level_selection/screens/level_selection_screen.dart';
import 'features/progress/screens/progress_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/shell/app_shell.dart';

export 'features/about/screens/about_screen.dart';
export 'features/home/screens/home_screen.dart';
export 'features/how_to_play/screens/how_to_play_screen.dart';
export 'features/level_selection/screens/level_selection_screen.dart';
export 'features/progress/screens/progress_screen.dart';
export 'features/settings/screens/settings_screen.dart';

class ArrowBoxApp extends StatefulWidget {
  const ArrowBoxApp({required this.store, super.key});

  final AppStore store;

  @override
  State<ArrowBoxApp> createState() => _ArrowBoxAppState();
}

class _ArrowBoxAppState extends State<ArrowBoxApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Sync audio preferences (sound effects + background music) from the store.
    AudioManager.instance.initializeFromStore(
      soundEnabled: widget.store.soundEnabled,
      musicEnabled: widget.store.musicEnabled,
      musicVolume: widget.store.musicVolume,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App entered the background: pause music so it does not keep playing.
        unawaited(AudioManager.instance.pauseMusic());
      case AppLifecycleState.resumed:
        // App returned to the foreground: resume music if enabled.
        unawaited(AudioManager.instance.resumeMusic());
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = Uri.base.queryParameters['screen'];

    Widget getHome() {
      switch (screen) {
        case 'levels':
          return LevelSelectionScreen(store: widget.store);
        case 'gameplay':
          return ArrowBoxScreen(
            store: widget.store,
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
              lives: 3,
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
          return SettingsScreen(store: widget.store);
        case 'progress':
          return ProgressScreen(store: widget.store);
        case 'howtoplay':
          return const HowToPlayScreen();
        case 'about':
          return const AboutScreen();
        default:
          return AppShell(store: widget.store);
      }
    }

    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) => MaterialApp(
        title: 'ArrowBox',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: widget.store.themeMode,
        // Fix Flutter web text underlines globally
        builder: (context, child) => DefaultTextStyle(
          style: const TextStyle(
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
