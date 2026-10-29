import 'dart:collection';

class ArrowBoxInputRequest {
  const ArrowBoxInputRequest({
    required this.index,
    required this.session,
    required this.capturedAt,
  });

  final int index;
  final int session;
  final Duration capturedAt;
}

class ArrowBoxInputQueue {
  ArrowBoxInputQueue({this.capacity = 128}) : assert(capacity > 0);

  final int capacity;
  final Queue<ArrowBoxInputRequest> _pending = Queue();
  final Set<int> _queuedIndices = <int>{};
  int _activeSession = 0;

  int duplicateRejections = 0;
  int staleSessionRejections = 0;
  int overflowRejections = 0;

  int get length => _pending.length;

  bool containsIndex(int index) => _queuedIndices.contains(index);

  bool enqueue({
    required int index,
    required int session,
    required Duration capturedAt,
  }) {
    if (session < _activeSession) {
      staleSessionRejections++;
      return false;
    }
    if (_queuedIndices.contains(index)) {
      duplicateRejections++;
      return false;
    }
    if (_pending.length >= capacity) {
      overflowRejections++;
      return false;
    }
    _pending.add(
      ArrowBoxInputRequest(
        index: index,
        session: session,
        capturedAt: capturedAt,
      ),
    );
    _queuedIndices.add(index);
    return true;
  }

  ArrowBoxInputRequest? takeNext() {
    while (_pending.isNotEmpty) {
      final request = _pending.removeFirst();
      _queuedIndices.remove(request.index);
      if (request.session >= _activeSession) return request;
    }
    return null;
  }

  void clear() {
    _pending.clear();
    _queuedIndices.clear();
  }

  void invalidateSession(int session) {
    if (session >= _activeSession) _activeSession = session + 1;
    _pending.removeWhere((request) => request.session < _activeSession);
    _queuedIndices
      ..clear()
      ..addAll(_pending.map((request) => request.index));
  }
}

class AdaptiveAnimationTiming {
  AdaptiveAnimationTiming({
    this.minimum = const Duration(milliseconds: 80),
    this.maximum = const Duration(milliseconds: 320),
    this.normal = const Duration(milliseconds: 220),
    this.smoothing = 0.25,
  }) : assert(smoothing > 0 && smoothing <= 1);

  final Duration minimum;
  final Duration maximum;
  final Duration normal;
  final double smoothing;

  Duration? _lastTap;
  double? _smoothedIntervalMilliseconds;

  Duration get smoothedInterval => Duration(
    milliseconds: (_smoothedIntervalMilliseconds ?? _normalInterval).round(),
  );

  void recordValidTap(Duration capturedAt) {
    final previous = _lastTap;
    _lastTap = capturedAt;
    if (previous == null) return;
    final interval = (capturedAt - previous).inMicroseconds / 1000;
    if (interval <= 0) return;
    _smoothedIntervalMilliseconds = _smoothedIntervalMilliseconds == null
        ? interval
        : _smoothedIntervalMilliseconds! * (1 - smoothing) +
              interval * smoothing;
  }

  void recordInvalidTap() {}

  Duration durationFor(Duration now) {
    final elapsedSinceTap = _lastTap == null
        ? 0
        : (now - _lastTap!).inMicroseconds / 1000;
    final interval = _smoothedIntervalMilliseconds ?? _normalInterval;
    final idleBlend = (elapsedSinceTap / 4000).clamp(0.0, 1.0);
    final targetInterval = interval + (_normalInterval - interval) * idleBlend;
    final normalized = ((targetInterval - 100) / 900).clamp(0.0, 1.0);
    final milliseconds =
        minimum.inMilliseconds +
        (maximum.inMilliseconds - minimum.inMilliseconds) * normalized;
    return Duration(
      milliseconds: milliseconds.round().clamp(
        minimum.inMilliseconds,
        maximum.inMilliseconds,
      ),
    );
  }

  double get _normalInterval => 625;
}
