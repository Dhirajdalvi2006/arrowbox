import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrowbox/arrowbox_input_queue.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';

void main() {
  test('queued stable indices remain associated after earlier removal', () {
    var state = ArrowBoxState.initial(level: 1);
    final first = state.nextEscapeIndex!;
    final second = state.board.indexWhere(
      (direction) => direction != null && direction != state.board[first],
    );
    final queue = ArrowBoxInputQueue();

    expect(
      queue.enqueue(
        index: first,
        session: 1,
        capturedAt: const Duration(milliseconds: 0),
      ),
      isTrue,
    );
    expect(
      queue.enqueue(
        index: second,
        session: 1,
        capturedAt: const Duration(milliseconds: 10),
      ),
      isTrue,
    );

    final firstRequest = queue.takeNext()!;
    final firstResult = state.move(firstRequest.index);
    expect(firstResult.wasValid, isTrue);
    state = firstResult.state;

    final secondRequest = queue.takeNext()!;
    expect(secondRequest.index, second);
    expect(state.board[second], isNotNull);
  });

  test('blocked queued moves use current state rules when executed', () {
    var state = ArrowBoxState.initial(level: 3);
    final blocked = state.board.indexWhere(
      (direction) =>
          direction != null && !state.canEscape(state.board.indexOf(direction)),
    );
    if (blocked == -1) return;

    final result = state.move(blocked);
    expect(result.wasValid, isFalse);
    expect(result.state.board[blocked], isNotNull);
    expect(result.state.mistakes, state.mistakes + 1);
  });

  test('duplicate queued taps cannot create duplicate moves', () {
    final queue = ArrowBoxInputQueue();

    expect(
      queue.enqueue(index: 4, session: 1, capturedAt: Duration.zero),
      isTrue,
    );
    expect(
      queue.enqueue(
        index: 4,
        session: 1,
        capturedAt: const Duration(milliseconds: 10),
      ),
      isFalse,
    );
    expect(queue.takeNext()?.index, 4);
    expect(queue.takeNext(), isNull);
  });
}
