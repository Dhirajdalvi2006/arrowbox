import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum SoundEffect {
  tap('arrow_tap.wav'),
  escape('arrow_escape.wav'),
  blocked('arrow_blocked.wav'),
  hint('hint.wav'),
  restart('restart.wav'),
  complete('level_complete.wav'),
  achievement('achievement.wav'),
  gameOver('game_over.wav');

  final String filename;
  const SoundEffect(this.filename);
}

/// Centralized audio manager for ArrowBox.
///
/// Controls sound effects and background music playback, synchronized with
/// [AppStore] preferences. All playback errors are reported via
/// [debugPrint] (never swallowed silently) so the app keeps working on
/// platforms without audio support or when assets are missing.
class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final AudioPlayer _effectsPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  // Sound effects mute state (synced with AppStore.soundEnabled).
  bool _sfxMuted = false;
  bool get sfxMuted => _sfxMuted;

  // Background music mute state (synced with AppStore.musicEnabled).
  bool _musicMuted = false;
  bool get musicMuted => _musicMuted;

  // Background music volume (synced with AppStore.musicVolume, 0.0-1.0).
  double _musicVolume = 0.7;
  double get musicVolume => _musicVolume;

  bool get isPlayingMusic => _musicPlayer.state == PlayerState.playing;

  bool get isInitialized => _initialized;
  bool _initialized = false;

  /// Initialize audio state from [store] preferences. Call once at app start.
  void initializeFromStore({
    required bool soundEnabled,
    required bool musicEnabled,
    required double musicVolume,
  }) {
    _sfxMuted = !soundEnabled;
    _musicMuted = !musicEnabled;
    _musicVolume = musicVolume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
    _initialized = true;
    if (_musicMuted) {
      _musicPlayer.stop();
    } else {
      _resumeMusic();
    }
  }

  /// Update SFX muted state (called when sound effects toggle changes).
  Future<void> setSfxMuted(bool muted) async {
    _sfxMuted = muted;
  }

  /// Update music enabled state.
  Future<void> setMusicEnabled(bool enabled) async {
    _musicMuted = !enabled;
    if (_musicMuted) {
      await _musicPlayer.stop();
    } else {
      await _resumeMusic();
    }
  }

  /// Pause background music (e.g. when the app enters the background).
  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      debugPrint('Error pausing background music: $e');
    }
  }

  /// Resume background music (e.g. when the app returns to the foreground).
  Future<void> resumeMusic() async {
    if (_musicMuted) return;
    await _resumeMusic();
  }

  /// Update music volume (0.0 to 1.0). Does not restart playback.
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    try {
      await _musicPlayer.setVolume(_musicVolume);
      // Resume from a stopped state if music is enabled but not playing.
      if (!_musicMuted && _musicPlayer.state != PlayerState.playing) {
        await _resumeMusic();
      }
    } catch (e) {
      debugPrint('Error setting background music volume: $e');
    }
  }

  /// Start or resume background music playback.
  Future<void> startMusic() => _resumeMusic();

  /// Play a sound effect. Fails gracefully if muted or audio unavailable.
  Future<void> play(SoundEffect effect) async {
    if (_sfxMuted) return;
    try {
      await _effectsPlayer.play(AssetSource('audio/${effect.filename}'));
    } catch (e) {
      debugPrint('Error playing sound ${effect.filename}: $e');
    }
  }

  /// Start or resume background music playback without restarting when already
  /// playing (so volume changes do not interrupt the track).
  Future<void> _resumeMusic() async {
    if (_musicMuted) return;
    try {
      if (_musicPlayer.state != PlayerState.playing) {
        await _musicPlayer.play(AssetSource('audio/background_music.wav'));
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      }
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  /// Stop background music.
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  /// Release audio resources.
  Future<void> dispose() async {
    await _effectsPlayer.dispose();
    await _musicPlayer.dispose();
    _initialized = false;
  }
}
