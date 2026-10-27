# ArrowBox

ArrowBox is an offline Flutter puzzle game in which players clear a 5 × 5 board by tapping directional arrow tiles whose paths are unobstructed. The project includes the playable ArrowBox experience, level selection, persistent progress, theme and gameplay settings, tutorial/help content, progress statistics, and an about/privacy view.

The application is designed for portrait mobile play and does not require a network connection or a backend service.

## Contents

- [Product overview](#product-overview)
- [Gameplay rules](#gameplay-rules)
- [Implemented user flows](#implemented-user-flows)
- [Game state and level generation](#game-state-and-level-generation)
- [Persistence and settings](#persistence-and-settings)
- [Visual system](#visual-system)
- [Project structure](#project-structure)
- [Application startup and routing](#application-startup-and-routing)
- [Testing and validation](#testing-and-validation)
- [Running the project](#running-the-project)
- [Web preview routes](#web-preview-routes)
- [Known limitations](#known-limitations)
- [Future development](#future-development)

## Product overview

ArrowBox is a focused, offline arrow-escape puzzle game. Every occupied board cell contains an arrow pointing up, right, down, or left. An arrow can be removed only when every board cell between it and the board edge is empty in the direction it points.

The current application provides:

- A branded landing screen.
- A 500-level progression system with Medium, Hard, and Ultra Hard boards plus persistent best-performance star ratings.
- A playable ArrowBox board.
- Clear-path validation for every move.
- Lives and mistake tracking.
- An elapsed gameplay timer.
- Undo, restart, and hint controls.
- Pause, resume, and pause-menu navigation.
- Level completion and game-over dialogs.
- Saved in-progress games.
- Persistent level completion and unlock progress.
- Light, dark, and system theme modes.
- Gameplay, audio, and appearance settings.
- Progress statistics.
- A four-step tutorial.
- Offline privacy and credits dialogs.

The application is built with Flutter and Dart. The package name remains `locate`, while the visible product name and application title are `ArrowBox`.

## Gameplay rules

### Board

- Each level uses a 5 × 5 board containing 25 fixed-position cells.
- A cell is either empty or contains one directional arrow.
- Empty cells remain visible with a dark/light cell surface, border, and centered dot.
- The board uses controlled grid constraints rather than a wrapping layout, so all five columns remain aligned.

### Valid move

1. The player taps an occupied cell.
2. The game reads the arrow direction.
3. The game walks through the board in that direction.
4. If every cell on the path to the edge is empty, the move is valid.
5. The tile animates outward, is removed from the board, and the move count increases.
6. The resulting board is added to undo history.
7. When all arrows are removed, the level is complete.

### Blocked move

If another arrow occupies the path:

- The arrow remains on the board.
- The tile receives rejection/shake feedback.
- One life is removed.
- The mistake count increases.
- The move count increases.
- When lives reach zero, the game enters the game-over state.

### Lives

Each game starts with three lives. The gameplay header displays three hearts using the real `lives` value. Remaining lives are filled and glowing; lost lives use an outlined/muted treatment.

### Timer

The gameplay timer is ready when the gameplay screen is created and begins tracking once the player makes their first move. It increments once per second while the game is active. It stops while paused and when the level is cleared or the player runs out of lives. The saved game stores the elapsed seconds so an in-progress game can resume with its previous time.

### Undo

Undo is available after a valid arrow removal. It restores the previous board snapshot and reduces the move count by one. Blocked moves do not add board snapshots to the undo history. The Undo button is disabled while the board is busy, paused, or has no valid history.

### Restart

Restart restores the current level to its original board with three lives, zero mistakes, zero moves, zero elapsed seconds, and an empty undo history. When `Confirm before restart` is enabled, the player must confirm before the reset occurs.

### Hints

The hint system scans the board from the first cell to the last and selects the first arrow that currently has a clear path. The selected tile is highlighted and the hint panel describes its color and direction. If no arrow can currently escape, the panel explains that a blocking arrow must be freed first.

Each level allows up to three hints. The Hint control displays remaining uses and disables after the third use. Hint usage is persisted with the saved board and reduces the completion rating when used. The Hint control is available only when `Show hints` is enabled.

## Implemented user flows

### Landing screen

The landing screen contains:

- ArrowBox logo asset and wordmark.
- Hero artwork.
- `Think. Aim. Escape.` tagline.
- `Play Now` action.
- `Continue Level N` action when a resumable saved game exists.
- Progress summary card.
- Links to Progress, How to Play, and About.
- Theme toggle.
- Settings navigation.

`Play Now` opens level selection. `Continue Level N` opens the saved board state instead of starting from the beginning of that level.

### Level selection

The level-selection screen displays the 500-level catalog in a four-column grid with numeric search and difficulty filtering.

- Completed levels are highlighted and show three stars.
- The current unlocked level is emphasized.
- Future locked levels show a lock and cannot be opened.
- The summary card displays completed levels out of 500.
- Opening a level resumes that level's saved state when one exists; otherwise it creates a fresh `ArrowBoxState`.

Completing level N unlocks level N + 1, except after level 500. Levels are mixed across Medium, Hard, and Ultra Hard difficulty bands with an increasing overall challenge curve. Levels can be replayed after they have been unlocked. Completion awards a performance rating based on mistakes and hints: three stars requires zero mistakes and no hints, two stars allows at most one mistake and one hint, and all other completions earn one star. Replaying a level can improve its stored rating, but never lowers the best rating already earned.

### Gameplay

The gameplay screen contains:

- Large circular back button.
- Compact supplied ArrowBox logo beside the `ArrowBox` wordmark.
- Current level label sourced from game state.
- Large circular pause button.
- Three-heart lives indicator.
- Mistake counter.
- Elapsed-time pill.
- Responsive 5 × 5 board.
- Direction-specific gradient arrow tiles.
- Empty cells with centered dots.
- Hint panel, when enabled.
- Undo, Restart, and Hint controls.

The back action saves the current board and timer before popping the gameplay route. The screen also saves an active state during disposal when the game is neither cleared nor over; finished and game-over states are deliberately not re-saved as resumable games.

### Pause interface

Pause overlays the gameplay board and prevents move interaction and timer increments. It provides:

- Resume.
- Restart level.
- Settings.
- Level selection.
- Main menu.

The timer is resumed when the player selects Resume or when a restart action resumes the game.

### Level-complete interface

After the board is cleared, the application records completion and displays:

- Completed level number.
- Move count.
- Mistake count.
- Elapsed time.
- Next Level.
- Replay Level.
- Level Selection.
- Main Menu.

The completion record updates unlocked progress and total mistakes. The final level (500) clears the saved-game entry and returns to the root route instead of opening a level beyond the catalog.

### Game-over interface

When all three lives are lost, the game-over interface displays the level and mistake count and provides:

- Restart Level.
- Level Selection.
- Main Menu.

### Settings

Settings are grouped into four areas.

#### Gameplay

- Haptic feedback: controls light, medium, and selection haptic calls.
- Show hints: controls whether the hint panel is shown.
- Confirm before restart: controls whether restart confirmation is displayed.

#### Audio

- Sound effects toggle is persisted, but no sound effect playback engine is currently implemented.
- Background music toggle is persisted, but no music playback engine is currently implemented.
- Music volume is persisted as a value from 0.0 to 1.0, but it currently has no audio output to control.

#### Appearance

- System theme.
- Light theme.
- Dark theme.

The selected theme is restored on the next launch.

#### Data

- Reset Settings restores settings defaults without clearing progress.
- Reset Progress clears unlocked level, completed levels, game count, mistake totals, and the saved game after confirmation.

### Progress

The Progress screen displays:

- Completed levels out of 500.
- Circular completion visualization.
- Total configured levels.
- Current unlocked level.
- Games played.
- Total recorded mistakes.

### How to Play

The tutorial explains four concepts:

1. Each block has a direction.
2. An arrow needs a clear path to the edge.
3. A successful arrow is removed.
4. Removing every arrow completes the level.

### About

The About screen displays the ArrowBox branding, version label, project description, and actions for:

- Offline privacy information.
- Credits.

The privacy copy describes the intended offline behavior: no personal data, tracking, or device identifiers are collected or transmitted by the application.

## Game state and level generation

The game model is implemented in `lib/features/arrowbox/arrowbox_logic.dart`.

### Direction model

`ArrowDirection` defines four directions and their row/column vectors:

| Direction | Row step | Column step |
| --- | ---: | ---: |
| Up | -1 | 0 |
| Right | 0 | 1 |
| Down | 1 | 0 |
| Left | 0 | -1 |

The enum also supplies human-readable direction text and the color name used in hint messages.

### Levels

There are 500 levels.

- Level 1 is a hand-authored introductory board.
- Level 2 is generated deterministically from a fixed seed.
- Level 3 is the authored reference-style board used by the widget tests and initial hint test.
- Levels 4 through 30 retain their original deterministic boards for compatibility.
- Levels 31 through 500 are generated deterministically across Medium, Hard, and Ultra Hard difficulty profiles with increasing target arrow density.

The generator builds boards by repeatedly selecting an empty cell and a direction whose path is currently clear. This construction order guarantees that each generated level has at least one valid solution sequence. The test suite solves every configured level to verify this property.

### `ArrowBoxState`

The state object contains:

- `board`: 25 nullable arrow directions.
- `level`: current level number.
- `lives`: remaining lives from 0 to 3.
- `mistakes`: blocked-move count.
- `moves`: total attempted move count.
- `secondsElapsed`: saved elapsed time.
- `history`: previous valid board snapshots for Undo.

The state supports JSON serialization for persistence and validates saved data before accepting it.

## Persistence and settings

Persistence is implemented by `AppStore` in `lib/core/app_store.dart` using `shared_preferences`.

### Stored progress

- `unlockedLevel`
- `completedLevels`
- `levelStars` (serialized as `level:stars` entries)
- `gamesPlayed`
- `totalMistakes`
- `savedGame`

A saved game contains the current level, board, lives, mistakes, moves, elapsed seconds, hint usage, and valid-move undo history. Saved sessions are stored per level, so leaving one level does not overwrite another level's in-progress board. Invalid saved-game JSON is discarded during startup rather than crashing the application.

### Stored preferences

- `soundEnabled`
- `musicEnabled`
- `musicVolume`
- `hapticsEnabled`
- `hintsEnabled`
- `confirmRestart`
- `themeMode`

The store validates persisted level numbers, completed-level values, non-negative counters, theme indexes, and saved board data before exposing them to the UI.

`AppStore` extends `ChangeNotifier`. `ArrowBoxApp` listens to it with `AnimatedBuilder`, so changes to settings and progress are reflected in the active application shell.

## Visual system

### Branding assets

The declared assets are:

- `assets/images/arrowbox_cube_logo.png`: compact ArrowBox logo used beside the wordmark.
- `assets/images/arrowbox_hero.png`: larger hero artwork used on the landing and About screens.

The gameplay header uses the compact logo asset rather than the hero artwork. The logo widget contains a vector fallback for environments where the asset cannot load.

### Theme

The theme system is defined by `AppTheme` and `AppColors`.

Dark mode uses deep navy surfaces, blue borders, cyan accents, and light text. Light mode uses neutral backgrounds and white surfaces while retaining the directional arrow gradients and readable dark text.

The app supports `ThemeMode.system`, `ThemeMode.light`, and `ThemeMode.dark`. The persisted default is dark mode when no preference exists.

### Directional tile styling

Reusable `GradientArrowTile` widgets provide:

- Direction-aware gradient colors.
- Rounded tile geometry.
- Thin bright borders.
- Colored glow/shadow.
- Upper highlight treatment.
- White directional icon.
- Entry animation.
- Tap compression.
- Hint pulse animation.
- Escape animation.
- Blocked-move shake animation.

The current palettes are:

| Direction | Palette |
| --- | --- |
| Up | Cyan-blue → electric blue → deep blue |
| Right | Light amber → orange → deep orange |
| Down | Coral → hot pink → red-pink |
| Left | Pale mint → emerald mint → deep teal |

## Project structure

```text
.
├── assets/
│   └── images/
│       ├── arrowbox_cube_logo.png
│       └── arrowbox_hero.png
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── app_store.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       └── arrowbox_widgets.dart
│   └── features/
│       └── arrowbox/
│           ├── arrowbox_logic.dart
│           ├── arrowbox_screen.dart
│           ├── arrowbox_board_widgets.dart
│           └── arrowbox_dialogs.dart
├── test/
│   ├── arrowbox_logic_test.dart
│   └── widget_test.dart
├── docs/
│   ├── redesign-plan.md
│   └── ui-audit.md
├── android/
├── web/
├── pubspec.yaml
└── analysis_options.yaml
```

### Source responsibilities

- `main.dart`: initializes Flutter, locks the app to portrait orientation, loads `AppStore`, and starts `ArrowBoxApp`.
- `app.dart`: configures `MaterialApp`, themes, preview routing, and the landing, level selection, settings, progress, tutorial, and About screens.
- `app_store.dart`: loads and persists progress, settings, saved games, and statistics.
- `arrowbox_logic.dart`: owns directions, levels, board validation, movement, lives, mistakes, undo history, hints, restart, and level transitions.
- `arrowbox_screen.dart`: coordinates gameplay state, timer, input locking, animations, persistence, pause, and completion/game-over flows.
- `arrowbox_board_widgets.dart`: renders active arrow tiles and empty board cells.
- `arrowbox_widgets.dart`: provides branding, artwork, shared action buttons, header buttons, and gameplay controls.
- `arrowbox_dialogs.dart`: provides pause, level-complete, and game-over overlays.
- `app_colors.dart` and `app_theme.dart`: define light/dark design tokens and Material themes.

## Application startup and routing

Startup is asynchronous:

1. Flutter bindings are initialized.
2. Orientation is restricted to portrait.
3. `AppStore.load()` reads SharedPreferences.
4. Saved progress and settings are validated.
5. `ArrowBoxApp` is created with the loaded store.
6. `MaterialApp` selects the current theme mode and builds the home flow.

The normal startup route is `WelcomeScreen`. The app also reads a `screen` query parameter from `Uri.base` for web previews and test/demo entry points.

## Web preview routes

The following query values can open specific screens directly in a web build:

| Query | Screen |
| --- | --- |
| `screen=levels` | Level selection |
| `screen=gameplay` | Gameplay preview starting at level 3 |
| `screen=pause` | Pause dialog preview |
| `screen=complete` | Level-complete dialog preview |
| `screen=gameover` | Game-over dialog preview |
| `screen=settings` | Settings |
| `screen=progress` | Progress |
| `screen=howtoplay` | How to Play |
| `screen=about` | About |

The dialog preview routes use no-op callbacks because they are visual/demo entry points. The normal in-app gameplay route supplies real navigation and state-changing callbacks.

Example:

```text
http://localhost:8080/?screen=gameplay
```

Use the actual host and port printed by `flutter run -d chrome`; do not assume a fixed port.

## Testing and validation

### Unit and model tests

`test/arrowbox_logic_test.dart` verifies:

- Direction vectors and descriptions.
- Edge and corner escape behavior.
- Blocked movement behavior.
- Life and mistake deductions.
- Game-over behavior.
- Restart behavior.
- Undo behavior.
- Solvability of all 500 levels.
- Level 3's initial hint and hint message.

### Widget tests

`test/widget_test.dart` verifies rendering and key text for:

- Landing screen.
- Level selection.
- Gameplay screen.
- Settings.
- Progress.
- How to Play.
- About.

The tests use mocked SharedPreferences values to make progress and statistics deterministic.

### Recommended validation commands

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

The project should be checked on a portrait mobile viewport at approximately 320, 375, and 412 logical pixels. Important interaction checks include valid escapes, blocked moves, life loss, undo, restart confirmation, pause/resume, hint highlighting, level completion, game over, saved-game resume, reset actions, and theme switching.

## Running the project

### Prerequisites

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml`.
- Android SDK for Android builds, or a configured browser/device target.
- A Windows, macOS, or Linux development environment supported by Flutter.

### Install dependencies

```powershell
flutter pub get
```

### Run on a connected device

```powershell
flutter devices
flutter run
```

For a specific device:

```powershell
flutter run -d <device-id>
```

### Run in a browser

```powershell
flutter run -d chrome
```

### Build Android debug APK

```powershell
flutter build apk --debug
```

The resulting APK is written to:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Dependencies

The application intentionally keeps dependencies small:

- `flutter`: application framework.
- `shared_preferences`: local progress, settings, statistics, and saved-game persistence.
- `flutter_test`: unit and widget test framework.
- `flutter_lints`: analyzer and lint recommendations.

No backend, database server, analytics SDK, audio package, or network API is required by the current implementation.

## Known limitations

These are current implementation facts, not hidden assumptions:

1. **Audio settings are preference-only.** Sound effects, background music, and music volume are stored and rendered in Settings, but no audio playback system is currently connected.
2. **Hint usage is limited to three per level.** The count is persisted with the saved game and affects completion stars.
3. **The game timer uses in-memory periodic updates while a screen is active.** The current elapsed value is persisted during navigation and lifecycle transitions, but elapsed time is not calculated from wall-clock timestamps while the app is suspended.
4. **The timer uses one-second periodic updates.** It is suitable for gameplay display, not precision timing.
5. **The app is portrait-only.** `main.dart` explicitly locks orientation to `portraitUp`.
6. **The visual query routes are previews.** The direct dialog preview routes intentionally use no-op callbacks.
7. **There is no cloud synchronization.** Progress is local to the device/browser storage used by SharedPreferences.
8. **The package name is still `locate`.** This is an internal project/package identifier and does not change the visible ArrowBox branding.
9. **The generated level builder is deterministic, not procedural at runtime.** Boards are generated once from fixed seeds when the level definitions are initialized.
10. **The current automated tests do not replace device-level interaction testing.** They verify game logic and key widget rendering but do not validate screenshots, haptics, physical back behavior, or every breakpoint.

## Future development

Possible next steps, if required by the product direction, include:

- Connect the existing audio settings to actual sound and music playback.
- Replace periodic elapsed-time display with timestamp-based timing across app suspension.
- Add integration tests for navigation, persistence, pause behavior, and saved-game resume.
- Add device/browser screenshot verification for the gameplay layout.
- Add accessibility labels and semantic assertions for board cells and controls.
- Add a real hint budget only if the product rules require limited hints.
- Extract the large screen collection from `app.dart` into feature-specific files as the application grows.
- Add release configuration, app icons, signing, and production deployment documentation.

## License and project status

This repository currently contains the ArrowBox application source and its local Flutter assets. No license file or open-source distribution terms are defined in the current project metadata; add one before publishing the project for external reuse.
