# GPT Project Guide: ArrowBox

This file is a context guide for an AI coding assistant working in this repository. Read it before changing code. It describes the current implementation as observed in the working tree, not an idealized future architecture.

## 1. Project identity

- **Product:** ArrowBox
- **Package name:** `locate` (legacy/internal identifier; do not rename casually)
- **Framework:** Flutter
- **Language:** Dart
- **Primary platform:** portrait mobile, with web preview support
- **Persistence:** local `shared_preferences`
- **Backend/network:** none
- **Current product focus:** an offline arrow-escape puzzle game
- **Current version in `pubspec.yaml`:** `1.1.0+2`
- **Visible app title:** `ArrowBox`

ArrowBox is a 5 × 5 puzzle game. Each occupied cell contains an arrow pointing up, right, down, or left. An arrow can be removed only when all cells between it and the board edge in its pointing direction are empty. The player clears the entire board while managing three lives, mistakes, hints, elapsed time, and undo history.

The repository is in an active redesign/consolidation state. The current active implementation is much smaller than the older game-hub implementation described in some historical documents. Trust the current `lib/` files and tests over stale planning/audit text when they disagree.

## 2. Important working-tree warning

The repository is currently dirty and contains a large migration from an older Offline Games Hub implementation to the current ArrowBox implementation. Do not discard, reset, clean, or broadly restore files without explicit authorization.

At the time this guide was written, the working tree included:

- Modified `README.md`, Android files, theme files, `lib/app.dart`, `lib/main.dart`, `pubspec.yaml`, `pubspec.lock`, and tests.
- Deleted legacy game-hub files such as the old home, favorites, recent, categories, search, all-games, game-card, and model files.
- Newly added active ArrowBox files under `lib/core/` and `lib/features/arrowbox/`.
- Untracked generated/build/development artifacts including `build/`, `android/build/`, `node_modules/`, `.playwright-mcp/`, screenshots, capture scripts, and some documentation.
- Some files had both staged and unstaged changes.

Before modifying or committing anything:

1. Run `git status --short`.
2. Inspect the relevant diff with `git diff` and, if needed, `git diff --cached`.
3. Do not use `git add .` or `git add -A` unless the user explicitly wants all files staged.
4. Do not commit unless the user explicitly asks for a commit.
5. Treat screenshots, generated folders, scripts, and the `Images to achieve/` directory as potentially intentional user work until inspected.

## 3. Active source layout

```text
.
├── assets/images/
│   ├── arrowbox_cube_logo.png
│   └── arrowbox_hero.png
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
│   ├── ui-audit.md
│   ├── 500-level-expansion-plan.md
│   └── superpowers/plans/...
├── android/
├── web/
├── pubspec.yaml
└── analysis_options.yaml
```

### File responsibilities

#### `lib/main.dart`

Application entry point. It:

1. Initializes Flutter bindings.
2. Locks the app to `DeviceOrientation.portraitUp`.
3. Loads `AppStore` asynchronously.
4. Starts `ArrowBoxApp`.

Do not remove the async startup or portrait lock without considering saved-state initialization and the mobile layout assumptions.

#### `lib/app.dart`

Contains `ArrowBoxApp` and most non-gameplay screens in one file:

- `WelcomeScreen`
- `LevelSelectionScreen`
- `SettingsScreen`
- `ProgressScreen`
- `HowToPlayScreen`
- `AboutScreen`
- Private screen-specific widgets and painters

`ArrowBoxApp` owns the `MaterialApp`, theme selection, global text styling, and web preview routing. It listens to `AppStore` through `AnimatedBuilder`, so store changes rebuild the app shell.

This file is intentionally large right now. Do not split it into multiple feature files as part of an unrelated bug fix unless the user asks for refactoring.

#### `lib/core/app_store.dart`

Owns persistent application state and settings through `SharedPreferences`. It extends `ChangeNotifier` and serializes writes through a private future queue to avoid write-order races.

It stores:

- Current unlocked level
- Completed levels
- Best stars per level
- Games played
- Total mistakes
- Per-level saved games
- Sound/music settings
- Music volume
- Haptics and hints settings
- Restart confirmation setting
- Theme mode

The store validates persisted values while loading. Invalid saved game JSON is ignored rather than allowed to crash startup.

#### `lib/features/arrowbox/arrowbox_logic.dart`

The source of truth for puzzle rules and game state. This file is the most important place to start for gameplay changes.

It contains:

- `ArrowDirection`
- `ArrowBoxDifficulty`
- `ArrowBoxLevel`
- Deterministic generation for 500 levels
- `ArrowBoxState`
- `ArrowMoveResult`

Keep game rules in this file rather than duplicating them in widgets.

#### `lib/features/arrowbox/arrowbox_screen.dart`

Stateful gameplay coordinator. It owns:

- Current immutable `ArrowBoxState`
- Timer and elapsed seconds
- Pause state
- Move locking while animations run
- Hint highlight
- Escape animation state
- Shake animation state
- Haptic feedback
- Saved-game writes
- Completion/game-over flows
- Navigation to settings, level selection, and main menu

The screen uses `WidgetsBindingObserver` to save active games when the app becomes inactive/paused/detached and saves again during disposal.

#### `lib/features/arrowbox/arrowbox_board_widgets.dart`

Rendering and animation widgets for the board:

- `GradientArrowTile`
- `EmptyBoardCell`
- `GameplayHintPanel`
- `GameplayControlButton`
- `arrowEscapeOffset`

`GradientArrowTile` owns entry, tap-compression, hint-pulse, escape, and blocked-move shake animations. It respects `MediaQuery.disableAnimations`.

#### `lib/features/arrowbox/arrowbox_dialogs.dart`

Visual overlays for:

- Pause
- Level complete
- Game over

The dialogs are mostly presentational and receive callbacks from `ArrowBoxScreen`.

#### `lib/core/widgets/arrowbox_widgets.dart`

Shared ArrowBox visual primitives:

- Logo and fallback vector logo painter
- Hero artwork wrapper and fallback
- Brand title
- Primary and secondary buttons
- Action cards
- Header icon buttons
- Press-scale interaction wrapper

#### `lib/core/theme/`

`app_colors.dart` contains dark/light design tokens, status colors, board colors, and directional gradients. `app_theme.dart` creates the light and dark Material 3 themes. `app_text_styles.dart` contains text style definitions, but some screens still use local `TextStyle` values.

## 4. Startup and screen routing

Normal startup is:

```text
main()
  -> AppStore.load()
  -> ArrowBoxApp
  -> WelcomeScreen
```

`ArrowBoxApp` reads `Uri.base.queryParameters['screen']` for web/demo entry points. Supported values:

| Query | Screen |
| --- | --- |
| `screen=levels` | Level selection |
| `screen=gameplay` | Gameplay using level 3 |
| `screen=pause` | Pause dialog preview |
| `screen=complete` | Completion dialog preview |
| `screen=gameover` | Game-over dialog preview |
| `screen=settings` | Settings |
| `screen=progress` | Progress |
| `screen=howtoplay` | Tutorial |
| `screen=about` | About |

The dialog preview routes deliberately use no-op callbacks. They are visual/demo routes, not alternate gameplay flows.

Normal navigation uses `MaterialPageRoute` and direct `Navigator.push`, `pushReplacement`, `pop`, and `popUntil` calls. There is no named-route registry.

## 5. Gameplay model

### Board representation

- Board size is always 25 entries.
- Index mapping is row-major: `index = row * 5 + column`.
- Each entry is either `ArrowDirection` or `null`.
- Direction vectors are:
  - up: `(-1, 0)`
  - right: `(0, 1)`
  - down: `(1, 0)`
  - left: `(0, -1)`

### Valid move

`ArrowBoxState.canEscape(index)` walks from the selected cell in the arrow direction until it leaves the board. If it encounters any non-null cell, the move is blocked; otherwise it can escape.

`ArrowBoxState.move(index)` is the authoritative state transition:

- Invalid selection, empty cell, cleared game, or game-over game: unchanged state and invalid result.
- Blocked arrow: preserve board, decrement lives, increment mistakes and moves, preserve undo history.
- Escaping arrow: remove it, increment moves, append the previous board to history, preserve lives/mistakes.
- The result exposes `wasValid` and `reachedEndState`.

A blocked move is intentionally counted as a move and mistake. It does not create undo history.

### State fields

`ArrowBoxState` contains:

- `board`
- `level`
- `lives`
- `mistakes`
- `moves`
- `secondsElapsed`
- `hintsUsed`
- `history`

Instances are immutable from the caller’s perspective. Lists are copied and wrapped as unmodifiable lists.

### Undo

Undo restores the last valid-move board snapshot, removes that snapshot from history, and decrements moves. It does not undo mistakes, lives, elapsed time, or hints. If history is empty, it returns the same state.

### Restart

Restart creates a fresh `ArrowBoxState.initial(level: currentLevel)`. It resets board, lives, mistakes, moves, seconds, hints, and history.

The screen optionally asks for confirmation based on `store.confirmRestart`.

### Hints

`nextEscapeIndex` scans from index 0 and returns the first currently escapable arrow. `useHint()` increments `hintsUsed` only when a valid escape exists. The UI limits hints to three uses per level and highlights the selected arrow.

Hint text is based on direction and color names. Level 3’s initial hint is intentionally tested as:

```text
The blue arrow can escape upward.
```

### Timer

The gameplay screen starts a one-second periodic timer only after the first move, or immediately when resuming a saved state with elapsed time greater than zero. It stops while paused, cleared, or game over.

The timer is an in-memory periodic counter. It persists the current integer seconds when saving, but it does not calculate elapsed wall-clock time while the app is suspended.

### Completion and ratings

When the board is cleared, `AppStore.recordCompletion`:

- Marks the level complete.
- Unlocks the next level, unless already at level 500.
- Adds mistakes to total mistakes.
- Stores the best star rating only.

Ratings:

- 3 stars: zero mistakes and zero hints
- 2 stars: at most one mistake and at most one hint
- 1 star: all other completions

Level 500 has no next level. Do not implement wraparound to level 1.

## 6. Level catalog and generation

There are exactly 500 deterministic levels.

- Level 1 is hand-authored and introductory.
- Level 2 is generated with a fixed seed.
- Level 3 is hand-authored and matches the reference/widget tests.
- Levels 4–30 use deterministic generated boards preserved for compatibility.
- Levels 31–500 use deterministic generated boards with difficulty profiles and uniqueness checks.

`ArrowBoxLevel._generateAllLevels()` creates the static catalog when first accessed. The generation process constructs boards in a way that guarantees at least one escape sequence. Dense Hard and Ultra Hard boards fill all 25 cells; Medium boards may contain empty cells.

Difficulty assignment currently follows level ranges and modulo rules in `arrowbox_logic.dart`, not a user-configured difficulty system. Do not assume the difficulty distribution is a simple contiguous block.

The tests verify:

- Exactly 500 levels
- Unique layouts
- Determinism
- Solvability of every level
- Difficulty constraints
- Full occupancy for dense levels
- Level 500 boundary behavior

When changing generation logic, run the full logic test suite because static catalog generation can be computationally meaningful and many invariants are cross-level.

## 7. Persistence details

`AppStore.load()` reads `SharedPreferences` and validates values before exposing them.

Primary keys include:

```text
unlockedLevel
completedLevels
levelStars
gamesPlayed
totalMistakes
savedGame
savedGames
soundEnabled
musicEnabled
musicVolume
hapticsEnabled
hintsEnabled
confirmRestart
themeMode
```

Saved games are serialized JSON representations of `ArrowBoxState`. The current format includes level, board, lives, mistakes, moves, elapsed seconds, hints used, and valid-move history.

Saved games are stored per level in `savedGames`, while `savedGame` is maintained as a compatibility/convenience pointer to one resumable saved state. The store chooses the saved state with the greatest elapsed time for the top-level pointer; level-specific navigation uses `savedGames[level]`.

Writes are queued in order through `_writeQueue`. Preserve that behavior when adding persistence operations; changing it can reintroduce save/clear races.

`resetProgress()` clears progress and saved games but leaves settings intact. `resetSettings()` restores settings defaults but keeps progress.

## 8. Visual and interaction conventions

The visual design is a premium dark-first puzzle interface with a light-theme alternative.

Dark palette characteristics:

- Deep navy/near-black backgrounds
- Blue borders and primary accents
- Cyan secondary accents
- Bright light text
- Glows and restrained shadows

Light palette characteristics:

- Pale neutral background
- White cards
- Dark navy text
- Muted blue-gray borders and secondary text

Directional tile palettes:

- Up: cyan/electric blue
- Right: amber/orange
- Down: coral/pink/red
- Left: mint/emerald/teal

Responsive assumptions:

- Portrait layout
- Board target width between roughly 240 and 420 logical pixels
- Main tested mobile widths around 320, 375, and 412 logical pixels
- Gameplay uses a controlled 5-column layout rather than a wrapping grid
- Long content uses scrolling

Accessibility/interaction conventions already present:

- Tooltips on header controls
- `Semantics` labels for level tiles and difficulty
- Haptic feedback controlled by the store setting
- Reduced-motion support through `MediaQuery.disableAnimations`
- Disabled controls represented by muted colors and disabled callbacks

When adding interactive controls, provide a semantic label or tooltip where appropriate and ensure the control behaves correctly in both themes.

## 9. Settings and known intentional limitations

Implemented settings:

- Haptic feedback
- Show hints
- Confirm before restart
- Sound effects toggle
- Background music toggle
- Music volume
- System/light/dark theme
- Reset settings
- Reset progress

Important limitation: audio settings are persisted and rendered but no audio engine is connected. Do not describe them as functional playback unless implementing an audio system.

Other intentional limitations:

- No backend, login, analytics, cloud sync, or network API.
- Progress is local to the platform/browser storage.
- Timer does not account for wall-clock time during app suspension.
- App is portrait-only.
- Preview query routes are visual/demo entry points.
- Package name remains `locate`.
- Existing automated tests do not replace real-device checks for haptics, physical back behavior, animation appearance, screenshots, or every breakpoint.
- About/settings UI still contains hard-coded version strings that may not match `pubspec.yaml`; verify before changing product metadata.

## 10. Tests and validation

### Unit/model tests

`test/arrowbox_logic_test.dart` covers:

- Direction vectors and text
- Edge/corner escapes
- Blocked moves
- Lives and mistakes
- Game over
- Restart
- Undo
- Completion star preservation
- Saved-game serialization and per-level isolation
- High-number level persistence
- Queued save/clear ordering
- 500-level determinism, uniqueness, difficulty, occupancy, and solvability
- Level 3 initial hint
- Level 500 boundary behavior

### Widget tests

`test/widget_test.dart` covers rendering and key text for:

- Welcome screen
- Level selection
- Difficulty filtering
- Gameplay screen
- Settings
- Progress
- How to Play
- About
- Escape animation offset helper

Tests use `SharedPreferences.setMockInitialValues` and should remain deterministic.

Recommended commands from the repository root:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

For UI changes, also run the app on a browser or device and inspect the actual layout. The project has web preview routes that can speed up checking isolated screens. Use the host and port printed by Flutter rather than assuming a fixed port.

## 11. Safe change workflow for an AI assistant

1. Read this file and the relevant current source files.
2. Check `git status --short` before making changes.
3. Identify whether the target is active code or a deleted/stale legacy file.
4. For gameplay behavior, update `arrowbox_logic.dart` first and add/adjust model tests before changing UI.
5. For persistence behavior, update `app_store.dart` and add round-trip/ordering tests.
6. For UI behavior, follow the existing theme helpers and shared ArrowBox widgets.
7. Avoid introducing a new state-management package, routing framework, database, or service layer for a localized change.
8. Run targeted tests, then `flutter analyze`, then the complete test suite when feasible.
9. For frontend changes, run the app and manually exercise the affected flow at mobile portrait sizes.
10. Review the diff for accidental generated files or unrelated legacy-file changes.
11. Report any tests not run; do not claim device or visual validation without actually performing it.

## 12. Common mistakes to avoid

- Treating the old Offline Games Hub files as the current architecture.
- Recreating deleted legacy screens without checking the current product direction.
- Duplicating clear-path logic in widgets instead of using `ArrowBoxState.canEscape`.
- Mutating `ArrowBoxState.board` or history directly.
- Adding blocked moves to undo history.
- Letting invalid moves remove arrows.
- Forgetting that blocked moves consume a life and count as a move/mistake.
- Saving cleared or game-over states as resumable games.
- Replacing per-level saved games with a single global save.
- Bypassing the AppStore write queue.
- Making level generation nondeterministic or unsolvable.
- Allowing level 500 to create level 501 or wrap to level 1.
- Assuming settings named sound/music already produce audio.
- Breaking reduced-motion behavior in animated widgets.
- Using fixed-width layouts that fail on 320 logical pixel portrait screens.
- Running destructive Git cleanup because generated files look unfamiliar.

## 13. Historical/stale documentation notes

`README.md` is currently the most complete product-level description and broadly matches the active ArrowBox implementation. `docs/redesign-plan.md` and `docs/superpowers/plans/` contain planning context and may describe work in progress rather than final behavior.

`docs/ui-audit.md` describes the former Offline Games Hub architecture, including screens and files that are now deleted or replaced. Use it only to understand migration history. Do not use it as an inventory of currently active screens.

If documentation, tests, and code disagree:

1. For actual behavior, inspect current code.
2. For intended invariants, inspect tests.
3. Update documentation only when the user asks or when the documentation is part of the requested change.
4. Do not silently restore old architecture based on historical docs.

## 14. Practical starting points

Use these entry points depending on the task:

| Task | Start here |
| --- | --- |
| Fix arrow movement or solvability | `lib/features/arrowbox/arrowbox_logic.dart` |
| Fix timer, pause, animation sequencing, or navigation | `lib/features/arrowbox/arrowbox_screen.dart` |
| Fix tile rendering or board layout | `lib/features/arrowbox/arrowbox_board_widgets.dart` |
| Fix completion/pause/game-over UI | `lib/features/arrowbox/arrowbox_dialogs.dart` |
| Fix saved progress/settings | `lib/core/app_store.dart` |
| Fix colors/theme | `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart` |
| Fix shared branding/buttons | `lib/core/widgets/arrowbox_widgets.dart` |
| Fix landing/levels/settings/progress/tutorial/about | `lib/app.dart` |
| Add/adjust model coverage | `test/arrowbox_logic_test.dart` |
| Add/adjust screen coverage | `test/widget_test.dart` |
| Understand product behavior | `README.md` |

The safest default is to make the smallest change in the active ArrowBox files, preserve current persistence and gameplay invariants, add a focused test, and validate the full Flutter suite before declaring the work complete.
