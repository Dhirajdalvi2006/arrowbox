import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/arrowbox/arrowbox_logic.dart';
import '../features/arrow_designs/arrow_designs.dart';
import 'services/auth_service.dart';
import 'services/cloud_sync_service.dart';

class AppStore extends ChangeNotifier {
  @visibleForTesting
  AppStore.forTesting(this._prefs)
    : unlockedLevel = _validLevel(_prefs.getInt('unlockedLevel')),
      completedLevels = _validCompletedLevels(
        _prefs.getStringList('completedLevels'),
      ),
      levelStars = _validLevelStars(_prefs.getStringList('levelStars')),
      gamesPlayed = _nonNegative(_prefs.getInt('gamesPlayed')),
      totalMistakes = _nonNegative(_prefs.getInt('totalMistakes')),
      soundEnabled = _prefs.getBool('soundEnabled') ?? true,
      musicEnabled = _prefs.getBool('musicEnabled') ?? true,
      musicVolume = _prefs.getDouble('musicVolume') ?? 0.7,
      hapticsEnabled = _prefs.getBool('hapticsEnabled') ?? true,
      hintsEnabled = _prefs.getBool('hintsEnabled') ?? true,
      confirmRestart = _prefs.getBool('confirmRestart') ?? true,
      themeMode = _validThemeMode(_prefs.getInt('themeMode')),
      arrowSkinId = _validSkinId(_prefs.getString('arrowSkinId')),
      boardThemeId = _validBoardThemeId(_prefs.getString('boardThemeId'));

  AppStore._(this._prefs)
    : unlockedLevel = _validLevel(_prefs.getInt('unlockedLevel')),
      completedLevels = _validCompletedLevels(
        _prefs.getStringList('completedLevels'),
      ),
      levelStars = _validLevelStars(_prefs.getStringList('levelStars')),
      gamesPlayed = _nonNegative(_prefs.getInt('gamesPlayed')),
      totalMistakes = _nonNegative(_prefs.getInt('totalMistakes')),
      soundEnabled = _prefs.getBool('soundEnabled') ?? true,
      musicEnabled = _prefs.getBool('musicEnabled') ?? true,
      musicVolume = _prefs.getDouble('musicVolume') ?? 0.7,
      hapticsEnabled = _prefs.getBool('hapticsEnabled') ?? true,
      hintsEnabled = _prefs.getBool('hintsEnabled') ?? true,
      confirmRestart = _prefs.getBool('confirmRestart') ?? true,
      themeMode = _validThemeMode(_prefs.getInt('themeMode')),
      arrowSkinId = _validSkinId(_prefs.getString('arrowSkinId')),
      boardThemeId = _validBoardThemeId(_prefs.getString('boardThemeId'));

  static int get totalLevels => ArrowBoxLevel.count;

  static int _validLevel(int? value) =>
      value != null && value >= 1 && value <= totalLevels ? value : 1;

  static int _nonNegative(int? value) =>
      value != null && value >= 0 ? value : 0;

  static Set<int> _validCompletedLevels(List<String>? values) => values == null
      ? {}
      : values
            .map(int.tryParse)
            .whereType<int>()
            .where((value) => value >= 1 && value <= totalLevels)
            .toSet();

  static Map<int, int> _validLevelStars(List<String>? values) {
    if (values == null) return {};
    final result = <int, int>{};
    for (final value in values) {
      final parts = value.split(':');
      if (parts.length != 2) continue;
      final level = int.tryParse(parts[0]);
      final stars = int.tryParse(parts[1]);
      if (level != null &&
          stars != null &&
          level >= 1 &&
          level <= totalLevels &&
          stars >= 1 &&
          stars <= 3) {
        result[level] = stars;
      }
    }
    return result;
  }

  static ThemeMode _validThemeMode(int? value) =>
      value != null && value >= 0 && value < ThemeMode.values.length
      ? ThemeMode.values[value]
      : ThemeMode.dark;

  static ArrowSkinId _validSkinId(String? value) =>
      ArrowSkinId.values.firstWhere(
        (skin) => skin.name == value,
        orElse: () => ArrowSkinId.classic,
      );

  static BoardThemeId _validBoardThemeId(String? value) =>
      BoardThemeId.values.firstWhere(
        (theme) => theme.name == value,
        orElse: () => BoardThemeId.midnight,
      );

  final SharedPreferences _prefs;
  Future<void> _writeQueue = Future<void>.value();
  StreamSubscription? _authSubscription;

  int unlockedLevel;
  Set<int> completedLevels;
  Map<int, int> levelStars;
  int gamesPlayed;
  int totalMistakes;
  bool soundEnabled;
  bool musicEnabled;
  double musicVolume;
  bool hapticsEnabled;
  bool hintsEnabled;
  bool confirmRestart;
  ThemeMode themeMode;
  ArrowSkinId arrowSkinId;
  BoardThemeId boardThemeId;
  ArrowBoxState? savedGame;
  final Map<int, ArrowBoxState> savedGames = {};

  bool get hasSavedGame =>
      savedGame != null && !savedGame!.isCleared && !savedGame!.isGameOver;

  bool get hasProgress => completedLevels.isNotEmpty || unlockedLevel > 1;

  bool get isAdmin {
    final user = AuthService.instance.currentUser;
    return user?.email?.trim().toLowerCase() == 'dalvi3473@gmail.com';
  }

  static Future<AppStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final store = AppStore._(prefs);
    final savedGames = prefs.getStringList('savedGames');
    if (savedGames != null) {
      for (final entry in savedGames) {
        try {
          final state = ArrowBoxState.fromJson(
            jsonDecode(entry) as Map<String, dynamic>,
          );
          if (!state.isCleared && !state.isGameOver) {
            store.savedGames[state.level] = state;
          }
        } catch (_) {
          continue;
        }
      }
    }

    if (savedGames == null) {
      final saved = prefs.getString('savedGame');
      if (saved != null) {
        try {
          final state = ArrowBoxState.fromJson(
            jsonDecode(saved) as Map<String, dynamic>,
          );
          if (!state.isCleared && !state.isGameOver) {
            store.savedGames[state.level] = state;
          }
        } catch (_) {
          await prefs.remove('savedGame');
        }
      }
    }

    store.savedGame = store._mostAdvancedSavedGame();
    store.initCloudSync();
    return store;
  }

  void initCloudSync() {
    try {
      _authSubscription?.cancel();
      _authSubscription = AuthService.instance.authStateChanges.listen((user) {
        notifyListeners();
        if (user != null) {
          CloudSyncService.instance.syncStore(this, user.uid);
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> saveGame(ArrowBoxState state) {
    return _enqueueWrite(() async {
      if (state.isCleared || state.isGameOver) {
        _removeSavedGame(level: state.level);
      } else {
        savedGames[state.level] = state;
        savedGame = _mostAdvancedSavedGame();
      }
      await _persistSavedGames();
      notifyListeners();
    });
  }

  Future<void> clearSavedGame({int? level}) {
    return _enqueueWrite(() async {
      if (level == null) {
        savedGames.clear();
        savedGame = null;
      } else {
        _removeSavedGame(level: level);
      }
      await _persistSavedGames();
      notifyListeners();
    });
  }

  ArrowBoxState? _mostAdvancedSavedGame() {
    if (savedGames.isEmpty) return null;
    return savedGames.values.reduce(
      (a, b) => a.secondsElapsed >= b.secondsElapsed ? a : b,
    );
  }

  void _removeSavedGame({required int level}) {
    savedGames.remove(level);
    savedGame = _mostAdvancedSavedGame();
  }

  Future<void> _enqueueWrite(Future<void> Function() operation) {
    final next = _writeQueue.then((_) => operation());
    _writeQueue = next.catchError((_) {});
    return next;
  }

  Future<void> _persistSavedGames() async {
    await _prefs.setStringList(
      'savedGames',
      savedGames.values.map((state) => jsonEncode(state.toJson())).toList(),
    );
    if (savedGame == null) {
      await _prefs.remove('savedGame');
    } else {
      await _prefs.setString('savedGame', jsonEncode(savedGame!.toJson()));
    }
  }

  Map<String, dynamic> toSyncJson() {
    return {
      'unlockedLevel': unlockedLevel,
      'completedLevels': completedLevels.toList()..sort(),
      'levelStars': levelStars.map((k, v) => MapEntry(k.toString(), v)),
      'gamesPlayed': gamesPlayed,
      'totalMistakes': totalMistakes,
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'musicVolume': musicVolume,
      'hapticsEnabled': hapticsEnabled,
      'hintsEnabled': hintsEnabled,
      'confirmRestart': confirmRestart,
      'themeMode': themeMode.index,
      'arrowSkinId': arrowSkinId.name,
      'boardThemeId': boardThemeId.name,
      'lastSyncedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> mergeFromCloud(Map<String, dynamic> cloud) {
    return _enqueueWrite(() async {
      final cloudUnlocked = cloud['unlockedLevel'] as int?;
      if (cloudUnlocked != null && cloudUnlocked > unlockedLevel) {
        unlockedLevel = _validLevel(cloudUnlocked);
      }

      final rawCompleted = cloud['completedLevels'];
      if (rawCompleted is List) {
        final parsed = rawCompleted
            .map((e) => e is int ? e : int.tryParse(e.toString()))
            .whereType<int>()
            .toSet();
        completedLevels = {...completedLevels, ...parsed};
      }

      final rawStars = cloud['levelStars'];
      if (rawStars is Map) {
        for (final entry in rawStars.entries) {
          final level = int.tryParse(entry.key.toString());
          final stars = entry.value is int
              ? entry.value as int
              : int.tryParse(entry.value.toString());
          if (level != null && stars != null) {
            final current = levelStars[level] ?? 0;
            if (stars > current) {
              levelStars[level] = stars;
            }
          }
        }
      }

      final cloudGames = cloud['gamesPlayed'] as int?;
      if (cloudGames != null && cloudGames > gamesPlayed) {
        gamesPlayed = cloudGames;
      }

      final cloudMistakes = cloud['totalMistakes'] as int?;
      if (cloudMistakes != null && cloudMistakes > totalMistakes) {
        totalMistakes = cloudMistakes;
      }

      // Sync preferences: Arrow skin, Board theme, ThemeMode, Audio, Controls
      final skinName = cloud['arrowSkinId'] as String?;
      if (skinName != null) {
        arrowSkinId = _validSkinId(skinName);
      }

      final themeName = cloud['boardThemeId'] as String?;
      if (themeName != null) {
        boardThemeId = _validBoardThemeId(themeName);
      }

      final modeIndex = cloud['themeMode'] as int?;
      if (modeIndex != null) {
        themeMode = _validThemeMode(modeIndex);
      }

      if (cloud['soundEnabled'] is bool) {
        soundEnabled = cloud['soundEnabled'] as bool;
      }
      if (cloud['musicEnabled'] is bool) {
        musicEnabled = cloud['musicEnabled'] as bool;
      }
      if (cloud['musicVolume'] is num) {
        musicVolume = (cloud['musicVolume'] as num).toDouble();
      }
      if (cloud['hapticsEnabled'] is bool) {
        hapticsEnabled = cloud['hapticsEnabled'] as bool;
      }
      if (cloud['hintsEnabled'] is bool) {
        hintsEnabled = cloud['hintsEnabled'] as bool;
      }
      if (cloud['confirmRestart'] is bool) {
        confirmRestart = cloud['confirmRestart'] as bool;
      }

      // Persist merged state to local storage
      await _persistAll();
      notifyListeners();
    });
  }

  Future<void> _persistAll() async {
    await _persistProgress();
    await _prefs.setInt('gamesPlayed', gamesPlayed);
    await _prefs.setInt('themeMode', themeMode.index);
    await _prefs.setString('arrowSkinId', arrowSkinId.name);
    await _prefs.setString('boardThemeId', boardThemeId.name);
    await _prefs.setBool('soundEnabled', soundEnabled);
    await _prefs.setBool('musicEnabled', musicEnabled);
    await _prefs.setDouble('musicVolume', musicVolume);
    await _prefs.setBool('hapticsEnabled', hapticsEnabled);
    await _prefs.setBool('hintsEnabled', hintsEnabled);
    await _prefs.setBool('confirmRestart', confirmRestart);
  }

  Future<void> recordCompletion(int level, int mistakes, {int hintsUsed = 0}) {
    return _enqueueWrite(() async {
      completedLevels = {...completedLevels, level};
      final stars = mistakes == 0 && hintsUsed == 0
          ? 3
          : mistakes <= 1 && hintsUsed <= 1
          ? 2
          : 1;
      final previousStars = levelStars[level] ?? 0;
      if (stars > previousStars) levelStars[level] = stars;
      if (level < totalLevels) {
        unlockedLevel = (unlockedLevel < level + 1) ? level + 1 : unlockedLevel;
      }
      totalMistakes += mistakes;
      await _persistProgress();
      CloudSyncService.instance.scheduleUpload(this);
      notifyListeners();
    });
  }

  Future<void> recordGameStarted() {
    return _enqueueWrite(() async {
      gamesPlayed++;
      await _prefs.setInt('gamesPlayed', gamesPlayed);
      CloudSyncService.instance.scheduleUpload(this);
      notifyListeners();
    });
  }

  Future<void> setThemeMode(ThemeMode value) {
    return _enqueueWrite(() async {
      themeMode = value;
      await _prefs.setInt('themeMode', value.index);
      CloudSyncService.instance.scheduleUpload(this);
      notifyListeners();
    });
  }

  Future<void> setArrowSkin(ArrowSkinId value) {
    return _enqueueWrite(() async {
      arrowSkinId = value;
      await _prefs.setString('arrowSkinId', value.name);
      CloudSyncService.instance.scheduleUpload(this);
      notifyListeners();
    });
  }

  Future<void> setBoardTheme(BoardThemeId value) {
    return _enqueueWrite(() async {
      boardThemeId = value;
      await _prefs.setString('boardThemeId', value.name);
      CloudSyncService.instance.scheduleUpload(this);
      notifyListeners();
    });
  }

  Future<void> setDouble(String key, double value) {
    return _enqueueWrite(() async {
      await _prefs.setDouble(key, value);
      if (key == 'musicVolume') {
        musicVolume = value;
      }
      CloudSyncService.instance.scheduleUpload(this);
      notifyListeners();
    });
  }

  Future<void> setBool(String key, bool value) {
    return _enqueueWrite(() async {
      await _prefs.setBool(key, value);
      switch (key) {
        case 'soundEnabled':
          soundEnabled = value;
        case 'musicEnabled':
          musicEnabled = value;
        case 'hapticsEnabled':
          hapticsEnabled = value;
        case 'hintsEnabled':
          hintsEnabled = value;
        case 'confirmRestart':
          confirmRestart = value;
      }
      CloudSyncService.instance.scheduleUpload(this);
      notifyListeners();
    });
  }

  Future<void> resetProgress() {
    return _enqueueWrite(() async {
      unlockedLevel = 1;
      completedLevels = {};
      gamesPlayed = 0;
      totalMistakes = 0;
      levelStars = {};
      savedGame = null;
      savedGames.clear();
      await _prefs.remove('unlockedLevel');
      await _prefs.remove('completedLevels');
      await _prefs.remove('gamesPlayed');
      await _prefs.remove('totalMistakes');
      await _prefs.remove('levelStars');
      await _prefs.remove('savedGame');
      await _prefs.remove('savedGames');
      CloudSyncService.instance.scheduleUpload(this);
      notifyListeners();
    });
  }

  Future<void> resetSettings() {
    return _enqueueWrite(() async {
      soundEnabled = true;
      musicEnabled = true;
      musicVolume = 0.7;
      hapticsEnabled = true;
      hintsEnabled = true;
      confirmRestart = true;
      themeMode = ThemeMode.dark;
      arrowSkinId = ArrowSkinId.classic;
      boardThemeId = BoardThemeId.midnight;
      for (final key in [
        'soundEnabled',
        'musicEnabled',
        'musicVolume',
        'hapticsEnabled',
        'hintsEnabled',
        'confirmRestart',
        'arrowSkinId',
        'boardThemeId',
      ]) {
        await _prefs.remove(key);
      }
      await _prefs.remove('themeMode');
      CloudSyncService.instance.scheduleUpload(this);
      notifyListeners();
    });
  }

  Future<void> _persistProgress() async {
    await _prefs.setInt('unlockedLevel', unlockedLevel);
    await _prefs.setStringList(
      'completedLevels',
      completedLevels.map((e) => e.toString()).toList(),
    );
    await _prefs.setStringList(
      'levelStars',
      levelStars.entries.map((entry) => '${entry.key}:${entry.value}').toList(),
    );
    await _prefs.setInt('totalMistakes', totalMistakes);
  }
}
