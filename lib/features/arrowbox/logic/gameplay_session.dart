import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/app_store.dart';
import '../arrowbox_input_queue.dart';
import '../arrowbox_logic.dart';
import '../widgets/gameplay_board.dart';

/// Owns a live ArrowBox session: input queue, timer, exits, hints, and
/// persistence. The screen only presents [state] and forwards callbacks.
class GameplaySession extends ChangeNotifier {
  GameplaySession({required this.store, ArrowBoxState? initialState})
    : game = initialState ?? ArrowBoxState.initial() {
    seconds = game.secondsElapsed;
    if (seconds > 0) {
      _timerStarted = true;
      startTimer();
    }
  }

  final AppStore store;
  final inputQueue = ArrowBoxInputQueue();
  final animationTiming = AdaptiveAnimationTiming();
  final exiting = <int, ArrowBoxExitRecord>{};
  final Stopwatch inputClock = Stopwatch()..start();

  late ArrowBoxState game;
  int? hintIndex;
  int? shakingIndex;
  int session = 0;
  int exitId = 0;
  bool processingQueue = false;
  bool busy = false;
  bool paused = false;
  bool startRecorded = false;
  bool timerStarted = false;
  Timer? timer;
  late int seconds;

  bool _disposed = false;

  bool get _timerStarted => timerStarted;
  set _timerStarted(bool value) => timerStarted = value;

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!paused && !game.isCleared && !game.isGameOver && !_disposed) {
        seconds++;
        notifyListeners();
      }
    });
  }

  Future<void> saveCurrentGame() async {
    if (!game.isCleared && !game.isGameOver) {
      await store.saveGame(game.withSeconds(seconds));
    }
  }

  void invalidatePendingGameplay() {
    final oldSession = session;
    session++;
    inputQueue.invalidateSession(oldSession);
    inputQueue.clear();
    exiting.clear();
  }

  Future<bool> restart({required bool confirmed}) async {
    if (!confirmed) return false;
    invalidatePendingGameplay();
    game = game.restart();
    seconds = 0;
    hintIndex = null;
    shakingIndex = null;
    paused = false;
    timerStarted = true;
    startTimer();
    notifyListeners();
    await store.saveGame(game);
    return true;
  }

  void captureMove(int index) {
    if (paused || game.isGameOver || game.isCleared) return;
    if (index < 0 ||
        index >= game.board.length ||
        game.board[index] == null ||
        exiting.containsKey(index)) {
      return;
    }
    final capturedAt = inputClock.elapsed;
    final accepted = inputQueue.enqueue(
      index: index,
      session: session,
      capturedAt: capturedAt,
    );
    if (!accepted) return;
    animationTiming.recordValidTap(capturedAt);
    hintIndex = null;
    unawaited(drainMoveQueue());
  }

  Future<void> drainMoveQueue() async {
    if (processingQueue) return;
    processingQueue = true;
    busy = true;
    notifyListeners();
    try {
      ArrowBoxInputRequest? request;
      while (!_disposed && (request = inputQueue.takeNext()) != null) {
        await executeQueuedMove(request!);
      }
    } finally {
      processingQueue = false;
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<MoveOutcome> executeQueuedMove(ArrowBoxInputRequest request) async {
    if (_disposed || request.session != session) {
      return const MoveOutcome.ignored();
    }
    if (paused || game.isGameOver || game.isCleared) {
      return const MoveOutcome.ignored();
    }
    if (request.index < 0 ||
        request.index >= game.board.length ||
        game.board[request.index] == null) {
      return const MoveOutcome.ignored();
    }
    if (!startRecorded) {
      startRecorded = true;
      await store.recordGameStarted();
      if (_disposed || request.session != session) {
        return const MoveOutcome.ignored();
      }
    }
    if (!_timerStarted) {
      _timerStarted = true;
      startTimer();
    }

    final direction = game.board[request.index]!;
    final canEscape = game.canEscape(request.index);
    if (store.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    final result = game.move(request.index);
    if (_disposed || request.session != session) {
      return const MoveOutcome.ignored();
    }

    if (canEscape && result.wasValid) {
      final duration = animationTiming.durationFor(inputClock.elapsed);
      final id = ++exitId;
      game = result.state.withSeconds(seconds);
      exiting[request.index] = ArrowBoxExitRecord(
        id: id,
        direction: direction,
        session: request.session,
        duration: duration,
      );
      notifyListeners();
      unawaited(_finishExit(request.index, id, request.session, duration));
    } else {
      game = result.state.withSeconds(seconds);
      shakingIndex = request.index;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (_disposed || request.session != session) {
        return const MoveOutcome.ignored();
      }
      shakingIndex = null;
      notifyListeners();
    }
    await store.saveGame(game);
    if (_disposed || request.session != session) {
      return const MoveOutcome.ignored();
    }
    if (result.state.isCleared) {
      inputQueue.clear();
      session++;
      timer?.cancel();
      return MoveOutcome.cleared(result.state);
    }
    if (result.state.isGameOver) {
      inputQueue.clear();
      session++;
      timer?.cancel();
      return MoveOutcome.failed(result.state);
    }
    return const MoveOutcome.continued();
  }

  Future<void> _finishExit(
    int index,
    int id,
    int moveSession,
    Duration duration,
  ) async {
    await Future<void>.delayed(duration);
    if (_disposed || moveSession != session) return;
    if (exiting[index]?.id != id) return;
    exiting.remove(index);
    notifyListeners();
  }

  int get completionStars => game.mistakes == 0 && game.hintsUsed == 0
      ? 3
      : game.mistakes <= 1 && game.hintsUsed <= 1
      ? 2
      : 1;

  Future<void> showHint() async {
    if (busy ||
        paused ||
        game.isGameOver ||
        game.isCleared ||
        game.hintsUsed >= 3) {
      return;
    }
    final index = game.nextEscapeIndex;
    if (index == null) return;
    if (store.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    game = game.useHint();
    hintIndex = index;
    notifyListeners();
    await store.saveGame(game.withSeconds(seconds));
  }

  void beginNextLevel(ArrowBoxState nextGame) {
    invalidatePendingGameplay();
    game = nextGame;
    seconds = 0;
    hintIndex = null;
    timerStarted = true;
    startTimer();
    notifyListeners();
  }

  void beginReplay() {
    invalidatePendingGameplay();
    game = game.restart();
    seconds = 0;
    hintIndex = null;
    timerStarted = true;
    startTimer();
    notifyListeners();
  }

  void pauseGame() {
    paused = true;
    notifyListeners();
  }

  void resumeGame() {
    paused = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    session++;
    inputQueue.clear();
    exiting.clear();
    timer?.cancel();
    unawaited(saveCurrentGame());
    super.dispose();
  }
}

class MoveOutcome {
  const MoveOutcome._(this.kind);
  const MoveOutcome.ignored() : this._(MoveKind.ignored);
  const MoveOutcome.continued() : this._(MoveKind.continued);
  const MoveOutcome.cleared(ArrowBoxState _) : this._(MoveKind.cleared);
  const MoveOutcome.failed(ArrowBoxState _) : this._(MoveKind.failed);

  final MoveKind kind;
  bool get cleared => kind == MoveKind.cleared;
  bool get failed => kind == MoveKind.failed;
}

enum MoveKind { ignored, continued, cleared, failed }
