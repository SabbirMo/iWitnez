import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/services/agora_service.dart';
import 'package:iwitnez/core/services/ringtone_service.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';
import 'package:iwitnez/feature/call/repository/call_repository.dart';

class CallSessionProvider extends ChangeNotifier {
  CallSessionProvider({required this.arguments, AgoraService? agoraService})
    : _agoraService = agoraService ?? AgoraService() {
    _status = arguments.direction == CallDirection.incoming
        ? CallStatus.ringing
        : CallStatus.dialing;
    _isSpeakerOn = arguments.callType == CallType.video;
    _isVideoEnabled = arguments.callType == CallType.video;
    _callId = arguments.callId;
    _agoraAppId = arguments.agoraAppId;
    _agoraChannelName = arguments.agoraChannelName;
    _agoraRtcToken = arguments.agoraRtcToken;

    _setupAgoraCallbacks();

    // Start playing ringtone (phone ringtone for incoming, dialing tone for outgoing)
    if (arguments.direction == CallDirection.incoming) {
      RingtoneService.instance.startIncomingRingtone();
    } else {
      RingtoneService.instance.startOutgoingRingtone();
      _startOutgoingCallFlow();
    }
  }

  final CallArguments arguments;
  final CallRepository _callRepo = CallRepository();
  final AgoraService _agoraService;

  AgoraService get agoraService => _agoraService;

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  String? _callId;
  String? _agoraAppId;
  String? _agoraChannelName;
  String? _agoraRtcToken;

  String? get callId => _callId;
  String? get agoraAppId => _agoraAppId;
  String? get agoraChannelName => _agoraChannelName;
  String? get agoraRtcToken => _agoraRtcToken;

  late CallStatus _status;
  bool _isMuted = false;
  late bool _isSpeakerOn;
  late bool _isVideoEnabled;
  bool _isFrontCamera = true;
  int _durationSeconds = 0;

  Timer? _durationTimer;
  Timer? _dialingPollingTimer;

  CallStatus get status => _status;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isFrontCamera => _isFrontCamera;
  int get durationSeconds => _durationSeconds;

  String get formattedDuration {
    final minutes = (_durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  void _setupAgoraCallbacks() {
    _agoraService.onJoinChannelSuccess = () {
      if (_isDisposed) return;
      debugPrint(
        '[CallSession] Joined channel, enabling speakerphone: $_isSpeakerOn',
      );
      _agoraService.setSpeakerphone(_isSpeakerOn);
    };

    _agoraService.onUserJoinedChannel = (remoteUid) {
      if (_isDisposed) return;
      debugPrint('[CallSession] Remote user joined channel: $remoteUid');
      _dialingPollingTimer?.cancel();
      // Stop ringing once connected
      RingtoneService.instance.stopRingtone();
      if (_status != CallStatus.ended) {
        _status = CallStatus.connected;
        _startDurationTimer();
        notifyListeners();
      }
    };

    _agoraService.onUserOfflineChannel = (remoteUid) {
      if (_isDisposed) return;
      debugPrint('[CallSession] Remote user left channel. Ending call.');
      RingtoneService.instance.stopRingtone();
      endCall();
    };

    _agoraService.onTokenWillExpire = () async {
      if (_isDisposed) return;
      if (_callId != null && _callId!.isNotEmpty) {
        final tokenData = await _callRepo.fetchToken(_callId!);
        if (_isDisposed) return;
        final newToken = tokenData?['agora_rtc_token']?.toString();
        if (newToken != null && newToken.isNotEmpty) {
          await _agoraService.renewToken(newToken);
        }
      }
    };
  }

  /// 1. Outgoing Call Flow (Screen 135)
  void _startOutgoingCallFlow() async {
    final isVideo = arguments.callType == CallType.video;
    final hasPerm = await _agoraService.checkAndRequestPermissions(isVideo);
    if (_isDisposed) return;

    if (!hasPerm) {
      debugPrint('[CallSession] Permissions denied for call');
      RingtoneService.instance.stopRingtone();
      _status = CallStatus.ended;
      notifyListeners();
      return;
    }

    // Immediately initialize camera preview so the front camera turns on right away (like WhatsApp!)
    final initialAppId = _agoraAppId ?? '57a5f1d2e0dc4d8e985065d9c86afb0f';
    if (isVideo) {
      await _agoraService.initialize(appId: initialAppId, isVideo: true);
      if (_isDisposed) return;
      notifyListeners();
    }

    final callTypeStr = isVideo ? 'video' : 'audio';
    final res = await _callRepo.initiateCall(
      callType: callTypeStr,
      receiverId: arguments.receiverId,
      contactName: arguments.contactName,
      contactPhone: arguments.contactPhone,
    );
    if (_isDisposed) return;

    if (res != null) {
      _callId = res.id;
      _agoraAppId = res.agoraAppId ?? initialAppId;
      _agoraChannelName = res.agoraChannelName;
      _agoraRtcToken = res.agoraRtcToken;

      // Start periodic status check while dialing so if remote user declines, we end call immediately
      _startDialingCheckTimer();

      if (_agoraChannelName != null && _agoraRtcToken != null) {
        if (_agoraService.engine == null) {
          await _agoraService.initialize(appId: _agoraAppId!, isVideo: isVideo);
          if (_isDisposed) return;
        }
        await _agoraService.joinChannel(
          channelName: _agoraChannelName!,
          token: _agoraRtcToken!,
          isVideo: isVideo,
        );
        if (_isDisposed) return;
      }
      notifyListeners();
    } else {
      debugPrint('[CallSession] Failed to initiate call on backend');
    }
  }

  /// 2. Incoming Call Accept (Screen 136)
  Future<void> acceptCall() async {
    RingtoneService.instance.stopRingtone();
    if (_isDisposed) return;

    final isVideo = arguments.callType == CallType.video;
    final hasPerm = await _agoraService.checkAndRequestPermissions(isVideo);
    if (_isDisposed) return;

    if (!hasPerm) {
      debugPrint('[CallSession] Permissions denied for incoming call');
      return;
    }

    const defaultAppId = '57a5f1d2e0dc4d8e985065d9c86afb0f';
    _agoraAppId ??= defaultAppId;

    if (_callId != null && _callId!.isNotEmpty) {
      final res = await _callRepo.respondCall(_callId!, action: 'accept');
      if (_isDisposed) return;
      if (res != null) {
        _agoraAppId = res.agoraAppId ?? _agoraAppId ?? defaultAppId;
        _agoraChannelName = res.agoraChannelName ?? _agoraChannelName;
        _agoraRtcToken = res.agoraRtcToken ?? _agoraRtcToken;
      }
    }

    // Fallback: If token was not returned in respondCall response, fetch it directly
    if ((_agoraRtcToken == null || _agoraRtcToken!.isEmpty) &&
        _callId != null &&
        _callId!.isNotEmpty) {
      debugPrint(
        '[CallSession] Token missing after accept, fetching from /token/',
      );
      final tokenData = await _callRepo.fetchToken(_callId!);
      if (_isDisposed) return;
      if (tokenData != null) {
        _agoraAppId =
            tokenData['agora_app_id']?.toString() ??
            _agoraAppId ??
            defaultAppId;
        _agoraChannelName ??= tokenData['agora_channel_name']?.toString();
        _agoraRtcToken = tokenData['agora_rtc_token']?.toString();
      }
    }

    if (_isDisposed) return;

    debugPrint(
      '[CallSession] Accept Connecting Agora with appId: $_agoraAppId, channel: $_agoraChannelName, hasToken: ${_agoraRtcToken != null}',
    );

    if (_agoraAppId != null &&
        _agoraChannelName != null &&
        _agoraRtcToken != null) {
      await _agoraService.initialize(appId: _agoraAppId!, isVideo: isVideo);
      if (_isDisposed) return;
      await _agoraService.joinChannel(
        channelName: _agoraChannelName!,
        token: _agoraRtcToken!,
        isVideo: isVideo,
      );
      if (_isDisposed) return;
    } else {
      debugPrint(
        '[CallSession] WARNING: Credentials missing to join Agora (appId: $_agoraAppId, channel: $_agoraChannelName, token: $_agoraRtcToken)',
      );
    }

    if (_isDisposed) return;
    _status = CallStatus.connected;
    _startDurationTimer();
    notifyListeners();
  }

  /// 3. Incoming Call Decline (Screen 136)
  Future<void> declineCall() async {
    RingtoneService.instance.stopRingtone();
    if (_callId != null && _callId!.isNotEmpty) {
      await _callRepo.respondCall(_callId!, action: 'decline');
    }
    endCall();
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed) {
        _durationTimer?.cancel();
        return;
      }
      _durationSeconds++;
      notifyListeners();
    });
  }

  void toggleMute() {
    if (_isDisposed) return;
    _isMuted = !_isMuted;
    _agoraService.toggleMuteAudio(_isMuted);
    notifyListeners();
  }

  void toggleSpeaker() {
    if (_isDisposed) return;
    _isSpeakerOn = !_isSpeakerOn;
    _agoraService.setSpeakerphone(_isSpeakerOn);
    notifyListeners();
  }

  void toggleVideo() {
    if (_isDisposed) return;
    _isVideoEnabled = !_isVideoEnabled;
    _agoraService.toggleMuteVideo(!_isVideoEnabled);
    notifyListeners();
  }

  void switchCamera() {
    if (_isDisposed) return;
    _isFrontCamera = !_isFrontCamera;
    _agoraService.switchCamera();
    notifyListeners();
  }

  void _startDialingCheckTimer() {
    _dialingPollingTimer?.cancel();
    int elapsedSeconds = 0;
    _dialingPollingTimer = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      elapsedSeconds += 2;
      // If no answer after 60 seconds, end call as missed
      if (elapsedSeconds >= 60) {
        debugPrint('[CallSession] Dialing timed out (no answer). Ending call.');
        timer.cancel();
        endCall();
        return;
      }

      // Check if recipient declined or ended call on backend
      if (_callId != null &&
          _callId!.isNotEmpty &&
          _status == CallStatus.dialing) {
        final data = await _callRepo.fetchToken(_callId!);
        if (_isDisposed) {
          timer.cancel();
          return;
        }
        if (data != null) {
          final callStatus = data['call_status']?.toString().toLowerCase();
          if (callStatus == 'ongoing' && _status == CallStatus.dialing) {
            debugPrint(
              '[CallSession] Remote user accepted the call on backend! Connecting caller locally.',
            );
            RingtoneService.instance.stopRingtone();
            _status = CallStatus.connected;
            _startDurationTimer();
            notifyListeners();
          } else if (callStatus == 'declined' ||
              callStatus == 'completed' ||
              callStatus == 'missed' ||
              callStatus == 'cancelled') {
            debugPrint(
              '[CallSession] Remote user declined/ended the call ($callStatus). Ending locally.',
            );
            timer.cancel();
            endCall();
          }
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// End Call (Red Button)
  void endCall() {
    if (_isDisposed) return;
    RingtoneService.instance.stopRingtone();
    _dialingPollingTimer?.cancel();
    _dialingPollingTimer = null;
    _durationTimer?.cancel();
    _durationTimer = null;

    if (_status == CallStatus.ended) return;
    _status = CallStatus.ended;

    if (_callId != null && _callId!.isNotEmpty) {
      _callRepo.endCall(_callId!, durationSeconds: _durationSeconds);
    }

    _agoraService.leaveAndCleanUp();
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    RingtoneService.instance.stopRingtone();
    _dialingPollingTimer?.cancel();
    _dialingPollingTimer = null;
    _durationTimer?.cancel();
    _durationTimer = null;
    _agoraService.onJoinChannelSuccess = null;
    _agoraService.onUserJoinedChannel = null;
    _agoraService.onUserOfflineChannel = null;
    _agoraService.onTokenWillExpire = null;
    _agoraService.leaveAndCleanUp();
    super.dispose();
  }
}
