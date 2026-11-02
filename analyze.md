# ArrowBox Project Analysis

## 1. Overview
- **Project**: `locate` package, product name ArrowBox – offline 5×5 arrow puzzle game.  
- **Platform**: Mobile (iOS/Android) portrait‑only, no backend, optional Firebase.  
- **Language**: Dart/Flutter.

## 2. Architecture
- `lib/main.dart`: entry, sets portrait orientation, creates `ArrowBoxStartup`.  
- `lib/startup.dart`: Firebase init (optional), loads `AppStore`, shows splash (`_StartupSplash`), transitions to `_ReadyApp`.  
- `lib/app.dart` (likely): `MaterialApp` with dark theme, navigation scaffold, routes.  
- `lib/core/`: `app_store.dart` (ChangeNotifier) holds progress, settings, theme, audio flags; `theme/` holds colors.  
- `lib/features/`: `arrowbox/` (game logic), `splash/` (splash widgets/animations), `arrow_designs/` (skins, themes), `games/` (saved‑game utils).  
- `lib/data/`: models, level seeds (not listed).  
- `lib/widgets/`: reusable UI (painters, buttons).  
- `test/`: unit/widget tests (logic & rendering).  
- `assets/`: images for logos, icons.  
- `pubspec.yaml`: deps – flutter, shared_preferences, firebase_core, firebase_auth, cloud_firestore, audioplayers, flutter_lints, flutter_test, flutter_launcher_icons.