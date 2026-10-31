# Modular Architecture Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or native execution to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor ArrowBox into a clean, modular, feature-first Flutter architecture where every screen has its own file, gameplay UI is separated from game logic, level catalogs and generation are isolated, and all 500 levels and existing behaviors are preserved.

**Architecture:**
- `lib/app.dart`: Slender configuration holding `MaterialApp`, theme integration, debug routes, and root navigation.
- `lib/features/`: Dedicated feature directories (`home`, `level_selection`, `arrowbox`, `settings`, `progress`, `how_to_play`, `about`, `arrow_lab`, `arrow_designs`, `auth`, `shell`, `splash`).
- `lib/core/`: Application-wide services (theme, audio, auth, persistence, widgets).
- Compatibility exports in `lib/app.dart` to maintain backwards compatibility with existing tests and imports during transition.

**Tech Stack:** Flutter, Dart 3, SharedPreferences, audioplayers, Firebase Auth (offline-tolerant).

---

## Global Constraints

- Never redesign the UI or change gameplay mechanics, timers, lives, or scoring.
- All 500 levels must remain identical and deterministically reproducible.
- Preserve existing SharedPreferences keys, audio filenames, and asset paths.
- Keep offline gameplay fully functional; do not add external database sync or network dependencies.
- No new external state-management dependencies (no Bloc, Riverpod, etc.).

---

## Review Focus

1. **Screen navigation & popscope**: Back buttons on standalone and embedded screens must never pop the root route into a blank screen.
2. **500-level catalog determinism**: All 500 levels, seeds, and difficulty distributions must remain strictly intact across checkpoint tests.
3. **Gameplay board & animation lifecycle**: Controller disposal, escape offsets, hint double-pulse, and gesture hitboxes must not regress.
4. **Appearance synchronization**: Changes in ArrowLab (`boardThemeId`, `arrowSkinId`) must synchronously reflect in gameplay and preview.
5. **Narrow viewport safety**: Completion dialogs, HUD hearts row, and level grid must not cause RenderFlex overflow on small screens (e.g. 320-360dp width).

---

### Task 1: Extract Non-Gameplay Screens from `app.dart`

**Files:**
- Create:
  - `lib/features/home/screens/home_screen.dart`
  - `lib/features/home/widgets/home_header.dart`
  - `lib/features/level_selection/screens/level_selection_screen.dart`
  - `lib/features/level_selection/widgets/level_tile.dart`
  - `lib/features/settings/screens/settings_screen.dart`
  - `lib/features/settings/widgets/settings_container.dart`
  - `lib/features/settings/widgets/settings_switch_row.dart`
  - `lib/features/settings/widgets/settings_radio_row.dart`
  - `lib/features/progress/screens/progress_screen.dart`
  - `lib/features/progress/widgets/circular_progress_card.dart`
  - `lib/features/progress/widgets/metric_card.dart`
  - `lib/features/how_to_play/screens/how_to_play_screen.dart`
  - `lib/features/how_to_play/widgets/tutorial_step_card.dart`
  - `lib/features/about/screens/about_screen.dart`
  - `lib/features/about/widgets/about_action_row.dart`
- Modify: `lib/app.dart`

- [x] **Step 1: Extract `HomeScreen` (currently `WelcomeScreen`) and widgets**
- [x] **Step 2: Extract `LevelSelectionScreen` and `_LevelTile`**
- [x] **Step 3: Extract `SettingsScreen` and helper widgets**
- [x] **Step 4: Extract `ProgressScreen` and metrics/circular progress widgets**
- [x] **Step 5: Extract `HowToPlayScreen` and step visual widgets**
- [x] **Step 6: Extract `AboutScreen` and action rows**
- [x] **Step 7: Re-export extracted screens from `lib/app.dart` for backwards compatibility**
- [x] **Step 8: Verify compilation and tests**
  Run: `flutter test test/appearance_test.dart test/theme_selection_card_test.dart`

---

### Task 2: Refactor Gameplay UI and Dialogs

**Files:**
- Create:
  - `lib/features/arrowbox/widgets/gameplay_hud.dart`
  - `lib/features/arrowbox/widgets/gameplay_board.dart`
  - `lib/features/arrowbox/widgets/gameplay_controls.dart`
  - `lib/features/arrowbox/dialogs/pause_dialog.dart`
  - `lib/features/arrowbox/dialogs/level_complete_dialog.dart`
  - `lib/features/arrowbox/dialogs/game_over_dialog.dart`
  - `lib/features/arrowbox/screens/arrowbox_screen.dart`
- Modify:
  - `lib/features/arrowbox/arrowbox_dialogs.dart` (re-export or delegate)
  - `lib/features/arrowbox/arrowbox_screen.dart`

- [x] **Step 1: Extract dialogs into dedicated files and fix narrow-screen flex overflows**
- [x] **Step 2: Extract `GameplayHud` (hearts, mistakes, timer, difficulty chip, restart/hint controls)**
- [x] **Step 3: Extract `GameplayBoard` (stack container, layout constraints, empty cells, animated tiles)**
- [x] **Step 4: Simplify `ArrowBoxScreen` to screen composition, game controller wiring, and navigation**
- [x] **Step 5: Verify gameplay tests**
  Run: `flutter test test/arrowbox_logic_test.dart test/hint_regression_test.dart`

---

### Task 3: Clean Level Catalog Architecture & Facade

**Files:**
- Review & Organize:
  - `lib/features/arrowbox/levels/`
  - Create facade `lib/features/levels/levels.dart` re-exporting catalog, generator, rules, solver, manifest
- Test:
  - `test/catalog_manifest_verification_test.dart`
  - `test/migrated_catalog_checkpoint_test.dart`
  - `test/level_generation_test.dart`

- [x] **Step 1: Create clean level export facade**
- [x] **Step 2: Run catalog integrity tests to guarantee all 500 levels remain intact**
  Run: `flutter test test/catalog_manifest_verification_test.dart test/migrated_catalog_checkpoint_test.dart`

---

### Task 4: Fix Pre-existing Test Regressions & Inconsistencies

**Files:**
- Modify:
  - `lib/features/arrowbox/dialogs/level_complete_dialog.dart` (prevent flex overflow on narrow screens)
  - `test/widget_test.dart` (align button label checks with "Play Adventure" / "Play Now" and tagline)
  - `test/audit_regression_test.dart` (handle undo test based on current gameplay control model)

- [x] **Step 1: Fix RenderFlex overflow in Level Complete Dialog hearts row**
- [x] **Step 2: Align `test/widget_test.dart` with current landing page labels**
- [x] **Step 3: Update `test/audit_regression_test.dart` or restore required Undo flow if applicable**
- [x] **Step 4: Run full test suite**
  Run: `flutter test`

---

### Task 5: Final Verification and Documentation

**Files:**
- Update: `README.md`
- Run:
  - `dart format lib test`
  - `flutter analyze`
  - `flutter test`
  - `flutter build apk --debug`

- [x] **Step 1: Format all code**
- [x] **Step 2: Run static analysis**
- [x] **Step 3: Run full automated tests**
- [x] **Step 4: Run Android debug build verification**
- [x] **Step 5: Update README.md with the clean architecture guide**
