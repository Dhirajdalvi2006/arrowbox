# ArrowBox Algorithm Correction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make all 500 ArrowBox levels deterministic, correctly positioned, fully solvable, and validated against the real movement rules, while preventing arrow escape animations from appearing in the wrong board position.

**Architecture:** Keep the existing 5×5 board and `ArrowBoxState` movement API, but replace the dense-board construction with reverse construction from a validated removal order. Expose solver metrics from the catalog generator for tests, and derive escape animation distance from the rendered cell geometry instead of using a fixed pixel value. Preserve the existing hand-authored levels 1 and 3 and the current persistence interfaces.

**Tech Stack:** Dart, Flutter, `flutter_test`, existing `ArrowDirection` vector model, `GridView` board renderer, deterministic `dart:math` seeded generation.

**Spec:** `docs/500-level-expansion-plan.md`

## Global Constraints

- The board remains exactly 5 × 5; difficulty comes from board structure, not board size.
- Hard and Ultra Hard levels contain exactly 25 arrows.
- Every generated level must be solvable using the same `canEscape`/`move` rules used by gameplay.
- Generation must be deterministic across launches and Flutter platforms.
- The catalog exposes exactly 500 levels.
- Existing levels 1–3, including level 3’s initial hint behavior, remain unchanged.
- Level 500 must not wrap to level 1 after completion.
- Do not modify or process image assets for this work.
- Do not add a second movement implementation in the renderer or solver.

## Review Focus

- A full board whose arrows are individually valid during construction must still have a valid complete removal sequence after construction; test every catalog level with the real state solver.
- A dense level must never be accepted with an empty cell; test all Hard and Ultra Hard levels for exactly 25 occupied cells.
- Rotated or mirrored generation must preserve direction-coordinate relationships; test deterministic boards and repeated generation against the same seeds.
- Arrow exit animation must move by the actual cell-to-board boundary distance on narrow and wide layouts; add widget coverage for rendered transform geometry or a pure escape-distance helper.
- A saved game at a high level must still load with the generated board and range validation; retain the existing level 250/417 persistence tests and add level 500 validation.

---

### Task 1: Establish generator and solver failure coverage

**Files:**
- Modify: `test/arrowbox_logic_test.dart`
- Modify: `lib/features/arrowbox/arrowbox_logic.dart:43-289`

**Interfaces:**
- Consumes: Existing `ArrowBoxLevel.forNumber`, `ArrowBoxState.initial`, `ArrowBoxState.nextEscapeIndex`, and `ArrowBoxState.move`.
- Produces: Test-visible catalog invariants and a deterministic failure case that the corrected generator must satisfy.

- [ ] **Step 1: Add tests that assert meaningful generation metrics, not only solvability**

Add tests that:
- Verify every level has exactly 25 cells.
- Verify Hard and Ultra Hard levels have 25 arrows.
- Verify every level can be cleared using `ArrowBoxState` and that each selected move is valid.
- Verify at least one dense level has a nontrivial dependency state: after selecting the first valid move, at least one occupied arrow remains blocked before the next removal.
- Verify two reads of every level number produce identical arrows, difficulty, and score.
- Verify no two catalog boards have the same serialized arrow layout.

- [ ] **Step 2: Run the focused tests and record the failing assertion**

Run:

```powershell
flutter test test/arrowbox_logic_test.dart
```

Expected: the current catalog may pass basic solvability but should fail the newly added dependency/duplicate/metric assertion if the current dense construction is structurally weak; use the observed failure to guide the replacement rather than changing tests to accommodate it.

- [ ] **Step 3: Add a test-only catalog summary assertion**

Assert that the catalog has all three difficulty types and that the assigned type is consistent with density: Medium may be partial, while Hard and Ultra Hard may not contain null cells.

- [ ] **Step 4: Commit the test-only baseline**

```powershell
git add test/arrowbox_logic_test.dart
git commit -m "test: cover ArrowBox generator invariants"
```

---

### Task 2: Replace dense generation with reverse construction

**Files:**
- Modify: `lib/features/arrowbox/arrowbox_logic.dart:168-289`
- Test: `test/arrowbox_logic_test.dart`

**Interfaces:**
- Consumes: `ArrowDirection.vector`, `_canEscape`, `_solveMetrics`, and the existing seeded level-number formula.
- Produces: `_buildFullBoard(ArrowBoxDifficulty difficulty, int seed) -> List<ArrowDirection?>` that returns exactly 25 occupied, solvable cells or throws a bounded `StateError`; `_solveMetrics` remains the sole movement-rule evaluator.

- [ ] **Step 1: Implement deterministic reverse construction**

For each candidate attempt:
1. Seed a local `Random` from the supplied seed plus attempt number.
2. Create a deterministic permutation of all 25 cell indexes as the intended forward removal order.
3. Start with an empty board and insert cells in reverse removal order.
4. For each insertion, choose only directions whose path is clear through the board state at insertion time; randomize candidate selection with the local seeded RNG.
5. After all 25 cells are inserted, solve the finished board with the real `_canEscape` rule, recording available-move counts at every step.
6. Reject candidates that cannot be solved, have no initial move, or fail the profile metrics.
7. Retry with a bounded deterministic attempt count and throw instead of returning a weak board.

Do not rotate coordinates after assigning directions unless the direction is transformed through the same rotation operation; the construction should operate directly on final row/column coordinates to avoid mismatched arrow vectors.

- [ ] **Step 2: Define profile acceptance metrics without duplicating movement logic**

Use the solver’s recorded first-choice count, forced-step ratio, and dependency depth. Require:
- Hard: 25 arrows, solvable, first-choice count between 2 and 6 when possible, and forced-step ratio between 0.45 and 0.85.
- Ultra Hard: 25 arrows, solvable, first-choice count between 1 and 3, forced-step ratio at least 0.70, and a dependency depth covering most of the occupied cells.

If a threshold cannot be met for a specific deterministic seed within the attempt bound, fail loudly with the level seed and difficulty in the error.

- [ ] **Step 3: Extend `_solveMetrics` or add a private metrics return type**

Return enough information to validate first choices, forced steps, average branching, and longest dependency chain while continuing to call `_canEscape` for each state. Keep the existing score calculation compatible with the new metrics.

- [ ] **Step 4: Run the catalog tests**

Run:

```powershell
flutter test test/arrowbox_logic_test.dart
```

Expected: all 500 levels generate, Hard/Ultra Hard levels are full, every level clears via `ArrowBoxState`, and the new dependency/determinism assertions pass.

- [ ] **Step 5: Run static analysis**

Run:

```powershell
flutter analyze lib/features/arrowbox test/arrowbox_logic_test.dart
```

Expected: no analyzer errors or warnings introduced by the generator rewrite.

- [ ] **Step 6: Commit the generator correction**

```powershell
git add lib/features/arrowbox/arrowbox_logic.dart test/arrowbox_logic_test.dart
git commit -m "fix: generate solvable dense ArrowBox boards"
```

---

### Task 3: Make escape animation geometry follow the board

**Files:**
- Modify: `lib/features/arrowbox/arrowbox_board_widgets.dart:6-246`
- Modify: `lib/features/arrowbox/arrowbox_screen.dart:565-590`
- Test: `test/arrowbox_widget_test.dart` (create if absent)

**Interfaces:**
- Consumes: The board’s actual cell size and `ArrowDirection.vector`.
- Produces: `GradientArrowTile` with an explicit `escapeDistance` parameter, defaulting only for isolated callers, and a transform distance calculated from the rendered grid rather than a fixed 280px constant.

- [ ] **Step 1: Add a pure geometry test/helper contract**

Add a widget-level test or extracted pure helper asserting that for a square board:
- The escape offset is along the arrow vector only.
- The distance is large enough to move the tile beyond the board edge.
- The distance scales when the board width changes.
- A left/right arrow never receives a vertical escape offset, and an up/down arrow never receives a horizontal escape offset except for the existing shake effect.

- [ ] **Step 2: Pass board-derived escape distance from `ArrowBoxScreen`**

Compute the board’s inner width and cell spacing from the same layout constraints used by `GridView`, then pass a distance based on cell size and board dimensions to each `GradientArrowTile`. Keep the animation duration unchanged unless the geometry test demonstrates a timing issue.

- [ ] **Step 3: Remove the hard-coded 280px movement assumption**

Update `GradientArrowTile` so `offsetX` and `offsetY` use `escapeDistance` and the direction vector. Preserve entry, pulse, shake, hit testing, and opacity behavior.

- [ ] **Step 4: Run widget tests and analysis**

Run:

```powershell
flutter test test/arrowbox_widget_test.dart
flutter analyze lib/features/arrowbox
```

Expected: geometry tests pass and the ArrowBox UI remains analyzer-clean.

- [ ] **Step 5: Commit the rendering correction**

```powershell
git add lib/features/arrowbox/arrowbox_board_widgets.dart lib/features/arrowbox/arrowbox_screen.dart test/arrowbox_widget_test.dart
git commit -m "fix: align ArrowBox escape animation with board geometry"
```

---

### Task 4: Validate gameplay across representative levels and persistence boundaries

**Files:**
- Modify: `test/arrowbox_logic_test.dart`
- Modify: `test/widget_test.dart` only if existing app/widget setup requires updated expectations
- Modify: `lib/core/app_store.dart` only if validation reveals a range or persistence defect

**Interfaces:**
- Consumes: Corrected 500-level catalog and existing `AppStore` persistence behavior.
- Produces: Regression coverage proving representative Medium, Hard, Ultra Hard, level 1, level 3, level 250, level 417, level 499, and level 500 behavior.

- [ ] **Step 1: Add representative progression tests**

Cover:
- Level 1 and level 3 reference behavior unchanged.
- Levels 50, 100, 200, 300, 400, 499, and 500 resolve and can be solved.
- `nextLevel()` moves 499 to 500 and returns null for 500.
- A level 500 saved state round-trips through JSON.
- Invalid level 501 is rejected.

- [ ] **Step 2: Run the full Flutter test suite**

Run:

```powershell
flutter test
```

Expected: all project tests pass, including the complete 500-level solver loop.

- [ ] **Step 3: Run the app and manually inspect representative boards**

Run the project using the app’s existing Flutter launch workflow. Open levels from each difficulty type at a narrow phone viewport and a wide desktop/web viewport. Confirm:
- arrows remain centered in their original cells before tapping;
- valid arrows leave in their own direction without appearing to jump to another cell;
- blocked arrows shake in place;
- the hint selects an actually escapable arrow;
- level and difficulty labels match the catalog.

- [ ] **Step 4: Run final static checks**

Run:

```powershell
flutter analyze
flutter test
```

Expected: no analyzer issues and all tests pass.

- [ ] **Step 5: Commit the final validation coverage**

```powershell
git add test/arrowbox_logic_test.dart test/widget_test.dart lib/core/app_store.dart
git commit -m "test: validate ArrowBox progression and persistence"
```

---

## Final Verification Checklist

- [ ] `ArrowBoxLevel.count == 500`.
- [ ] Every level has 25 cells and is deterministic.
- [ ] Every Hard and Ultra Hard board has exactly 25 arrows.
- [ ] Every level clears using the production `ArrowBoxState` movement methods.
- [ ] Dense boards satisfy their difficulty metrics instead of only being full.
- [ ] No generated board is duplicated.
- [ ] Escape animation distance scales with board geometry.
- [ ] Existing level 1 and level 3 behavior remains unchanged.
- [ ] Level 500 persistence and final-level behavior work without wrapping.
- [ ] `flutter analyze` and `flutter test` pass.
