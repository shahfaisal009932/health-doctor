import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Owns the incoming-call ringtone playback.
///
/// A registered singleton lives for the whole app lifetime, so the ringtone
/// keeps playing until [stopRingtone] is called (even while the incoming-call
/// screen is being swapped for the video call screen).
class CallNotificationService {
  final AudioPlayer _player = AudioPlayer();
  bool _ringing = false;

  /// Loop the ringtone asset until [stopRingtone] is called.
  Future<void> startRingtone() async {
    if (_ringing) return;
    _ringing = true;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(1.0);
      await _player.play(AssetSource('audio/ringtone.wav'));
    } catch (e) {
      debugPrint('CallNotificationService.startRingtone error: $e');
    }
  }

  Future<void> stopRingtone() async {
    if (!_ringing) return;
    _ringing = false;
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('CallNotificationService.stopRingtone error: $e');
    }
  }
}
