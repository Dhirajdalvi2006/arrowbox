import 'dart:async';

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
///
/// Sound effects use a small, bounded pool of [AudioPlayer] instances so
/// that an ordinary interaction (tap) cannot cut off a critical event sound
/// (level complete / achievement / game over). Players are reused; no
/// unlimited player creation occurs.
class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  /// Bounded pool of effect players. Player 0 is reserved for critical
  /// events; the rest are shared round-robin for ordinary interactions.
  static const int _effectPoolSize = 3;
  final List<AudioPlayer> _effectsPlayers = List.generate(
    _effectPoolSize,
    (_) => AudioPlayer(),
  );
  int _nextOrdinaryPlayer = 1;

  final AudioPlayer _musicPlayer = AudioPlayer();

  // Sound effects mute state (synced with AppStore.soundEnabled).
  bool _sfxMuted = false;
  bool get sfxMuted => _sfxMuted;

  // Background music mute state (synced with AppStore.musicEnabled).
  // Off by default; the user opts in from Settings.
  bool _musicMuted = true;
  bool get musicMuted => _musicMuted;

  // Background music volume (synced with AppStore.musicVolume, 0.0-1.0).
  double _musicVolume = 0.7;
  double get musicVolume => _musicVolume;

  bool get isPlayingMusic => _musicPlayer.state == PlayerState.playing;

  bool get isInitialized => _initialized;
  bool _initialized = false;
  bool _disposed = false;

  /// Initialize audio state from [store] preferences. Safe to call repeatedly;
  /// does not create duplicate players or restart music that is already
  /// playing.
  void initializeFromStore({
    required bool soundEnabled,
    required bool musicEnabled,
    required double musicVolume,
  }) {
    if (_disposed) return;
    _sfxMuted = !soundEnabled;
    _musicMuted = !musicEnabled;
    _musicVolume = musicVolume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume).catchError((Object e) {
      debugPrint('Error setting background music volume: $e');
    });
    _initialized = true;
    if (_musicMuted) {
      _musicPlayer.stop().catchError((Object e) {
        debugPrint('Error stopping background music: $e');
      });
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
      unawaited(
        _musicPlayer.stop().catchError((Object e) {
          debugPrint('Error stopping background music: $e');
        }),
      );
    } else {
      unawaited(_resumeMusic());
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
  ///
  /// Resumes from the paused position instead of restarting playback.
  Future<void> resumeMusic() async {
    if (_musicMuted) return;
    final state = _musicPlayer.state;
    if (state == PlayerState.paused) {
      unawaited(
        _musicPlayer.resume().catchError((Object e) {
          debugPrint('Error resuming background music: $e');
        }),
      );
    } else if (state != PlayerState.playing) {
      unawaited(_resumeMusic());
    }
    unawaited(
      _musicPlayer.setVolume(_musicVolume).catchError((Object e) {
        debugPrint('Error setting background music volume: $e');
      }),
    );
  }

  /// Update music volume (0.0 to 1.0). Does not restart playback.
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    unawaited(
      _musicPlayer.setVolume(_musicVolume).catchError((Object e) {
        debugPrint('Error setting background music volume: $e');
      }),
    );
    // Resume from a stopped state if music is enabled but not playing.
    if (!_musicMuted && _musicPlayer.state != PlayerState.playing) {
      unawaited(_resumeMusic());
    }
  }

  /// Start or resume background music playback.
  Future<void> startMusic() => _resumeMusic();

  /// Play a sound effect. Fails gracefully if muted or audio unavailable.
  ///
  /// Critical events (level complete, achievement, game over) prefer a
  /// dedicated player so an ordinary tap cannot cut them off. Ordinary
  /// interactions round-robin across the remaining players.
  Future<void> play(SoundEffect effect) async {
    if (_sfxMuted || _disposed) return;
    final bool critical =
        effect == SoundEffect.complete ||
        effect == SoundEffect.achievement ||
        effect == SoundEffect.gameOver;

    final AudioPlayer player = _pickPlayer(critical);
    // Fire-and-forget playback so callers are never blocked (and the app
    // never hangs on platforms without an audio backend). audioplayers stops
    // the player's current source automatically when play() is called.
    unawaited(
      player.play(AssetSource('audio/${effect.filename}')).catchError((
        Object e,
      ) {
        debugPrint('Error playing sound ${effect.filename}: $e');
      }),
    );
  }

  AudioPlayer _pickPlayer(bool critical) {
    if (critical) {
      // Prefer player 0, but if it is busy fall back to the least recently
      // used ordinary player so the critical sound is not dropped.
      if (_effectsPlayers[0].state != PlayerState.playing) {
        return _effectsPlayers[0];
      }
    }
    // Ordinary (and fallback): prefer an idle player, else rotate.
    for (var i = 1; i < _effectPoolSize; i++) {
      if (_effectsPlayers[i].state != PlayerState.playing) {
        return _effectsPlayers[i];
      }
    }
    final player = _effectsPlayers[_nextOrdinaryPlayer];
    _nextOrdinaryPlayer++;
    if (_nextOrdinaryPlayer >= _effectPoolSize) _nextOrdinaryPlayer = 1;
    return player;
  }

  /// Start or resume background music playback without restarting when already
  /// playing (so volume changes do not interrupt the track).
  Future<void> _resumeMusic() async {
    if (_musicMuted || _disposed) return;
    try {
      if (_musicPlayer.state != PlayerState.playing) {
        unawaited(
          _musicPlayer.setReleaseMode(ReleaseMode.loop).catchError((Object e) {
            debugPrint('Error setting release mode: $e');
          }),
        );
        unawaited(
          _musicPlayer
              .play(AssetSource('audio/background_music.wav'))
              .catchError((Object e) {
                debugPrint('Error playing background music: $e');
              }),
        );
      }
      unawaited(
        _musicPlayer.setVolume(_musicVolume).catchError((Object e) {
          debugPrint('Error setting background music volume: $e');
        }),
      );
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  /// Stop background music.
  Future<void> stopMusic() async {
    unawaited(
      _musicPlayer.stop().catchError((Object e) {
        debugPrint('Error stopping background music: $e');
      }),
    );
  }

  /// Release audio resources.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    for (final player in _effectsPlayers) {
      await player.dispose();
    }
    await _musicPlayer.dispose();
    _initialized = false;
  }
}
