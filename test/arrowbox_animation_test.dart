import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrowbox/arrowbox_input_queue.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';

void main() {
  test('adaptive durations can overlap without changing earlier requests', () {
    final timing = AdaptiveAnimationTiming();
    timing.recordValidTap(Duration.zero);
    timing.recordValidTap(const Duration(milliseconds: 700));
    final slow = timing.durationFor(const Duration(milliseconds: 700));

    timing.recordValidTap(const Duration(milliseconds: 720));
    final fast = timing.durationFor(const Duration(milliseconds: 720));

    expect(slow.inMilliseconds, greaterThan(fast.inMilliseconds));
    expect(slow.inMilliseconds, inInclusiveRange(80, 320));
    expect(fast.inMilliseconds, inInclusiveRange(80, 320));
  });

  test('logical removal leaves visual identity information capturable', () {
    final state = ArrowBoxState.initial(level: 1);
    final index = state.nextEscapeIndex!;
    final direction = state.board[index]!;
    final result = state.move(index);

    expect(result.wasValid, isTrue);
    expect(result.state.board[index], isNull);
    expect(direction, isNotNull);
  });
}
