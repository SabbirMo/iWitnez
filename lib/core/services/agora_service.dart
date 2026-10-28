import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _isJoined = false;

  RtcEngine? get engine => _engine;
  int? get remoteUid => _remoteUid;
  bool get isJoined => _isJoined;

  VoidCallback? onJoinChannelSuccess;
  Function(int remoteUid)? onUserJoinedChannel;
  Function(int remoteUid)? onUserOfflineChannel;
  Function()? onTokenWillExpire;

  /// Check & request runtime permissions for mic and camera
  Future<bool> checkAndRequestPermissions(bool isVideo) async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      debugPrint('[AgoraService] Microphone permission denied');
      return false;
    }

    if (isVideo) {
      final camStatus = await Permission.camera.request();
      if (!camStatus.isGranted) {
        debugPrint('[AgoraService] Camera permission denied');
        return false;
      }
    }
    return true;
  }

  /// Initialize Agora RTC Engine
  Future<void> initialize({
    required String appId,
    required bool isVideo,
  }) async {
    if (_engine != null) {
      await leaveAndCleanUp();
    }

    debugPrint('[AgoraService] Initializing Agora Engine with appId: $appId');
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint(
            '[AgoraService] Local user joined channel: ${connection.channelId}, uid: ${connection.localUid}',
          );
          _isJoined = true;
          onJoinChannelSuccess?.call();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint(
            '[AgoraService] Remote user joined: $remoteUid in channel: ${connection.channelId}',
          );
          _remoteUid = remoteUid;
          onUserJoinedChannel?.call(remoteUid);
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint(
                '[AgoraService] Remote user offline: $remoteUid, reason: $reason',
              );
              _remoteUid = null;
              onUserOfflineChannel?.call(remoteUid);
            },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
            '[AgoraService] Token will expire soon. Requesting renewal...',
          );
          onTokenWillExpire?.call();
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('[AgoraService] Agora Error: $err - $msg');
        },
      ),
    );

    try {
      await _engine!.enableAudio();
      await _engine!.enableLocalAudio(true);
      await _engine!.adjustRecordingSignalVolume(100);
      await _engine!.adjustPlaybackSignalVolume(100);

      if (isVideo) {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.disableVideo();
      }
    } catch (e) {
      debugPrint('[AgoraService] Error enabling audio/video: $e');
    }
  }

  /// Join Agora RTC Channel with dynamic token
  Future<void> joinChannel({
    required String channelName,
    required String token,
    int uid = 0,
    bool isVideo = false,
  }) async {
    if (_engine == null) {
      debugPrint('[AgoraService] Cannot join channel: Engine is null');
      return;
    }

    try {
      debugPrint(
        '[AgoraService] Joining channel: $channelName with token (uid: $uid, isVideo: $isVideo)',
      );
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishMicrophoneTrack: true,
          publishCameraTrack: isVideo,
          autoSubscribeAudio: true,
          autoSubscribeVideo: isVideo,
        ),
      );
    } catch (e) {
      debugPrint('[AgoraService] joinChannel error: $e');
    }
  }

  /// Renew token when expiring
  Future<void> renewToken(String newToken) async {
    try {
      if (_engine != null) {
        debugPrint('[AgoraService] Renewing Agora token');
        await _engine!.renewToken(newToken);
      }
    } catch (e) {
      debugPrint('[AgoraService] renewToken error: $e');
    }
  }

  Future<void> toggleMuteAudio(bool muted) async {
    try {
      await _engine?.muteLocalAudioStream(muted);
    } catch (e) {
      debugPrint('[AgoraService] muteLocalAudioStream error: $e');
    }
  }

  Future<void> toggleMuteVideo(bool muted) async {
    try {
      await _engine?.muteLocalVideoStream(muted);
    } catch (e) {
      debugPrint('[AgoraService] muteLocalVideoStream error: $e');
    }
  }

  Future<void> switchCamera() async {
    try {
      await _engine?.switchCamera();
    } catch (e) {
      debugPrint('[AgoraService] switchCamera error: $e');
    }
  }

  Future<void> setSpeakerphone(bool enabled) async {
    try {
      if (_engine != null) {
        await _engine!.setEnableSpeakerphone(enabled);
      }
    } catch (e) {
      debugPrint(
        '[AgoraService] setEnableSpeakerphone notice (safe fallback): $e',
      );
    }
  }

  /// Leave channel and release all engine resources
  Future<void> leaveAndCleanUp() async {
    debugPrint('[AgoraService] Cleaning up Agora Engine...');
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
      }
    } catch (e) {
      debugPrint('[AgoraService] Error cleaning up engine: $e');
    } finally {
      _engine = null;
      _remoteUid = null;
      _isJoined = false;
    }
  }
}
