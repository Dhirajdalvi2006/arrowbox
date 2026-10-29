import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrowbox/arrowbox_input_queue.dart';

void main() {
  test('preserves FIFO order for distinct requests', () {
    final queue = ArrowBoxInputQueue();

    expect(
      queue.enqueue(
        index: 3,
        session: 7,
        capturedAt: const Duration(milliseconds: 10),
      ),
      isTrue,
    );
    expect(
      queue.enqueue(
        index: 8,
        session: 7,
        capturedAt: const Duration(milliseconds: 20),
      ),
      isTrue,
    );

    expect(queue.takeNext()?.index, 3);
    expect(queue.takeNext()?.index, 8);
    expect(queue.takeNext(), isNull);
  });

  test('rejects duplicate indices and exposes overflow without eviction', () {
    final queue = ArrowBoxInputQueue(capacity: 2);
    const timestamp = Duration(milliseconds: 10);

    expect(queue.enqueue(index: 1, session: 1, capturedAt: timestamp), isTrue);
    expect(queue.enqueue(index: 1, session: 1, capturedAt: timestamp), isFalse);
    expect(queue.enqueue(index: 2, session: 1, capturedAt: timestamp), isTrue);
    expect(queue.enqueue(index: 3, session: 1, capturedAt: timestamp), isFalse);

    expect(queue.duplicateRejections, 1);
    expect(queue.overflowRejections, 1);
    expect(queue.takeNext()?.index, 1);
    expect(queue.takeNext()?.index, 2);
  });

  test('rejects stale sessions and clears pending requests', () {
    final queue = ArrowBoxInputQueue();
    const timestamp = Duration(milliseconds: 10);

    expect(queue.enqueue(index: 1, session: 2, capturedAt: timestamp), isTrue);
    queue.invalidateSession(2);
    expect(queue.takeNext(), isNull);

    expect(queue.enqueue(index: 2, session: 3, capturedAt: timestamp), isTrue);
    queue.clear();
    expect(queue.length, 0);
  });

  test('smooths valid intervals and decays toward normal while idle', () {
    final timing = AdaptiveAnimationTiming();

    expect(
      timing.durationFor(const Duration(milliseconds: 0)),
      const Duration(milliseconds: 220),
    );
    timing.recordValidTap(const Duration(milliseconds: 0));
    timing.recordValidTap(const Duration(milliseconds: 1000));
    final slowDuration = timing.durationFor(const Duration(milliseconds: 1000));
    expect(slowDuration.inMilliseconds, greaterThan(220));

    timing.recordValidTap(const Duration(milliseconds: 1020));
    final smoothedFastDuration = timing.durationFor(
      const Duration(milliseconds: 1020),
    );
    expect(smoothedFastDuration.inMilliseconds, greaterThan(80));
    expect(
      smoothedFastDuration.inMilliseconds,
      lessThan(slowDuration.inMilliseconds),
    );

    final idleDuration = timing.durationFor(
      const Duration(milliseconds: 10020),
    );
    expect(idleDuration.inMilliseconds, lessThan(slowDuration.inMilliseconds));
    expect(idleDuration.inMilliseconds, greaterThan(80));
  });

  test('invalid taps do not affect timing estimate', () {
    final timing = AdaptiveAnimationTiming();
    timing.recordValidTap(const Duration(milliseconds: 0));
    timing.recordValidTap(const Duration(milliseconds: 400));
    final before = timing.smoothedInterval;

    timing.recordInvalidTap();

    expect(timing.smoothedInterval, before);
  });

  test('durations remain within configured bounds', () {
    final timing = AdaptiveAnimationTiming();

    timing.recordValidTap(const Duration(milliseconds: 0));
    timing.recordValidTap(const Duration(milliseconds: 10000));
    expect(
      timing.durationFor(const Duration(milliseconds: 10000)).inMilliseconds,
      lessThanOrEqualTo(320),
    );

    for (var index = 1; index <= 20; index++) {
      timing.recordValidTap(Duration(milliseconds: 10000 + index * 10));
    }
    expect(
      timing.durationFor(const Duration(milliseconds: 10200)).inMilliseconds,
      greaterThanOrEqualTo(80),
    );
  });
}
