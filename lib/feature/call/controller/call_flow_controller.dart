import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';
import 'package:iwitnez/router/app_route_names.dart';

class CallFlowController {
  CallFlowController._();

  /// Global notifier triggered whenever a call ends (incoming or outgoing)
  static final ValueNotifier<int> callEndedNotifier = ValueNotifier<int>(0);

  static void notifyCallEnded() {
    callEndedNotifier.value++;
  }

  static Future<void> startAudioCall(
    BuildContext context, {
    required String name,
    required String avatarUrl,
    String? receiverId,
    String? contactPhone,
  }) async {
    await context.push(
      AppRouteNames.audioCallScreen,
      extra: CallArguments(
        contactName: name,
        avatarUrl: avatarUrl,
        callType: CallType.voice,
        direction: CallDirection.outgoing,
        receiverId: receiverId,
        contactPhone: contactPhone,
      ),
    );
    notifyCallEnded();
  }

  static Future<void> startVideoCall(
    BuildContext context, {
    required String name,
    required String avatarUrl,
    String? receiverId,
    String? contactPhone,
    bool isIncoming = false,
  }) async {
    await context.push(
      AppRouteNames.videoCallScreen,
      extra: CallArguments(
        contactName: name,
        avatarUrl: avatarUrl,
        callType: CallType.video,
        direction: isIncoming ? CallDirection.incoming : CallDirection.outgoing,
        receiverId: receiverId,
        contactPhone: contactPhone,
      ),
    );
    notifyCallEnded();
  }

  static void endCall(BuildContext context) {
    notifyCallEnded();
    if (context.canPop()) {
      context.pop();
    }
  }
}
