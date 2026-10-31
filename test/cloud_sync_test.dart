import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/features/arrow_designs/arrow_designs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('toSyncJson serializes all progress, arrow preferences, and theme preferences', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = AppStore.forTesting(prefs);

    await store.recordCompletion(1, 0); // 3 stars
    await store.recordCompletion(2, 2); // 1 star
    await store.setArrowSkin(ArrowSkinId.neon);
    await store.setBoardTheme(BoardThemeId.deepOcean);
    await store.setThemeMode(ThemeMode.light);

    final json = store.toSyncJson();

    expect(json['unlockedLevel'], 3);
    expect(json['completedLevels'], [1, 2]);
    expect(json['levelStars'], {'1': 3, '2': 1});
    expect(json['arrowSkinId'], 'neon');
    expect(json['boardThemeId'], 'deepOcean');
    expect(json['themeMode'], ThemeMode.light.index);
    expect(json['soundEnabled'], true);
    expect(json.containsKey('lastSyncedAt'), true);
  });

  test(
    'mergeFromCloud merges cloud progress and applies preferences',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final store = AppStore.forTesting(prefs);

      // Initial local state: level 1 completed
      await store.recordCompletion(1, 1); // 2 stars
      expect(store.unlockedLevel, 2);
      expect(store.arrowSkinId, ArrowSkinId.classic);

      // Simulated cloud data with higher progress and custom preferences
      final cloudData = {
        'unlockedLevel': 5,
        'completedLevels': [1, 2, 3, 4],
        'levelStars': {'1': 3, '2': 3, '3': 2, '4': 3},
        'gamesPlayed': 10,
        'totalMistakes': 2,
        'arrowSkinId': 'pastel',
        'boardThemeId': 'aurora',
        'themeMode': ThemeMode.dark.index,
        'soundEnabled': false,
        'musicVolume': 0.5,
      };

      await store.mergeFromCloud(cloudData);

      // Verify progress merged
      expect(store.unlockedLevel, 5);
      expect(store.completedLevels, {1, 2, 3, 4});
      expect(store.levelStars[1], 3); // Max of local(2) and cloud(3)
      expect(store.levelStars[3], 2);
      expect(store.gamesPlayed, 10);

      // Verify preferences merged
      expect(store.arrowSkinId, ArrowSkinId.pastel);
      expect(store.boardThemeId, BoardThemeId.aurora);
      expect(store.themeMode, ThemeMode.dark);
      expect(store.soundEnabled, false);
      expect(store.musicVolume, 0.5);

      // Verify persisted to local SharedPreferences
      expect(prefs.getInt('unlockedLevel'), 5);
      expect(prefs.getString('arrowSkinId'), 'pastel');
      expect(prefs.getString('boardThemeId'), 'aurora');
    },
  );
}
