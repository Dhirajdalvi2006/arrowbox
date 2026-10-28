# ArrowBox Level Validation Report

Generated: 2026-10-28

## Result

The requested catalog-wide audit could not complete within the available execution window. The standalone validator uses the production generators, solver, and `arrowCanEscape` rule and does not launch `flutter_tester.exe`. Both the original exhaustive pass and the optimized one-pass run exceeded the 600-second execution limit before writing a report.

The audit therefore does **not** claim complete 500-level statistics. It does establish production generation failures at the following levels through direct standalone probes:

| Level | Band | Result | Runtime |
|---:|---|---|---:|
| 200 | Medium | `StateError: Unable to generate solvable board for seed 1583901` | 7,838 ms |
| 350 | Hard | `StateError: Unable to generate solvable board for seed 2771861` | 15,708 ms |
| 351 | Ultra Hard | `StateError: Unable to generate solvable board for seed 2779876` | 14,594 ms |

Each failure occurs after the production generator's bounded 10,000-attempt search. These are invalid generation results, not solver inconclusive results.

## Representative successful probes

| Band | Level | Arrows | Runtime |
|---|---:|---:|---:|
| Easy | 1 | 8 | 22 ms |
| Easy | 50 | 15 | 12 ms |
| Easy | 100 | 20 | 13 ms |
| Medium | 101 | 16 | 28 ms |
| Medium | 150 | 19 | 3 ms |
| Hard | 201 | 20 | 341 ms |
| Hard | 275 | 22 | 2,764 ms |
| Ultra Hard | 425 | 25 | 2,398 ms |
| Ultra Hard | 500 | 25 | 6,917 ms |

These probes are not a substitute for catalog-wide statistics. They demonstrate that some levels are fast while others consume seconds or exhaust the generation bound.

## Intended bands checked by the harness

- Levels 1–100: Easy.
- Levels 101–200: Medium.
- Levels 201–350: Hard.
- Levels 351–500: Ultra Hard.

The harness checks board size, arrow-count profile, direction balance, solver result, production-rule solution replay, duplicate layouts, and deterministic regeneration at selected band boundaries. It records generator exceptions as invalid and solver `null` results as inconclusive; it does not treat search exhaustion as proof of unsolvability.

## Current profile observations

- Easy uses a gradual density curve from 8 to 20 arrows.
- Medium targets 16–23 arrows.
- Hard targets 20–25 arrows.
- Ultra Hard targets exactly 25 arrows.
- Hard and Ultra Hard require at least three arrows in every direction.
- Ultra Hard has not been demonstrated to be measurably harder than Hard by the current solver metrics.
- Earlier measured samples reported lower average dependency depth and forced-move ratio for Ultra Hard than Hard. Those values are not re-presented as a complete current-catalog result.

## Limitations

1. The production generator does not expose the exact attempt count used for successful generations.
2. `LevelSolver.analyze` returns `null` for both unsolvable boards and search exhaustion, so a `null` result cannot be classified as proven unsolvable.
3. The solver returns the first successful DFS path rather than an optimized solution; dependency depth and forced-move ratio are path-dependent.
4. The catalog initializer eagerly generates all 500 levels, so the validator intentionally calls the production mode generators directly to avoid unrelated eager initialization.
5. The validator writes its report only after all levels finish. The full run produced no partial report before the execution limit.
6. Flutter tests could not execute because Windows Application Control blocked `flutter_tester.exe`; that policy was not bypassed.

## Validation status

- Complete 500-level generation audit: **incomplete due to runtime limit**.
- Proven generation failures: **3 representative levels** — 200, 350, and 351.
- Proven unsolvable levels: **none established by this audit**.
- Inconclusive solver results: **not available catalog-wide because the audit did not finish**.
- Ultra Hard measurably harder than Hard: **not established**.
- Production difficulty rules changed for this audit: **no**.
