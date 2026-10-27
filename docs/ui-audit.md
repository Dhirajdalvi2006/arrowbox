# UI audit

## Active app structure

- `main.dart` starts `OfflineGamesApp`; `app.dart` supplies the global light/dark themes and opens `SplashScreen`, which replaces itself with `MainShell` after two seconds.
- `MainShell` owns the active four-tab `IndexedStack` (Home, Games, Favorites, Settings). Search, Categories, Recently Played and game details are pushed routes. `ArrowBoxScreen` and `TicTacToeScreen` are real gameplay routes.
- `allGames` contains 16 entries. Only ArrowBox and Tic-Tac-Toe have gameplay; the remaining 14 catalog entries are detail-page prototypes that show “coming soon.”
- Theme mode was held in a notifier and settings wrote a preference, but startup did not load it. Favorites and recently played were held only in memory; recent games were seeded with unplayed items.

## Screen findings

| Screen | Active implementation | Audit finding |
| --- | --- | --- |
| Home | `features/home/home_screen.dart` | Search and game/category routes work. The header's settings button was inert. Recent section reflected seeded data, not actual play. |
| All Games | `features/games/all_games_screen.dart` | Search and category filtering work; catalog cards route to details. |
| Categories | `features/categories/categories_screen.dart` | Category cards opened an unfiltered catalog with empty callbacks, disconnecting favorites and recent tracking. |
| Game Details | `features/game_details/game_details_screen.dart` | Only ArrowBox and Tic-Tac-Toe are playable; others explicitly show a coming-soon message. |
| Search | `features/search/search_screen.dart` | Title search works, but suggested/results routes used empty favorite callbacks. |
| Favorites | `features/favorites/favorites_screen.dart` | Empty state and removal work against in-memory favorites; data resets on process restart. |
| Recently Played | `features/recent/recent_screen.dart` | Screen exists but its home list was seeded rather than play history. |
| Settings | `features/settings/settings_screen.dart` | Theme choices and progress confirmation exist; sound, music and vibration had no gameplay effect; language choices had no localization. |
| ArrowBox | `features/arrowbox/arrowbox_screen.dart` | Previously a fixed, non-interactive board with inert controls; now supports clear-path moves, mistakes/lives, undo, restart and levels. |
| Tic-Tac-Toe | `features/games/tictactoe/tictactoe_screen.dart` | Alternating turns, win/draw detection, move lock after win and score tracking work; reset starts a fresh round. |

## Shared UI and verification baseline

- Shared UI is in `core/widgets` (game cards, thumbnails, buttons, filters, search and empty states); design tokens are in `core/theme`.
- The app uses `shared_preferences` and `google_fonts`; no custom asset directory was present. Existing artwork is largely emoji-based.
- Baseline `flutter pub get` succeeded and baseline `flutter test` passed. Baseline analysis reported one unused settings widget. No root `CLAUDE.md` or project `.claude` skills directory was found.
- Flutter reports Windows and browser targets plus two Android emulator profiles. No emulator was connected at audit time.
