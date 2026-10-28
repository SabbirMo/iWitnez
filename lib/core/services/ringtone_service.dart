import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RingtoneService {
  RingtoneService._();
  static final RingtoneService instance = RingtoneService._();

  static const MethodChannel _systemRingtoneChannel = MethodChannel(
    'com.iwitnez.lifetrace/system_ringtone',
  );

  AudioPlayer? _player;
  StreamSubscription? _playerCompleteSubscription;
  bool _isPlaying = false;
  bool _isNativeRingtonePlaying = false;

  bool get isPlaying => _isPlaying;

  /// Configure AudioPlayer so Agora's communication audio does not duck or kill the ringtone
  Future<void> _configureAudioContext() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.voiceCommunicationSignalling,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[RingtoneService] Error setting AudioContext: $e');
    }
  }

  /// 1. Incoming Call Ringtone:
  /// Plays the phone's actual system ringtone (selected in phone settings)
  /// or falls back to a pleasant melodic chime on iOS / emulators.
  Future<void> startIncomingRingtone() async {
    if (_isPlaying) return;
    _isPlaying = true;

    // Try playing phone's native system ringtone on Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final success = await _systemRingtoneChannel.invokeMethod<bool>(
          'playSystemRingtone',
        );
        if (success == true) {
          _isNativeRingtonePlaying = true;
          debugPrint('[RingtoneService] Phone system ringtone playing');
          return;
        }
      } catch (e) {
        debugPrint(
          '[RingtoneService] Native system ringtone error, falling back: $e',
        );
      }
    }

    // Fallback: Play melodious incoming ringtone
    try {
      await _configureAudioContext();
      _player ??= AudioPlayer();
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(1.0);

      _playerCompleteSubscription?.cancel();
      _playerCompleteSubscription = _player!.onPlayerComplete.listen((_) async {
        if (_isPlaying) {
          try {
            await _player?.seek(Duration.zero);
            await _player?.resume();
          } catch (_) {}
        }
      });

      await _player!.play(AssetSource('audio/incoming_ring.wav'));
      debugPrint('[RingtoneService] Melodic incoming ringtone started playing');
    } catch (e) {
      debugPrint('[RingtoneService] Error playing incoming ringtone asset: $e');
    }
  }

  /// 2. Outgoing Call Tone (Dialing / Calling sound):
  /// Plays the standard outgoing calling ringback tone ("tut... tut...") in a continuous loop
  Future<void> startOutgoingRingtone() async {
    if (_isPlaying) return;
    _isPlaying = true;

    try {
      await _configureAudioContext();
      _player ??= AudioPlayer();
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(1.0);

      // Explicit repeat listener ensures loop never stops after 1 iteration
      _playerCompleteSubscription?.cancel();
      _playerCompleteSubscription = _player!.onPlayerComplete.listen((_) async {
        if (_isPlaying) {
          try {
            await _player?.seek(Duration.zero);
            await _player?.resume();
          } catch (_) {}
        }
      });

      await _player!.play(AssetSource('audio/outgoing_ring.wav'));
      debugPrint(
        '[RingtoneService] Outgoing calling tone started playing in continuous loop',
      );
    } catch (e) {
      debugPrint('[RingtoneService] Error playing outgoing calling tone: $e');
    }
  }

  /// Legacy / default start: decides based on call direction
  Future<void> startRingtone({bool isIncoming = true}) async {
    if (isIncoming) {
      await startIncomingRingtone();
    } else {
      await startOutgoingRingtone();
    }
  }

  /// Stop all ringtones immediately (both system ringtone & audio player)
  Future<void> stopRingtone() async {
    if (!_isPlaying && _player == null && !_isNativeRingtonePlaying) return;
    _isPlaying = false;
    _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = null;

    // Stop native system ringtone
    if (_isNativeRingtonePlaying ||
        defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _systemRingtoneChannel.invokeMethod('stopSystemRingtone');
      } catch (_) {}
      _isNativeRingtonePlaying = false;
    }

    // Stop asset audio player
    try {
      await _player?.stop();
    } catch (e) {
      debugPrint('[RingtoneService] Error stopping audio player: $e');
    }
    debugPrint('[RingtoneService] All ringtones stopped');
  }

  Future<void> dispose() async {
    await stopRingtone();
    await _player?.dispose();
    _player = null;
  }
}
