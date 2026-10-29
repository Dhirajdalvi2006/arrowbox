# ArrowBox Responsive Input Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Register rapid valid ArrowBox taps immediately, process them against authoritative current state, and animate committed removals with smoothly adaptive durations without leaking input across lifecycle changes.

**Architecture:** Keep `ArrowBoxState` and its fixed 25-cell board as the sole movement authority. Add a small pure Dart `ArrowBoxInputQueue`/speed estimator that records pointer requests and valid tap intervals, while `_ArrowBoxScreenState` serializes logical moves and tracks independent visual exit layers by stable cell index. The board indices remain stable because moves replace cells with `null` rather than compacting the list; queued requests therefore retain identity, and each request is revalidated immediately before `move`.

**Tech Stack:** Dart, Flutter, `flutter_test`, `AnimationController`, `Stopwatch`/injected timestamps, existing ArrowBox movement and rendering widgets.

**Spec:** Approved ArrowBox responsive input design from the user request (2026-10-29).

## Global Constraints

- Never silently discard ordinary valid taps while another arrow is moving; use a bounded queue with an explicit overflow policy.
- Preserve the existing `ArrowBoxState.canEscape` and `ArrowBoxState.move` rules; the logical board is authoritative.
- Keep the fixed 25-cell board representation; do not modify level generation, difficulty thresholds, or catalog rules.
- Adaptive escape durations must remain between 80 ms and 320 ms and use smoothed intervals from valid taps only.
- Invalid taps, duplicate requests, stale sessions, restart, disposal, completion, and game-over must not mutate a later session.
- Do not create a parallel gameplay movement implementation or add a dependency.
- Do not commit or push changes.

## Review Focus

- A queued index that was blocked at capture time becomes valid after an earlier removal; test that it succeeds when revalidated.
- A queued index remains blocked at execution time; test that it records a mistake and never removes the arrow.
- Four rapid distinct taps arriving during an active animation remain ordered and are all attempted; test queue ordering and no busy-drop.
- A duplicate tap for an index already queued or exiting produces one logical removal; test duplicate suppression without suppressing different arrows.
- Restart/disposal/session replacement occurs while requests or exit animations are pending; test no stale state update or completion callback.

---

### Task 1: Add deterministic input queue and adaptive timing model

**Files:**
- Create: `lib/features/arrowbox/arrowbox_input_queue.dart`
- Test: `test/arrowbox_input_queue_test.dart`

**Interfaces:**
- Produces `ArrowBoxInputRequest { int index; int session; Duration capturedAt; }`.
- Produces `ArrowBoxInputQueue({int capacity = 64})` with `int get length`, `bool enqueue({required int index, required int session, required Duration capturedAt})`, `ArrowBoxInputRequest? takeNext()`, `void clear()`, `void invalidateSession(int session)`, and `bool containsIndex(int index)`.
- Produces `AdaptiveAnimationTiming({Duration minimum = const Duration(milliseconds: 80), Duration maximum = const Duration(milliseconds: 320), Duration normal = const Duration(milliseconds: 220), double smoothing = 0.25})` with `void recordValidTap(Duration capturedAt)`, `void recordInvalidTap()`, `Duration durationFor(Duration now)`, and `Duration get smoothedInterval`.

- [ ] **Step 1: Write failing queue tests**
  - Verify four distinct requests are returned in capture order even when no execution has occurred.
  - Verify duplicate indices are rejected while queued, `containsIndex` includes queued entries, and capacity 64 rejects the 65th request without removing earlier entries.
  - Verify `clear` and `invalidateSession` remove pending requests and stale-session requests cannot be taken.

- [ ] **Step 2: Write failing timing tests**
  - Verify an initial duration is 220 ms, slow valid intervals move duration toward the 320 ms bound, and rapid intervals move it toward the 80 ms bound.
  - Verify smoothing prevents one 20 ms interval from immediately setting the minimum duration.
  - Verify invalid taps do not change `smoothedInterval` or the duration estimate.
  - Verify `durationFor(now)` gradually returns toward 220 ms after no recent taps rather than jumping directly.

- [ ] **Step 3: Run the focused tests and confirm they fail**

Run: `flutter test test/arrowbox_input_queue_test.dart`

Expected: FAIL because the queue and timing types do not exist yet.

- [ ] **Step 4: Implement the queue and timing model**
  - Store requests in a FIFO `ListQueue`/list with capacity 64 and explicit rejection on overflow; never evict an ordinary earlier request.
  - Deduplicate by stable board index across queued requests; the screen will separately exclude indices already in exit animations.
  - Track the current session and discard requests from older sessions when taking or invalidating.
  - Use EWMA interval smoothing with factor 0.25, map longer intervals toward 320 ms and shorter intervals toward 80 ms, clamp bounds, and decay toward 220 ms based on elapsed idle time.

- [ ] **Step 5: Run the focused tests and confirm they pass**

Run: `flutter test test/arrowbox_input_queue_test.dart`

Expected: PASS.

### Task 2: Separate screen input capture from serialized move execution

**Files:**
- Modify: `lib/features/arrowbox/arrowbox_screen.dart:25-220`
- Modify: `lib/features/arrowbox/arrowbox_logic.dart:238-269` only if a small test-facing identity helper is needed
- Test: `test/arrowbox_input_integration_test.dart`

**Interfaces:**
- Consumes `ArrowBoxInputQueue` and `AdaptiveAnimationTiming` from Task 1.
- Produces screen methods `_captureMove(int index)`, `_drainMoveQueue()`, and `_executeQueuedMove(ArrowBoxInputRequest request)` with a monotonically increasing session token.

- [ ] **Step 1: Write failing integration tests**
  - Pump `ArrowBoxScreen` with a deterministic level and send four rapid taps to four distinct tile widgets; verify all four requests are accepted/attempted rather than ignored by `_busy`.
  - Verify a blocked queued arrow is revalidated after an earlier queued removal and is removed only if `canEscape` is true at execution time.
  - Verify an arrow still blocked at execution remains in the board and increments mistakes/lives exactly through `ArrowBoxState.move`.
  - Verify repeated taps on the same tile result in one removal attempt, while different indices retain FIFO order.
  - Verify restarting while requests are queued produces a new session and no old request changes the restarted board.

- [ ] **Step 2: Run the focused integration tests and confirm they fail**

Run: `flutter test test/arrowbox_input_integration_test.dart`

Expected: FAIL because `_move` currently exits when `_busy` is true and no queue exists.

- [ ] **Step 3: Implement immediate capture and queued execution**
  - Replace the `_busy` early return in `_move` with `_captureMove`; reject only paused/game-over/cleared/out-of-range/null cells at capture.
  - Capture `Duration` from an injectable screen clock or a small `DateTime`/`Stopwatch` abstraction so tests do not depend on wall-clock sleeps.
  - Record timing only after the request is confirmed valid for capture; do not record blocked/null/duplicate/overflow requests.
  - Drain one request at a time, checking the current session, current board cell, `canEscape`, and lifecycle state immediately before execution.
  - Use `ArrowBoxState.move` for both valid and invalid requests, update persistence without recursively draining, and start the next request after the logical result is committed.
  - Keep queue capacity at 64 and expose an internal/test-visible count or callback for explicit overflow diagnostics; ordinary valid taps within capacity must not be dropped.

- [ ] **Step 4: Invalidate lifecycle state**
  - Increment the session and clear the queue on restart, completion, game over, and any level replacement.
  - Cancel/guard asynchronous persistence and dialog continuation paths with `mounted` plus the captured session token.
  - Clear the queue and stop processing in `dispose` before cancelling timers.

- [ ] **Step 5: Run the focused integration tests and confirm they pass**

Run: `flutter test test/arrowbox_input_integration_test.dart`

Expected: PASS.

### Task 3: Support overlapping exit animations without logical divergence

**Files:**
- Modify: `lib/features/arrowbox/arrowbox_screen.dart:600-675`
- Modify: `lib/features/arrowbox/arrowbox_board_widgets.dart:13-190`
- Test: `test/arrowbox_animation_test.dart`

**Interfaces:**
- Screen maintains an internal map of exiting layers keyed by stable board index, containing direction, session, and animation duration/state.
- `GradientArrowTile` accepts an optional `escapeDuration` and no longer disables `onTap` merely because another tile is escaping; a tile being removed remains non-interactive through its own stable index.

- [ ] **Step 1: Write failing animation tests**
  - Verify the first logical removal starts an exit layer while the logical board cell is already null.
  - Verify a second independent removal can start before the first exit duration completes and both visual exit layers remain present.
  - Verify each exit duration is the current adaptive duration, bounded from 80 to 320 ms, and changing a later duration does not snap an earlier animation.
  - Verify an exiting tile cannot be tapped again and no duplicate visual layer is created.
  - Verify all exit layers are cleared when the session changes or the widget is disposed.

- [ ] **Step 2: Run the focused animation tests and confirm they fail**

Run: `flutter test test/arrowbox_animation_test.dart`

Expected: FAIL because the current screen has one `_escapingIndex` and the tile uses a fixed 320 ms controller.

- [ ] **Step 3: Implement independent visual exit layers**
  - Replace the single escaping index with a session-scoped map of exit records keyed by fixed cell index.
  - Commit the logical move before adding the exit record, render the exiting tile from the captured direction rather than from the now-null board cell, and remove the record only after its own animation completes.
  - Pass the adaptive duration into each tile/controller before starting it; do not change an active controller’s duration.
  - Render normal board tiles from `_game.board` and exit overlays from exit records, preserving cell geometry and preventing removed arrows from reappearing.
  - Keep pointer feedback on each tile, but have capture happen exactly once through the existing `onTap` path; do not add a second tap callback alongside `Listener`.

- [ ] **Step 4: Run the focused animation tests and confirm they pass**

Run: `flutter test test/arrowbox_animation_test.dart`

Expected: PASS.

### Task 4: Regression coverage, formatting, and full verification

**Files:**
- Modify: `test/arrowbox_logic_test.dart` only if a focused stable-index assertion belongs with existing logic tests
- Modify: `test/widget_test.dart` only if existing gameplay expectations need deterministic queue setup

- [ ] **Step 1: Add stable identity and rule regressions**
  - Assert that removing index `i` leaves all other fixed board indices unchanged and queued index `j` still refers to the original arrow.
  - Assert invalid queued moves never remove an arrow or bypass lives/mistakes behavior.
  - Assert completion is reported once when the final logical move commits, even if exit animations remain active.

- [ ] **Step 2: Format changed Dart files**

Run: `dart format lib/features/arrowbox/arrowbox_input_queue.dart lib/features/arrowbox/arrowbox_screen.dart lib/features/arrowbox/arrowbox_board_widgets.dart test/arrowbox_input_queue_test.dart test/arrowbox_input_integration_test.dart test/arrowbox_animation_test.dart test/arrowbox_logic_test.dart test/widget_test.dart`

Expected: All files formatted successfully.

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze`

Expected: `No issues found!`

- [ ] **Step 4: Run focused gameplay tests**

Run: `flutter test test/arrowbox_input_queue_test.dart test/arrowbox_input_integration_test.dart test/arrowbox_animation_test.dart test/arrowbox_logic_test.dart test/widget_test.dart`

Expected: All tests pass and complete without timeout.

- [ ] **Step 5: Run the broader Flutter suite**

Run: `flutter test`

Expected: All tests pass; if the suite exceeds the command timeout, report it as incomplete rather than claiming success.

- [ ] **Step 6: Inspect the final diff**

Run: `git diff --check` and `git status --short`

Expected: No whitespace errors, no unrelated files modified, and no commit/push performed.
