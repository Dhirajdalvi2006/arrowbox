# ArrowBox Level Validation Report

Generated: 2026-10-28

## Current result

The generator now exposes structured outcomes and the standalone validator supports bounded range validation with atomic checkpoint/resume. Difficulty thresholds were not changed.

A complete 500-level validation is still incomplete. The standalone validator and the catalog-wide Flutter generation test both exceed the available execution budget before all levels finish. No incomplete or budget-exhausted level is reported as passed.

## Structured generation outcomes

`BoardGenerationStatus` distinguishes:

- `SUCCESS`: generation completed and final verification returned a valid board.
- `UNSOLVABLE`: reserved for a conclusive proof that no valid solution exists.
- `BUDGET_EXHAUSTED`: the configured attempt or node budget ended before success.
- `INVALID_CONFIGURATION`: invalid arrow-count, constraint, or budget configuration.

The existing list-returning production API remains available for gameplay callers. The new outcome API carries status, board, reason, level, difficulty, and `BoardGenerationStats` including attempts, nodes, backtracks, solver calls, rejection counters, and elapsed time.

## Resumable validator

New tool: `tool/resume_arrowbox_catalog.dart`

Supported options:

- `--start=N`
- `--end=N`
- `--checkpoint=PATH`
- `--maxAttempts=N`
- `--maxNodes=N`

Checkpoint behavior:

- Writes after every level using a temporary file and rename.
- Stores schema version, exact range, configuration fingerprint, status, diagnostics, and successful layout keys.
- Skips only existing `SUCCESS` entries.
- Retries `BUDGET_EXHAUSTED`, `UNSOLVABLE`, and `INVALID_CONFIGURATION` entries.
- Rejects incompatible configuration/range and out-of-range checkpoint entries.
- Reports `complete=false` and exits non-zero when any requested level is incomplete.

Verified small-range runs:

- Range 1–2 with `maxAttempts=1`, `maxNodes=1`: both recorded `BUDGET_EXHAUSTED`; run incomplete.
- Range 1–2 with normal budgets: both recorded `SUCCESS`; run complete.
- Outcome/checkpoint tests: 2 passed.

## Performance diagnostics

Latest bounded diagnostics for the previously problematic levels:

| Level | Band | Status | Attempts | Nodes | Latest observed runtime |
|---:|---|---|---:|---:|---:|
| 200 | Medium | Generated | 7 | 336,954 | ~2.4 s |
| 350 | Hard | Generated | 41 | 2,032,815 | ~14.3 s |
| 351 | Ultra Hard | Generated | 8 | 362,862 | ~2.6 s |

Hard 350 remains the outlier. Instrumentation indicates construction/backtracking dominates; solver verification is invoked only after candidate construction reaches a leaf and is not the primary cost in the latest probe.

## Validation commands

Passed:

- `flutter test test/appearance_test.dart` — 4 passed.
- `flutter test test/board_generation_outcome_test.dart` — 2 passed.
- `dart analyze` — no issues.
- `flutter analyze` — no issues.
- `flutter build apk --debug` — succeeded; APK built in approximately 28.6 seconds.
- `git diff --check` — passed with only CRLF conversion warnings.
- Small-range checkpoint validation — completed successfully for levels 1–2.

Incomplete:

- `flutter test test/level_generation_test.dart` reached the catalog-wide replay test and exceeded 600 seconds without a reported assertion failure.
- Full standalone 500-level validation remains incomplete and must be resumed through the checkpoint validator.

## Difficulty separation

Hard and Ultra Hard are not yet proven measurably distinct across the complete catalog. No stronger Ultra Hard thresholds were introduced.

## Remaining gaps

- Complete the 1–500 checkpointed validation.
- Produce catalog-wide duplicate, determinism, solvability, and difficulty statistics from completed checkpoint entries.
- Add a conclusive solver result type if the project later needs to distinguish proven unsolvability from search exhaustion internally.
