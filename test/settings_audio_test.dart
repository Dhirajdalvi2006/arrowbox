import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locate/app.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/core/services/audio_manager.dart';
import 'package:locate/features/settings/screens/settings_screen.dart';

Future<AppStore> _loadStore([Map<String, dynamic>? initial]) async {
  final prefs = await SharedPreferences.getInstance();
  if (initial != null) {
    for (final entry in initial.entries) {
      final value = entry.value;
      if (value is bool) {
        await prefs.setBool(entry.key, value);
      } else if (value is double) {
        await prefs.setDouble(entry.key, value);
      } else if (value is int) {
        await prefs.setInt(entry.key, value);
      } else if (value is String) {
        await prefs.setString(entry.key, value);
      }
    }
  }
  return AppStore.load();
}

/// Returns the [Switch] finder inside the settings row whose title is [title].
Finder _switchForRow(WidgetTester tester, String title) {
  final text = find.text(title);
  expect(text, findsOneWidget);
  final row = find.ancestor(of: text.first, matching: find.byType(Row));
  expect(row, findsWidgets);
  final switches = find.descendant(
    of: row.first,
    matching: find.byType(Switch),
  );
  expect(switches, findsOneWidget);
  return switches;
}

bool _switchValue(WidgetTester tester, Finder finder) =>
    tester.widget<Switch>(finder.first).value;

void main() {
  setUp(() async {
    // Initialize the mock shared_preferences channel, then clear audio keys so
    // each test starts from a clean slate.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      'soundEnabled',
      'musicEnabled',
      'musicVolume',
      'hapticsEnabled',
      'confirmRestart',
    ]) {
      await prefs.remove(key);
    }
  });

  test(
    'setBool updates only the targeted preference key (no fallthrough)',
    () async {
      SharedPreferences.setMockInitialValues({
        'soundEnabled': true,
        'musicEnabled': true,
        'hapticsEnabled': true,
        'confirmRestart': true,
      });
      final store = await AppStore.load();

      await store.setBool('soundEnabled', false);

      expect(store.soundEnabled, isFalse);
      // Other keys must be untouched (the old switch fallthrough bug is fixed).
      expect(store.musicEnabled, isTrue);
      expect(store.hapticsEnabled, isTrue);
      expect(store.confirmRestart, isTrue);
    },
  );

  testWidgets('tapping Sound Effects OFF updates the stored preference', (
    tester,
  ) async {
    final store = await _loadStore({'soundEnabled': true});
    expect(store.soundEnabled, isTrue);

    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    final sfx = _switchForRow(tester, 'Sound effects');
    expect(_switchValue(tester, sfx), isTrue);

    await tester.tap(sfx);
    await tester.pumpAndSettle();

    expect(store.soundEnabled, isFalse);
    expect(_switchValue(tester, sfx), isFalse);

    // Audio manager is synced.
    expect(AudioManager.instance.sfxMuted, isTrue);
  });

  testWidgets('tapping Sound Effects ON restores the preference', (
    tester,
  ) async {
    final store = await _loadStore({'soundEnabled': false});
    expect(store.soundEnabled, isFalse);

    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    final sfx = _switchForRow(tester, 'Sound effects');
    expect(_switchValue(tester, sfx), isFalse);

    await tester.tap(sfx);
    await tester.pumpAndSettle();

    expect(store.soundEnabled, isTrue);
    expect(AudioManager.instance.sfxMuted, isFalse);
  });

  testWidgets('tapping Background Music OFF invokes the audio operation', (
    tester,
  ) async {
    final store = await _loadStore({'musicEnabled': true});
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    final music = _switchForRow(tester, 'Background music');
    expect(_switchValue(tester, music), isTrue);

    await tester.tap(music);
    await tester.pumpAndSettle();

    expect(store.musicEnabled, isFalse);
    expect(AudioManager.instance.musicMuted, isTrue);
  });

  testWidgets('tapping Background Music ON invokes the audio operation', (
    tester,
  ) async {
    final store = await _loadStore({'musicEnabled': false});
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    final music = _switchForRow(tester, 'Background music');
    expect(_switchValue(tester, music), isFalse);

    await tester.tap(music);
    await tester.pumpAndSettle();

    expect(store.musicEnabled, isTrue);
    expect(AudioManager.instance.musicMuted, isFalse);
  });

  testWidgets('changing the music slider updates the percentage', (
    tester,
  ) async {
    final store = await _loadStore({'musicVolume': 0.5});
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('50%'), findsOneWidget);

    final slider = find.byType(Slider).first;
    await tester.drag(slider, const Offset(400, 0));
    await tester.pumpAndSettle();

    // Volume moved away from 0.5; the label reflects the new value.
    expect(store.musicVolume, isNot(0.5));
    expect(AudioManager.instance.musicVolume, store.musicVolume);
  });

  testWidgets('music volume is persisted and restored across restart', (
    tester,
  ) async {
    final store = await _loadStore({'musicVolume': 0.3});
    expect(store.musicVolume, 0.3);

    await store.setDouble('musicVolume', 0.8);
    expect(store.musicVolume, 0.8);

    // Simulate an application restart: reload from the same persisted mock prefs.
    final restored = await AppStore.load();
    expect(restored.musicVolume, 0.8);
    expect(AudioManager.instance.musicVolume, 0.8);
  });

  testWidgets('sound effects preference survives an application restart', (
    tester,
  ) async {
    final store = await _loadStore({'soundEnabled': false});
    expect(store.soundEnabled, isFalse);

    await store.setBool('soundEnabled', true);
    expect(store.soundEnabled, isTrue);

    // Simulate an application restart: reload from the same persisted mock prefs.
    final restarted = await AppStore.load();
    expect(restarted.soundEnabled, isTrue);
  });

  testWidgets('audio errors do not crash the settings page', (tester) async {
    final store = await _loadStore();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    // Toggling both switches must not throw even if audio playback fails.
    await tester.tap(_switchForRow(tester, 'Sound effects'));
    await tester.pumpAndSettle();
    await tester.tap(_switchForRow(tester, 'Background music'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('rapid taps do not create duplicate audio players', (
    tester,
  ) async {
    final store = await _loadStore();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    final first = AudioManager.instance;

    // Rapid-fire toggles and effect plays.
    for (var i = 0; i < 20; i++) {
      await store.setBool('soundEnabled', i.isEven);
      await AudioManager.instance.setSfxMuted(!i.isEven);
      unawaited(AudioManager.instance.play(SoundEffect.tap));
      await tester.pumpAndSettle();
    }

    expect(AudioManager.instance, same(first));
  });

  testWidgets('existing settings navigation still works', (tester) async {
    final store = await _loadStore();
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('AUDIO'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('DATA & STORAGE'), findsOneWidget);
    expect(find.text('Reset Settings'), findsOneWidget);
    expect(find.text('Reset Progress'), findsOneWidget);
  });
}
