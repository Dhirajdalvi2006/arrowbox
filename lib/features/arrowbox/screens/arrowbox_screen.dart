import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app.dart';
import '../../../core/app_store.dart';
import '../../../core/services/audio_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../arrow_designs/arrow_designs.dart';
import '../arrowbox_dialogs.dart';
import '../arrowbox_input_queue.dart';
import '../arrowbox_logic.dart';
import '../widgets/gameplay_board.dart';
import '../widgets/gameplay_controls.dart';
import '../widgets/gameplay_hud.dart';

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
  final Map<int, ArrowBoxExitRecord> _exiting = {};
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
    // Sync audio preferences (sound effects + background music) from the store.
    AudioManager.instance.initializeFromStore(
      soundEnabled: widget.store.soundEnabled,
      musicEnabled: widget.store.musicEnabled,
      musicVolume: widget.store.musicVolume,
    );
    if (widget.store.musicEnabled) {
      unawaited(AudioManager.instance.startMusic());
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
    for (final timer in _exitTimers.values) {
      timer.cancel();
    }
    _exitTimers.clear();
    _timer?.cancel();
    _saveCurrentGame();
    unawaited(AudioManager.instance.stopMusic());
    super.dispose();
  }

  void _invalidatePendingGameplay() {
    final oldSession = _session;
    _session++;
    _inputQueue.invalidateSession(oldSession);
    _inputQueue.clear();
    _exiting.clear();
    // Cancel any pending exit timers from the old session
    for (final timer in _exitTimers.values) {
      timer.cancel();
    }
    _exitTimers.clear();
    _shakingIndex = null;
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
    // A restarted game always needs a fresh countdown timer: the previous one
    // may have been cancelled when the session ended (Game Over / Level
    // Complete), in which case restarting without re-arming would freeze it.
    _timerStarted = true;
    _startTimer();
    unawaited(AudioManager.instance.play(SoundEffect.restart));
    await widget.store.saveGame(_game);
  }

  void _captureMove(int index) {
    debugPrint('_captureMove called for index $index');
    if (_paused || _game.isGameOver || _game.isCleared) {
      debugPrint(
        '_captureMove blocked: paused=$_paused, over=${_game.isGameOver}, cleared=${_game.isCleared}',
      );
      return;
    }
    if (index < 0 ||
        index >= _game.board.length ||
        _game.board[index] == null ||
        _exiting.containsKey(index)) {
      debugPrint(
        '_captureMove invalid: boardVal=${_game.board[index]}, exiting=${_exiting.containsKey(index)}',
      );
      return;
    }
    final capturedAt = _inputClock.elapsed;
    final accepted = _inputQueue.enqueue(
      index: index,
      session: _session,
      capturedAt: capturedAt,
    );
    if (!accepted) {
      debugPrint('_captureMove not accepted by queue');
      return;
    }
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

  final Map<int, Timer> _exitTimers = {};

  Future<void> _executeQueuedMove(ArrowBoxInputRequest request) async {
    debugPrint('_executeQueuedMove started for ${request.index}');
    if (!mounted || request.session != _session) return;
    if (_paused || _game.isGameOver || _game.isCleared) return;
    if (request.index < 0 ||
        request.index >= _game.board.length ||
        _game.board[request.index] == null) {
      return;
    }
    if (!_startRecorded) {
      _startRecorded = true;
      debugPrint('_executeQueuedMove recording game started');
      await widget.store.recordGameStarted();
      debugPrint('_executeQueuedMove game started recorded');
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

    // Play game sound effects: arrow escape on success, blocked/mistake otherwise.
    unawaited(
      AudioManager.instance.play(
        canEscape && result.wasValid ? SoundEffect.escape : SoundEffect.blocked,
      ),
    );

    if (canEscape && result.wasValid) {
      final duration = _animationTiming.durationFor(_inputClock.elapsed);
      final exitId = ++_exitId;
      setState(() {
        _game = result.state.withSeconds(_seconds);
        _exiting[request.index] = ArrowBoxExitRecord(
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
      final timer = Timer(const Duration(milliseconds: 320), () {
        if (!mounted || request.session != _session) return;
        setState(() => _shakingIndex = null);
      });
      _exitTimers[request.index] = timer;
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

  void _finishExit(int index, int exitId, int session, Duration duration) {
    final timer = Timer(duration, () {
      if (!mounted || session != _session) return;
      if (_exiting[index]?.id != exitId) return;
      setState(() => _exiting.remove(index));
      _exitTimers.remove(index);
    });
    _exitTimers[index] = timer;
  }

  int get _completionStars => _game.mistakes == 0 && _game.hintsUsed == 0
      ? 3
      : _game.mistakes <= 1 && _game.hintsUsed <= 1
      ? 2
      : 1;

  Future<void> _showHint() async {
    if (_busy || _paused || _game.isGameOver || _game.isCleared) return;
    if (_game.hintsUsed >= 3) {
      _showHintFeedback('No hints remaining for this level.');
      return;
    }
    final index = _game.nextEscapeIndex;
    if (index == null) {
      _showHintFeedback(
        'No arrow can escape right now. Free a blocking arrow first.',
      );
      return;
    }
    if (widget.store.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _game = _game.useHint();
      _hintIndex = index;
    });
    unawaited(AudioManager.instance.play(SoundEffect.hint));
    await widget.store.saveGame(_game.withSeconds(_seconds));
  }

  /// Shows a short, non-blocking message when a hint cannot be produced.
  void _showHintFeedback(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.getCard(context),
        ),
      );
  }

  Future<void> _showLevelComplete() async {
    unawaited(AudioManager.instance.play(SoundEffect.complete));
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
        lives: _game.lives,
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
    unawaited(AudioManager.instance.play(SoundEffect.gameOver));
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
                  color: Colors.white.withValues(alpha: 0.05),
                  size: 300,
                ),
              ),
              Positioned(
                bottom: 100,
                left: -100,
                child: _BackgroundGlow(
                  color: Colors.white.withValues(alpha: 0.05),
                  size: 400,
                ),
              ),
            ],

            Column(
              children: [
                GameplayHud(
                  level: _game.level,
                  difficulty: ArrowBoxLevel.forNumber(_game.level).difficulty,
                  lives: _game.lives,
                  mistakes: _game.mistakes,
                  seconds: _seconds,
                  onBack: _leaveScreen,
                  onPause: _pauseGame,
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GameplayBoard(
                            game: _game,
                            boardTheme: boardTheme,
                            skin: skin,
                            exiting: _exiting,
                            hintIndex: _hintIndex,
                            shakingIndex: _shakingIndex,
                            animationDuration: _animationTiming.durationFor(
                              _inputClock.elapsed,
                            ),
                            onTap: _captureMove,
                          ),

                          const SizedBox(height: 24),

                          GameplayControls(
                            isBusy: _busy,
                            isGameOver: _game.isGameOver,
                            isCleared: _game.isCleared,
                            hintsUsed: _game.hintsUsed,
                            hasValidHint: _game.nextEscapeIndex != null,
                            onRestart: _restart,
                            onHint: _showHint,
                          ),
                          const SizedBox(height: 20),
                        ],
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
