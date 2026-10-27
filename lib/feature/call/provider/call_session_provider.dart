import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';
import 'package:iwitnez/feature/call/repository/call_repository.dart';

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
  final CallRepository _callRepo = CallRepository();
  String? _callId;
  String? get callId => _callId;

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

  void _startOutgoingCallFlow() async {
    if (arguments.receiverId != null && arguments.receiverId!.isNotEmpty) {
      final callTypeStr =
          arguments.callType == CallType.video ? 'video' : 'audio';
      final res = await _callRepo.initiateCall(
        callType: callTypeStr,
        receiverId: arguments.receiverId!,
        contactName: arguments.contactName,
        contactPhone: arguments.contactPhone,
      );
      if (res != null) {
        _callId = res.id;
      }
    }

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

    if (_callId != null && _callId!.isNotEmpty) {
      _callRepo.endCall(_callId!);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _statusTransitionTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}
