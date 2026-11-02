import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locate/core/app_store.dart';
import 'package:locate/core/services/audio_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> initAudio() async {
    SharedPreferences.setMockInitialValues({
      'soundEnabled': true,
      'musicEnabled': false,
      'musicVolume': 0.5,
    });
    final store = await AppStore.load();
    AudioManager.instance.initializeFromStore(
      soundEnabled: store.soundEnabled,
      musicEnabled: store.musicEnabled,
      musicVolume: store.musicVolume,
    );
  }

  testWidgets('AudioManager is a singleton', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    expect(AudioManager.instance, same(AudioManager.instance));
  });

  testWidgets('isInitialized is true after initializeFromStore', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    expect(AudioManager.instance.isInitialized, isTrue);
  });

  testWidgets('setSfxMuted toggles state', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    await AudioManager.instance.setSfxMuted(true);
    expect(AudioManager.instance.sfxMuted, isTrue);
    await AudioManager.instance.setSfxMuted(false);
    expect(AudioManager.instance.sfxMuted, isFalse);
  });

  testWidgets('setMusicEnabled toggles musicMuted', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    unawaited(AudioManager.instance.setMusicEnabled(false));
    expect(AudioManager.instance.musicMuted, isTrue);
    unawaited(AudioManager.instance.setMusicEnabled(true));
    expect(AudioManager.instance.musicMuted, isFalse);
    await tester.pump();
  });

  testWidgets('setMusicVolume clamps to 0..1', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    await AudioManager.instance.setMusicVolume(1.5);
    expect(AudioManager.instance.musicVolume, 1.0);
    await AudioManager.instance.setMusicVolume(-0.2);
    expect(AudioManager.instance.musicVolume, 0.0);
    await AudioManager.instance.setMusicVolume(0.3);
    expect(AudioManager.instance.musicVolume, 0.3);
  });

  testWidgets('play does not throw for any SoundEffect when muted', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    await AudioManager.instance.setSfxMuted(true);
    for (final effect in SoundEffect.values) {
      unawaited(AudioManager.instance.play(effect));
    }
    await tester.pump();
    await AudioManager.instance.setSfxMuted(false);
  });

  testWidgets('play does not throw for any SoundEffect when unmuted', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    await AudioManager.instance.setSfxMuted(false);
    for (final effect in SoundEffect.values) {
      unawaited(AudioManager.instance.play(effect));
    }
    await tester.pump();
  });

  testWidgets('rapid play calls do not crash', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    await AudioManager.instance.setSfxMuted(false);
    for (var i = 0; i < 100; i++) {
      unawaited(AudioManager.instance.play(SoundEffect.tap));
    }
    await tester.pump();
  });

  testWidgets('repeated initializeFromStore does not crash', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      AudioManager.instance.initializeFromStore(
        soundEnabled: true,
        musicEnabled: false,
        musicVolume: 0.5,
      );
    }
    expect(AudioManager.instance.isInitialized, isTrue);
  });

  testWidgets('pauseMusic and resumeMusic do not throw', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    unawaited(AudioManager.instance.pauseMusic());
    unawaited(AudioManager.instance.resumeMusic());
    await tester.pump();
  });

  testWidgets('stopMusic then startMusic does not throw', (tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await initAudio();
    unawaited(AudioManager.instance.stopMusic());
    unawaited(AudioManager.instance.startMusic());
    await tester.pump();
  });

  testWidgets('SoundEffect maps to non-empty filename for all values', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox.shrink());
    for (final e in SoundEffect.values) {
      expect(e.filename, isNotEmpty);
      expect(e.filename, endsWith('.wav'));
    }
  });
}
