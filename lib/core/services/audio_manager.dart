import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum SoundEffect {
  tap('arrow_tap.wav'),
  escape('arrow_escape.wav'),
  blocked('arrow_blocked.wav'),
  hint('hint.wav'),
  restart('restart.wav'),
  complete('level_complete.wav'),
  achievement('achievement.wav');

  final String filename;
  const SoundEffect(this.filename);
}

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  final AudioPlayer _player = AudioPlayer();
  bool _muted = false;

  bool get muted => _muted;

  Future<void> toggleMute() async {
    _muted = !_muted;
    if (_muted) await _player.stop();
  }

  Future<void> play(SoundEffect effect) async {
    if (_muted) return;
    try {
      await _player.play(AssetSource('audio/${effect.filename}'));
    } catch (e) {
      debugPrint('Error playing sound ${effect.filename}: $e');
    }
  }
}
