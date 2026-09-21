import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';

class CallSessionProvider extends ChangeNotifier {
  CallSessionProvider({required this.arguments}) {
    _status = arguments.direction == CallDirection.incoming
        ? CallStatus.ringing
        : CallStatus.dialing;
    _isSpeakerOn = arguments.callType == CallType.video;
    _isVideoEnabled = arguments.callType == CallType.video;

    if (arguments.direction == CallDirection.outgoing) {
      _startOutgoingCallFlow();
    }
  }

  final CallArguments arguments;

  late CallStatus _status;
  bool _isMuted = false;
  late bool _isSpeakerOn;
  late bool _isVideoEnabled;
  bool _isFrontCamera = true;
  int _durationSeconds = 0;

  Timer? _durationTimer;
  Timer? _statusTransitionTimer;

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

  void _startOutgoingCallFlow() {
    _statusTransitionTimer?.cancel();
    _statusTransitionTimer = Timer(const Duration(seconds: 2), () {
      if (_status != CallStatus.ended) {
        _status = CallStatus.connected;
        _startDurationTimer();
        notifyListeners();
      }
    });
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _durationSeconds++;
      notifyListeners();
    });
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    notifyListeners();
  }

  void toggleVideo() {
    _isVideoEnabled = !_isVideoEnabled;
    notifyListeners();
  }

  void switchCamera() {
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }

  void acceptCall() {
    _statusTransitionTimer?.cancel();
    _status = CallStatus.connected;
    _startDurationTimer();
    notifyListeners();
  }

  void endCall() {
    _statusTransitionTimer?.cancel();
    _durationTimer?.cancel();
    _status = CallStatus.ended;
    notifyListeners();
  }

  @override
  void dispose() {
    _statusTransitionTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}
