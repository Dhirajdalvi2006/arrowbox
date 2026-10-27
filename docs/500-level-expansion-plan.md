# ArrowBox 500-Level Expansion Plan

## 1. Objective

Expand ArrowBox from 30 levels to approximately 500 deterministic levels while preserving the existing offline gameplay model, saved-game compatibility, progression rules, and responsive mobile experience.

The expanded catalog will contain three difficulty types:

- **Medium**: approachable boards with clear solution paths, moderate arrow counts, and limited dependency depth. Empty cells are allowed.
- **Hard**: every one of the 25 board cells contains an arrow. The arrangement must create long dependencies, few immediately available moves, and meaningful mistake pressure.
- **Ultra Hard**: every one of the 25 board cells contains an arrow. The arrangement must be genuinely restrictive, with deep dependency chains and frequent forced choices, while remaining completely solvable by a deterministic solver.

Difficulty is a gameplay property, not only a label. The level-selection tile and the gameplay screen must both show the authoritative difficulty for the current level.

The catalog will mix these types throughout the progression instead of placing all easy levels first and all difficult levels at the end. Difficulty should rise overall, but periodic lower-intensity levels should provide pacing and recovery.

## 2. Current-State Constraints

The current implementation has several 30-level assumptions that must be removed or centralized:

- `ArrowBoxLevel.count` is `30` in `lib/features/arrowbox/arrowbox_logic.dart`.
- `AppStore.totalLevels` is `30` in `lib/core/app_store.dart`.
- Level generation currently uses a fixed 5 × 5 board with at most 25 arrows, but the current generator does not guarantee full occupancy for Hard and Ultra Hard.
- `ArrowBoxState.fromJson` rejects saved levels above 30.
- `ArrowBoxState.nextLevel()` wraps back to level 1 after the final level.
- Progress and level-selection screens contain display text and calculations based on 30.
- The level-selection screen renders every level in one four-column grid.
- Tests validate solvability only for the current 30 levels.
- README documentation describes a 30-level catalog.

The 5 × 5 board should remain unchanged for this expansion. Increasing difficulty must come from board structure and solution constraints rather than making the board physically larger.

## 3. Proposed Domain Model

### 3.1 Difficulty enum

Add a difficulty type to the level model:

```dart
enum ArrowBoxDifficulty {
  medium,
  hard,
  ultraHard,
}
```

Expose presentation metadata without coupling the generator to UI:

- Display name: `Medium`, `Hard`, `Ultra Hard`.
- Stable identifier for persistence or future analytics.
- Optional accent color chosen through the app theme layer.

### 3.2 Level metadata

Expand `ArrowBoxLevel` to contain both board data and catalog metadata:

```dart
class ArrowBoxLevel {
  const ArrowBoxLevel({
    required this.arrows,
    required this.difficulty,
    required this.seed,
    required this.solutionDepth,
    required this.availableMoves,
  });

  final List<ArrowDirection?> arrows;
  final ArrowBoxDifficulty difficulty;
  final int seed;
  final int solutionDepth;
  final int availableMoves;
}
```

The exact metadata can be reduced if it is not needed at runtime, but the generator should calculate and validate it during catalog creation. The game should not rely on a difficulty label alone; the label must correspond to measurable board properties.

### 3.3 Single source of truth for level count

Remove duplicate numeric constants. `AppStore.totalLevels` should derive from the level catalog, for example:

```dart
static int get totalLevels => ArrowBoxLevel.count;
```

`ArrowBoxLevel.count` should be the catalog length, not a separately maintained literal.

## 4. Level Catalog Distribution

Target catalog size: **500 levels**.

Recommended distribution:

- Levels 1–50: mostly Medium, with a few introductory levels.
- Levels 51–200: Medium and Hard mixed, approximately 60% Medium and 40% Hard.
- Levels 201–400: Hard and Ultra Hard mixed, approximately 65% Hard and 35% Ultra Hard.
- Levels 401–500: mostly Ultra Hard, with periodic Hard recovery levels.

A practical final distribution is:

- 220 Medium levels.
- 200 Hard levels.
- 80 Ultra Hard levels.

The ordering should use a deterministic schedule rather than a random shuffle. For example, difficulty bands can be mixed with a repeating cadence whose period does not divide evenly into 500. This prevents long runs of one difficulty while preserving a gradual overall curve.

Every generated level should store its assigned difficulty and seed so the catalog remains reproducible across app launches and Flutter platforms.

## 5. Difficulty Design

Difficulty must be measurable and testable. Candidate metrics:

### 5.1 Arrow density

Number of occupied cells out of 25.

- Medium: approximately 8–15 arrows.
- Hard: approximately 13–20 arrows.
- Ultra Hard: exactly 25 arrows; every block must be occupied.

Hard and Ultra Hard therefore require full occupancy, not merely a high approximate density. Density alone must not determine difficulty because some dense boards can still have many immediately removable arrows.

### 5.2 Solution depth

The number of sequential removals required to clear the board. This is equal to the number of arrows for the current rules, but the important measure is the dependency depth: the longest chain where one arrow must be removed before another can escape.

For full boards, difficulty must be evaluated over the complete removal sequence. A board is not Ultra Hard merely because it contains 25 arrows; it must also constrain the order of those removals.

Suggested targets:

- Medium: shallow to moderate dependency chains.
- Hard: moderate to deep dependency chains.
- Ultra Hard: deep chains covering most of the board.

### 5.3 Initial and average branching factor

Measure how many arrows can escape at each solution step.

- Medium should usually offer multiple valid choices.
- Hard should offer fewer choices and more forced sequences.
- Ultra Hard should frequently have one valid choice, while never becoming unsolvable.

The generator should reject boards with an unintended deadlock and should reject boards that are too open for their assigned difficulty.

### 5.4 Mistake pressure

Estimate how many occupied arrows are blocked at each step. A difficult board should contain plausible-looking but blocked moves, but the game must remain fair: every blocked move must be explainable by an occupied path and solvability must remain deterministic.

### 5.5 Difficulty score

Calculate a normalized score from density, dependency depth, average branching factor, and forced-choice frequency. Use score thresholds to validate the assigned type:

```text
Medium:    score 0.20–0.48
Hard:      score 0.45–0.75
Ultra Hard: score 0.70–0.98
```

Thresholds should be calibrated from generated samples and adjusted after reviewing actual playability. Overlapping boundaries are intentional so the catalog does not produce abrupt difficulty jumps.

## 6. Required Correction: Full Hard and Ultra Hard Boards

The current implementation does not meet the intended meaning of Hard and Ultra Hard. A high arrow count is not enough, and the gameplay header must not hide the difficulty type.

### 6.1 Gameplay difficulty visibility

The gameplay header must show both the level number and its catalog difficulty:

```text
Level 417   ULTRA
```

Use the authoritative `ArrowBoxLevel.forNumber(_game.level).difficulty` value rather than storing a second difficulty value in `ArrowBoxState`. The badge must:

- Be visible in both light and dark themes.
- Use text in addition to color.
- Remain compact on 320–412 logical-pixel screens.
- Expose semantics such as `Level 417, Ultra Hard`.
- Appear on level selection tiles as well as the gameplay screen.

### 6.2 Full occupancy requirement

For levels assigned `Hard` or `Ultra Hard`, the board must contain exactly 25 arrows. There must be no empty cells. Medium levels may continue to use partial boards.

This requirement must be enforced by generation and tests:

```dart
final arrowCount = level.arrows.whereType<ArrowDirection>().length;
if (level.difficulty != ArrowBoxDifficulty.medium && arrowCount != 25) {
  throw StateError('Dense levels must fill the board');
}
```

The current random forward generator can stop early, so it cannot be used as the sole guarantee. A failed candidate must be retried with a different deterministic seed or rejected; it must never be silently accepted with fewer arrows.

### 6.3 Full-board solvability construction

Use reverse construction with an explicit removal order:

1. Start with an empty 5 × 5 board.
2. Choose a deterministic removal order for all 25 cells.
3. Add arrows in reverse removal order.
4. For each inserted cell, choose a direction whose path is clear through the currently placed arrows.
5. Prefer directions that satisfy the target dependency and branching metrics.
6. After all 25 arrows are placed, solve the final board using the real movement rules.
7. Reject candidates that do not clear all 25 cells or that fail the Ultra Hard constraints.

A full board is solvable because edge arrows can point outward initially. Subsequent arrows become available as blocking arrows are removed. The generator must prove this with the same `canEscape`/`move` rules used by gameplay.

### 6.4 Hard profile

Every Hard board must:

- Have exactly 25 arrows.
- Have at least one valid first move.
- Have a moderate initial branching factor.
- Contain meaningful dependencies rather than 25 mostly independent edge escapes.
- Be solvable without mistakes by the deterministic solver.

### 6.5 Ultra Hard profile

Every Ultra Hard board must:

- Have exactly 25 arrows.
- Have at least one valid first move.
- Frequently have exactly one valid first move, with a defined tolerance for occasional recovery levels.
- Have a high forced-choice ratio across the solution sequence.
- Have deep dependency chains covering most of the board.
- Contain blocked alternatives that are understandable from the arrow paths.
- Be fully solvable without guessing or relying on a hidden special rule.

Ultra Hard must be validated by actual search metrics, not just assigned based on level number or density. If a candidate has many independent valid moves, it must be downgraded or regenerated.

### 6.6 Difficulty thresholds

Store generator metrics for each candidate:

- Occupied-cell count.
- Initial valid-move count.
- Average valid-move count through the solution.
- Number and ratio of forced steps.
- Longest dependency chain.
- Solver completion length.

Suggested acceptance thresholds:

| Type | Occupancy | Initial choices | Forced-step ratio | Dependency target |
| --- | ---: | ---: | ---: | ---: |
| Medium | 8–15 | 2+ | below 0.70 | shallow/moderate |
| Hard | exactly 25 | 2–6 | 0.45–0.85 | deep |
| Ultra Hard | exactly 25 | 1–3 | 0.70+ | very deep |

These values must be calibrated against generated samples. They are constraints to tune, not permission to label an easy board Ultra Hard.

## 7. Generation Strategy

### 7.1 Preserve deterministic generation

Continue using seeded generation. A level must be identical when generated on Android, web, and future builds.

Use a stable seed formula based on level number and a catalog version:

```text
seed = catalogVersion * largePrime + levelNumber * anotherPrime + difficultyIndex
```

Do not use runtime time, device state, or an unseeded random generator.

### 7.2 Generate by reverse construction

The current generator places arrows whose paths are clear at generation time. For harder levels, use reverse solution construction:

1. Start with an empty board.
2. Choose a removal sequence or dependency order.
3. Insert arrows in reverse order so the final forward sequence is guaranteed.
4. Evaluate the resulting board.
5. Reject and regenerate if its measured difficulty does not match the target.

This maintains the existing solvability guarantee while enabling control over dependency depth and branching factor.

### 7.3 Difficulty-specific constraints

Use separate generator profiles:

#### Medium profile

- Lower arrow density.
- More edge-facing arrows.
- Several valid first moves.
- Limited dependency depth.
- Avoid excessive forced sequences.

#### Hard profile

- Higher density.
- More interior arrows.
- Moderate number of valid first moves.
- Longer dependency chains.
- More blocked-looking alternatives.

#### Ultra Hard profile

- High density, potentially up to 25 arrows.
- Deep dependency chains.
- Frequent single-choice states.
- Low average branching factor.
- No accidental deadlock and no impossible first move.

### 7.4 Generator validation loop

Each candidate level should pass all of these checks before being added:

1. Exactly 25 board cells.
2. Arrow count is within the profile range.
3. At least one valid move exists unless the board is intentionally an empty terminal state, which should not be generated.
4. A solver clears the board without using mistakes.
5. The solver does not exceed a defined search limit.
6. The measured difficulty falls within the assigned profile range.
7. The seed and generated board are deterministic.
8. The board is not a duplicate of an earlier level.
9. The level does not create an unfair initial state that requires guessing.

Generation should fail loudly during development if it cannot produce the requested number of valid levels within a bounded attempt count. It should not silently append weak or unsolvable boards.

## 7. Solver and Validation Tools

Add a test-only or internal validation solver that can:

- Find a complete valid removal sequence.
- Count available moves at each state.
- Calculate dependency depth.
- Calculate forced-choice frequency.
- Detect duplicate boards.
- Produce summary statistics by difficulty.

The solver should use the existing `canEscape` and `move` rules rather than duplicating movement behavior. If search is needed, use memoization keyed by the board state to avoid repeatedly exploring identical states.

For generated catalog validation, run the full 500-level solver test in CI or local validation. If runtime becomes too high, split validation into deterministic batches while retaining a full release validation command.

## 8. Progression and Persistence Changes

### 8.1 Level validation

Update all level range validation from 30 to the centralized catalog count:

- `AppStore._validLevel`.
- Completed-level parsing.
- Level-star parsing.
- Saved-game loading.
- `ArrowBoxState.fromJson`.
- Any route or preview validation.

Existing users with progress below level 31 should retain all progress unchanged.

### 8.2 Final-level behavior

Change `nextLevel()` so the final level does not wrap to level 1. It should either:

- Keep the completed final state and let the completion dialog return to level selection/main menu; or
- Return a dedicated `isFinalLevel` result to the screen.

Do not silently restart level 1 after completing level 500.

### 8.3 Saved-game compatibility

Saved games currently contain the numeric level and board state. Existing saved games remain compatible because levels 1–30 retain their board definitions and numeric identifiers.

Add optional metadata only if needed; do not make old saved JSON invalid. If difficulty is stored, treat it as informational and derive the authoritative difficulty from the level catalog.

### 8.4 Progress reset

Keep reset behavior unchanged, but ensure it clears progress for the expanded range and removes all saved games across all levels.

## 9. Level Selection UX

A 500-level four-column grid is technically lazy-renderable but difficult to navigate. Update the screen with:

- Search by level number.
- Difficulty filter: All, Medium, Hard, Ultra Hard.
- Current-level shortcut.
- Completed/uncompleted filter if useful.
- Section or page grouping, such as levels 1–50, 51–100, etc.
- Difficulty badge or visual indicator on each tile.
- A compact progress summary showing completed levels out of 500.

The existing level tile should continue to show:

- Level number.
- Best stars.
- Locked state.
- Current-level state.
- Difficulty indicator.

Use lazy building and avoid constructing all 500 route objects at once. Opening a level should still load only the selected level.

Do not rely on color alone for difficulty. Include text, an icon, or a semantic label for accessibility.

## 10. Progress and Home Screen Updates

Replace every hardcoded `30` in visible copy and calculations with `AppStore.totalLevels` or a derived value:

- Landing progress summary.
- Level-selection summary.
- Circular progress ratio.
- Progress metric cards.
- Tutorial or About copy if it references the catalog size.
- README and screenshots/documentation where applicable.

Progress should display values such as `42 / 500 levels` and remain readable on mobile widths.

## 11. Difficulty Presentation

Add a small reusable difficulty badge with theme-aware colors:

- Medium: blue/cyan treatment.
- Hard: amber/orange treatment.
- Ultra Hard: pink/red treatment.

The badge must remain legible in both light and dark themes. Avoid using the same colors as directional arrows in a way that causes confusion. Add semantics such as:

```text
Level 237, Ultra Hard, locked
```

for screen readers and automated tests.

## 12. Testing Plan

### 12.1 Model tests

Add tests for:

- The catalog contains exactly 500 levels.
- Every level number from 1 through 500 resolves.
- Difficulty distribution matches the configured targets.
- Difficulty schedule is deterministic.
- Each board has exactly 25 cells.
- Every level is solvable.
- No generated board is duplicated.
- Each level's measured difficulty matches its assigned profile.
- Level 1, level 3, and the existing reference behavior remain unchanged.
- `nextLevel()` moves from 499 to 500 and does not wrap from 500 to 1.

### 12.2 Persistence tests

Add tests for:

- Unlocking levels above 30.
- Loading completed levels such as 250 and 500.
- Loading star records for high level numbers.
- Saving and loading an in-progress level such as 417.
- Rejecting invalid levels above 500.
- Preserving existing saved games from levels 1–30.
- Resetting all expanded progress.

### 12.3 Widget tests

Update and extend tests for:

- `500` appearing in progress summaries.
- Level-selection filtering by difficulty.
- Search results for high level numbers.
- Locked and unlocked level 500 states.
- Difficulty labels and accessibility semantics.
- Narrow mobile layouts with filter controls.
- Progress cards without overflow.

### 12.4 Performance tests

Measure:

- App startup time with the 500-level catalog initialized.
- Level-selection first-frame time.
- Memory use while scrolling the catalog.
- Catalog generation time.
- Full solvability-test duration.

If eager generation causes unacceptable startup cost, generate the catalog once into a checked-in deterministic data file or lazily cache levels by number. Do not sacrifice deterministic validation.

## 13. Implementation Sequence

### Phase 1: Catalog abstraction

1. Introduce `ArrowBoxDifficulty`.
2. Expand `ArrowBoxLevel` metadata.
3. Centralize total-level access.
4. Preserve existing levels 1–3 exactly.
5. Replace hardcoded range checks.
6. Add catalog and metadata tests.

### Phase 2: Generator and solver

1. Implement deterministic profile-based generation.
2. Implement solver metrics.
3. Add duplicate detection.
4. Generate the 500-level catalog.
5. Validate every level for solvability and difficulty.
6. Tune thresholds using generated statistics.

### Phase 3: Gameplay and progression

1. Update final-level navigation behavior.
2. Confirm saved games and completion records work through level 500.
3. Confirm hints, undo, timers, restart, and completion dialogs work with all difficulty types.
4. Add high-level persistence tests.

### Phase 4: UI and navigation

1. Update progress/home/selection counts.
2. Add level-selection search and filters.
3. Add difficulty badges and semantics.
4. Add grouping or paging for 500 levels.
5. Test portrait widths around 320, 375, and 412 logical pixels.

### Phase 5: Release validation

1. Run `flutter analyze`.
2. Run the full test suite.
3. Run the complete catalog solvability validation.
4. Build web and Android debug artifacts.
5. Manually play representative Medium, Hard, and Ultra Hard levels.
6. Verify saved-game resume, reset progress, final-level completion, and theme switching.
7. Update README and release notes.

## 14. Acceptance Criteria

The expansion is complete when:

- The app exposes exactly 500 deterministic levels.
- Levels are visibly labeled Medium, Hard, or Ultra Hard.
- Difficulty types are mixed throughout progression with an increasing overall curve.
- Every level is solvable using the existing movement rules.
- Harder levels demonstrate deeper dependencies and lower branching factors than Medium levels.
- Existing progress and saved games for levels 1–30 remain valid.
- Level 500 completes without wrapping to level 1.
- Level selection remains usable on a mobile viewport.
- Progress and home screens correctly show totals out of 500.
- All tests, analysis, and release builds pass.
- No image assets are modified or processed as part of the level expansion.

## 15. Risks and Decisions to Revisit

### Generator performance

Generating and validating 500 boards may be expensive if each candidate requires exhaustive search. Use bounded deterministic generation and memoized validation. If necessary, precompute and check in the catalog while keeping the generator available for verification.

### Difficulty fairness

Ultra Hard should be demanding but not arbitrary. A low branching factor is acceptable; an unexplained deadlock is not. Manual playtesting of representative levels is required even after automated validation.

### Catalog updates

Changing generation logic can change boards for existing level numbers. Keep the first 30 boards stable and introduce a catalog version. Future generator changes should either preserve all published boards or intentionally migrate the catalog with a clear version policy.

### Storage size

Per-level saved games and 500-level progress remain small with the current JSON format, but saved-game serialization should continue storing only active sessions and not every generated board.
