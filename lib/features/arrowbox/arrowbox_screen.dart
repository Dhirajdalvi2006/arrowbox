import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/arrowbox_widgets.dart';
import 'arrowbox_board_widgets.dart';
import 'arrowbox_dialogs.dart';
import 'arrowbox_input_queue.dart';
import 'arrowbox_logic.dart';
import '../arrow_designs/arrow_designs.dart';
import '../../app.dart';

class _ArrowBoxExitRecord {
  const _ArrowBoxExitRecord({
    required this.id,
    required this.direction,
    required this.session,
    required this.duration,
  });

  final int id;
  final ArrowDirection direction;
  final int session;
  final Duration duration;
}

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
  final _inputQueue = ArrowBoxInputQueue();
  final _animationTiming = AdaptiveAnimationTiming();
  final Map<int, _ArrowBoxExitRecord> _exiting = {};
  final Stopwatch _inputClock = Stopwatch()..start();
  int _session = 0;
  int _exitId = 0;
  bool _processingQueue = false;
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
    widget.store.addListener(_appearanceChanged);
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

  void _appearanceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.store.removeListener(_appearanceChanged);
    WidgetsBinding.instance.removeObserver(this);
    _session++;
    _inputQueue.clear();
    _exiting.clear();
    _timer?.cancel();
    _saveCurrentGame();
    super.dispose();
  }

  void _invalidatePendingGameplay() {
    final oldSession = _session;
    _session++;
    _inputQueue.invalidateSession(oldSession);
    _inputQueue.clear();
    _exiting.clear();
  }

  Future<void> _leaveScreen() async {
    _invalidatePendingGameplay();
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

    _invalidatePendingGameplay();
    setState(() {
      _game = _game.restart();
      _seconds = 0;
      _hintIndex = null;
      _shakingIndex = null;
      _paused = false;
    });
    await widget.store.saveGame(_game);
  }

  void _captureMove(int index) {
    if (_paused || _game.isGameOver || _game.isCleared) return;
    if (index < 0 ||
        index >= _game.board.length ||
        _game.board[index] == null ||
        _exiting.containsKey(index)) {
      return;
    }
    final capturedAt = _inputClock.elapsed;
    final accepted = _inputQueue.enqueue(
      index: index,
      session: _session,
      capturedAt: capturedAt,
    );
    if (!accepted) return;
    _animationTiming.recordValidTap(capturedAt);
    _hintIndex = null;
    _drainMoveQueue();
  }

  Future<void> _drainMoveQueue() async {
    if (_processingQueue) return;
    _processingQueue = true;
    _busy = true;
    try {
      ArrowBoxInputRequest? request;
      while (mounted && (request = _inputQueue.takeNext()) != null) {
        await _executeQueuedMove(request!);
      }
    } finally {
      _processingQueue = false;
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _executeQueuedMove(ArrowBoxInputRequest request) async {
    if (!mounted || request.session != _session) return;
    if (_paused || _game.isGameOver || _game.isCleared) return;
    if (request.index < 0 ||
        request.index >= _game.board.length ||
        _game.board[request.index] == null) {
      return;
    }
    if (!_startRecorded) {
      _startRecorded = true;
      await widget.store.recordGameStarted();
      if (!mounted || request.session != _session) return;
    }
    if (!_timerStarted) {
      _timerStarted = true;
      _startTimer();
    }

    final direction = _game.board[request.index]!;
    final canEscape = _game.canEscape(request.index);
    if (widget.store.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    final result = _game.move(request.index);
    if (!mounted || request.session != _session) return;

    if (canEscape && result.wasValid) {
      final duration = _animationTiming.durationFor(_inputClock.elapsed);
      final exitId = ++_exitId;
      setState(() {
        _game = result.state.withSeconds(_seconds);
        _exiting[request.index] = _ArrowBoxExitRecord(
          id: exitId,
          direction: direction,
          session: request.session,
          duration: duration,
        );
      });
      _finishExit(request.index, exitId, request.session, duration);
    } else {
      setState(() {
        _game = result.state.withSeconds(_seconds);
        _shakingIndex = request.index;
      });
      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted || request.session != _session) return;
      setState(() => _shakingIndex = null);
    }
    await widget.store.saveGame(_game);
    if (!mounted || request.session != _session) return;
    if (result.state.isCleared) {
      _inputQueue.clear();
      _session++;
      _timer?.cancel();
      await _showLevelComplete();
    } else if (result.state.isGameOver) {
      _inputQueue.clear();
      _session++;
      _timer?.cancel();
      await _showGameOver();
    }
  }

  Future<void> _finishExit(
    int index,
    int exitId,
    int session,
    Duration duration,
  ) async {
    await Future<void>.delayed(duration);
    if (!mounted || session != _session) return;
    if (_exiting[index]?.id != exitId) return;
    setState(() => _exiting.remove(index));
  }

  Future<void> _undo() async {
    if (_busy || _paused || _game.history.isEmpty) return;
    if (widget.store.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    final previousBoard = _game.board;
    setState(() {
      _game = _game.undo();
      _hintIndex = null;
      for (var i = 0; i < _game.board.length; i++) {
        if (_game.board[i] != null && previousBoard[i] == null) {
          _exiting.remove(i);
        }
      }
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
            _invalidatePendingGameplay();
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
          _invalidatePendingGameplay();
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
          _invalidatePendingGameplay();
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
    final skin = ArrowSkinRegistry.byId(widget.store.arrowSkinId);
    final boardTheme = BoardThemeRegistry.byId(widget.store.boardThemeId);

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
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
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
                                      color: AppColors.getTextSecondary(
                                        context,
                                      ),
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
                        ),
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
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(3, (i) {
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
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 28,
                              color: AppColors.getBorder(context),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '${_game.mistakes} mistakes',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(context),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
                            0.0,
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
                                      ? boardTheme.frame
                                      : AppColors.getSecondaryBackground(
                                          context,
                                        ),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: isDark
                                        ? boardTheme.frameBorder
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
                                        index,
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
                                                  ? (_exiting[index] == null
                                                        ? EmptyBoardCell(
                                                            theme: boardTheme,
                                                          )
                                                        : GradientArrowTile(
                                                            direction:
                                                                _exiting[index]!
                                                                    .direction,
                                                            skin: skin,
                                                            index: index,
                                                            highlighted: false,
                                                            isEscaping: true,
                                                            isShaking: false,
                                                            onTap: () {},
                                                            escapeDuration:
                                                                _exiting[index]!
                                                                    .duration,
                                                            escapeDistance:
                                                                escapeDistance,
                                                          ))
                                                  : GradientArrowTile(
                                                      direction:
                                                          _game.board[index]!,
                                                      skin: skin,
                                                      index: index,
                                                      highlighted:
                                                          index == _hintIndex,
                                                      isEscaping: false,
                                                      isShaking:
                                                          index ==
                                                          _shakingIndex,
                                                      onTap: () =>
                                                          _captureMove(index),
                                                      escapeDuration:
                                                          _animationTiming
                                                              .durationFor(
                                                                _inputClock
                                                                    .elapsed,
                                                              ),
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
      ArrowBoxDifficulty.easy => AppColors.success,
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
