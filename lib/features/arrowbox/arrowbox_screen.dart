import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/arrowbox_widgets.dart';
import 'arrowbox_board_widgets.dart';
import 'arrowbox_dialogs.dart';
import 'arrowbox_logic.dart';
import '../../app.dart';

class ArrowBoxScreen extends StatefulWidget {
  const ArrowBoxScreen({required this.store, this.initialState, super.key});

  final AppStore store;
  final ArrowBoxState? initialState;

  @override
  State<ArrowBoxScreen> createState() => _ArrowBoxScreenState();
}

class _ArrowBoxScreenState extends State<ArrowBoxScreen>
    with WidgetsBindingObserver {
  late ArrowBoxState _game;
  int? _hintIndex;
  int? _escapingIndex;
  int? _shakingIndex;
  bool _busy = false;
  bool _paused = false;
  bool _startRecorded = false;
  bool _timerStarted = false;

  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = widget.initialState ?? ArrowBoxState.initial();
    _seconds = _game.secondsElapsed;
    if (_seconds > 0) {
      _timerStarted = true;
      _startTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveCurrentGame();
    }
  }

  Future<void> _saveCurrentGame() async {
    if (!_game.isCleared && !_game.isGameOver) {
      await widget.store.saveGame(_game.withSeconds(_seconds));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!_paused && !_game.isCleared && !_game.isGameOver && mounted) {
        setState(() => _seconds++);
      }
    });
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _saveCurrentGame();
    super.dispose();
  }

  Future<void> _leaveScreen() async {
    await widget.store.saveGame(_game.withSeconds(_seconds));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _restart() async {
    if (widget.store.confirmRestart) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.getCard(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.getBorder(context)),
          ),
          title: Text(
            'Restart level?',
            style: TextStyle(color: AppColors.getTextPrimary(context)),
          ),
          content: Text(
            'Your current board progress will be reset.',
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
              child: const Text('Restart'),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
    }

    setState(() {
      _game = _game.restart();
      _seconds = 0;
      _hintIndex = null;
      _escapingIndex = null;
      _shakingIndex = null;
      _paused = false;
    });
    await widget.store.saveGame(_game);
  }

  Future<void> _move(int index) async {
    if (_busy || _paused || _game.isGameOver || _game.isCleared) return;
    if (index < 0 ||
        index >= _game.board.length ||
        _game.board[index] == null) {
      return;
    }
    _busy = true;
    if (!_startRecorded) {
      _startRecorded = true;
      await widget.store.recordGameStarted();
      if (!mounted) return;
    }
    if (!_timerStarted) {
      _timerStarted = true;
      _startTimer();
    }
    final canEscape = _game.canEscape(index);

    if (canEscape) {
      if (widget.store.hapticsEnabled) {
        HapticFeedback.lightImpact();
      }
      setState(() {
        _escapingIndex = index;
        _hintIndex = null;
        _busy = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;

      final result = _game.move(index);
      setState(() {
        _game = result.state.withSeconds(_seconds);
        _escapingIndex = null;
        _busy = false;
      });
      await widget.store.saveGame(_game);

      if (result.state.isCleared) {
        _timer?.cancel();
        await _showLevelComplete();
      }
    } else {
      if (widget.store.hapticsEnabled) {
        HapticFeedback.mediumImpact();
      }
      setState(() {
        _shakingIndex = index;
        _hintIndex = null;
        _busy = true;
      });

      final result = _game.move(index);
      setState(() {
        _game = result.state.withSeconds(_seconds);
      });
      await widget.store.saveGame(_game);

      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      setState(() {
        _shakingIndex = null;
        _busy = false;
      });

      if (result.state.isGameOver) {
        _timer?.cancel();
        await _showGameOver();
      }
    }
  }

  Future<void> _undo() async {
    if (_busy || _paused || _game.history.isEmpty) return;
    if (widget.store.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _game = _game.undo();
      _hintIndex = null;
    });
    await widget.store.saveGame(_game);
  }

  int get _completionStars => _game.mistakes == 0 && _game.hintsUsed == 0
      ? 3
      : _game.mistakes <= 1 && _game.hintsUsed <= 1
      ? 2
      : 1;

  Future<void> _showHint() async {
    if (_busy ||
        _paused ||
        _game.isGameOver ||
        _game.isCleared ||
        _game.hintsUsed >= 3) {
      return;
    }
    final index = _game.nextEscapeIndex;
    if (index == null) return;
    if (widget.store.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _game = _game.useHint();
      _hintIndex = index;
    });
    await widget.store.saveGame(_game.withSeconds(_seconds));
  }

  Future<void> _showLevelComplete() async {
    await widget.store.recordCompletion(
      _game.level,
      _game.mistakes,
      hintsUsed: _game.hintsUsed,
    );
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ArrowBoxLevelCompleteDialog(
        level: _game.level,
        moves: _game.moves,
        mistakes: _game.mistakes,
        hintsUsed: _game.hintsUsed,
        stars: _completionStars,
        seconds: _seconds,
        onNextLevel: () async {
          Navigator.pop(dialogContext);
          if (_game.level < AppStore.totalLevels) {
            final nextGame = _game.nextLevel();
            if (nextGame == null) {
              await widget.store.clearSavedGame();
              if (mounted) Navigator.pop(context);
              return;
            }
            setState(() {
              _game = nextGame;
              _seconds = 0;
              _hintIndex = null;
            });
            await widget.store.saveGame(_game);
            _startTimer();
          } else {
            await widget.store.clearSavedGame();
            if (mounted) Navigator.pop(context);
          }
        },
        onReplayLevel: () async {
          Navigator.pop(dialogContext);
          setState(() {
            _game = _game.restart();
            _seconds = 0;
            _hintIndex = null;
          });
          await widget.store.saveGame(_game);
          _startTimer();
        },
        onLevelSelection: () {
          Navigator.pop(dialogContext);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LevelSelectionScreen(store: widget.store),
            ),
          );
        },
        onMainMenu: () {
          Navigator.pop(dialogContext);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  Future<void> _showGameOver() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ArrowBoxGameOverDialog(
        level: _game.level,
        mistakes: _game.mistakes,
        onRestart: () async {
          Navigator.pop(dialogContext);
          setState(() {
            _game = _game.restart();
            _seconds = 0;
            _hintIndex = null;
          });
          await widget.store.saveGame(_game);
          _startTimer();
        },
        onLevelSelection: () {
          Navigator.pop(dialogContext);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LevelSelectionScreen(store: widget.store),
            ),
          );
        },
        onMainMenu: () {
          Navigator.pop(dialogContext);
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  void _pauseGame() => setState(() => _paused = true);
  void _resumeGame() => setState(() => _paused = false);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bgColor = AppColors.getBackground(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Atmospheric Background Glows
            if (isDark) ...[
              Positioned(
                top: -100,
                right: -50,
                child: _BackgroundGlow(
                  color: const Color(0xFF1D5CC9).withValues(alpha: 0.15),
                  size: 300,
                ),
              ),
              Positioned(
                bottom: 100,
                left: -100,
                child: _BackgroundGlow(
                  color: const Color(0xFF14D1FF).withValues(alpha: 0.1),
                  size: 400,
                ),
              ),
            ],

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ArrowBoxHeaderIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onPressed: _leaveScreen,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              ArrowBoxLogoMark(size: 26),
                              SizedBox(width: 10),
                              ArrowBoxTitle(fontSize: 22),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Level ${_game.level}',
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(context),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Semantics(
                                label:
                                    'Level ${_game.level}, ${ArrowBoxLevel.forNumber(_game.level).difficulty.label}',
                                child: _DifficultyBadge(
                                  difficulty: ArrowBoxLevel.forNumber(
                                    _game.level,
                                  ).difficulty,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ArrowBoxHeaderIconButton(
                        icon: Icons.pause_rounded,
                        tooltip: 'Pause',
                        onPressed: _pauseGame,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(3, (i) {
                          final hasLife = i < _game.lives;
                          return Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Icon(
                              hasLife
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: hasLife
                                  ? const Color(0xFFFF4D6D)
                                  : (isDark
                                        ? const Color(0xFF33445D)
                                        : const Color(0xFFCAD6E6)),
                              size: 27,
                              shadows: hasLife
                                  ? const [
                                      Shadow(
                                        color: Color(0x66FF365F),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 13),
                      Container(
                        width: 1,
                        height: 28,
                        color: AppColors.getBorder(context),
                      ),
                      const SizedBox(width: 13),
                      Text(
                        '${_game.mistakes} mistakes',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.getCard(context)
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.getBorder(context)
                                .withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppColors.cyan,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(_seconds),
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final boardWidth = (constraints.maxWidth - 4).clamp(
                            240.0,
                            420.0,
                          );

                          final escapeDistance = boardWidth;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: boardWidth,
                                height: boardWidth,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF040C18)
                                      : AppColors.getSecondaryBackground(
                                          context,
                                        ),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0x7721D4FD)
                                        : AppColors.getBorder(context),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? const Color(0x33000000)
                                          : const Color(0x12000000),
                                      blurRadius: 30,
                                      offset: const Offset(0, 12),
                                    ),
                                    if (isDark)
                                      BoxShadow(
                                        color: const Color(0xFF21D4FD)
                                            .withValues(alpha: 0.15),
                                        blurRadius: 20,
                                        spreadRadius: -2,
                                      ),
                                  ],
                                ),
                                child: LayoutBuilder(
                                  builder: (context, boardConstraints) {
                                    const gap = 10.0;
                                    final tileSize =
                                        (boardConstraints.maxWidth - gap * 4) /
                                        5;
                                    final indexes = [
                                      for (var index = 0; index < 25; index++)
                                        if (index != _escapingIndex) index,
                                      ?_escapingIndex,
                                    ];

                                    return SizedBox.expand(
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          for (final index in indexes)
                                            Positioned(
                                              key: ValueKey(index),
                                              left:
                                                  (index % 5) *
                                                  (tileSize + gap),
                                              top:
                                                  (index ~/ 5) *
                                                  (tileSize + gap),
                                              width: tileSize,
                                              height: tileSize,
                                              child: _game.board[index] == null
                                                  ? const EmptyBoardCell()
                                                  : GradientArrowTile(
                                                      direction:
                                                          _game.board[index]!,
                                                      index: index,
                                                      highlighted:
                                                          index == _hintIndex,
                                                      isEscaping:
                                                          index ==
                                                          _escapingIndex,
                                                      isShaking:
                                                          index ==
                                                          _shakingIndex,
                                                      onTap: () => _move(index),
                                                      escapeDistance:
                                                          escapeDistance,
                                                      animationDelay: Duration(
                                                        milliseconds:
                                                            (index % 5 +
                                                                index ~/ 5) *
                                                            50,
                                                      ),
                                                    ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 24),

                              if (widget.store.hintsEnabled)
                                GameplayHintPanel(
                                  message: _game.hintMessage,
                                  onTapHint: _showHint,
                                ),

                              const SizedBox(height: 24),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: [
                                    GameplayControlButton(
                                      icon: Icons.undo_rounded,
                                      label: 'Undo',
                                      enabled:
                                          !_busy && _game.history.isNotEmpty,
                                      onTap: _undo,
                                    ),
                                    const SizedBox(width: 16),
                                    GameplayControlButton(
                                      icon: Icons.refresh_rounded,
                                      label: 'Restart',
                                      enabled: !_busy,
                                      onTap: _restart,
                                    ),
                                    const SizedBox(width: 16),
                                    GameplayControlButton(
                                      icon: Icons.lightbulb_rounded,
                                      label: 'Hint',
                                      badgeCount: _game.hintsUsed < 3
                                          ? 3 - _game.hintsUsed
                                          : null,
                                      enabled: !_busy && _game.hintsUsed < 3,
                                      onTap: _showHint,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_paused)
              Positioned.fill(
                child: ModalBarrier(dismissible: false, color: Colors.black54),
              ),
            if (_paused)
              Positioned.fill(
                child: ArrowBoxPauseDialog(
                  onResume: _resumeGame,
                  onRestart: () {
                    _resumeGame();
                    _restart();
                  },
                  onSettings: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(store: widget.store),
                      ),
                    );
                  },
                  onLevelSelection: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LevelSelectionScreen(store: widget.store),
                      ),
                    );
                  },
                  onMainMenu: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final ArrowBoxDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      ArrowBoxDifficulty.medium => AppColors.cyan,
      ArrowBoxDifficulty.hard => AppColors.warning,
      ArrowBoxDifficulty.ultraHard => AppColors.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        difficulty == ArrowBoxDifficulty.ultraHard
            ? 'ULTRA'
            : difficulty.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
