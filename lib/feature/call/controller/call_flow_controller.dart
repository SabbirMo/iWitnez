import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/call/model/call_session_model.dart';
import 'package:iwitnez/router/app_route_names.dart';

class CallFlowController {
  CallFlowController._();

  static void startAudioCall(
    BuildContext context, {
    required String name,
    required String avatarUrl,
  }) {
    context.push(
      AppRouteNames.audioCallScreen,
      extra: CallArguments(
        contactName: name,
        avatarUrl: avatarUrl,
        callType: CallType.voice,
        direction: CallDirection.outgoing,
      ),
    );
  }

  static void startVideoCall(
    BuildContext context, {
    required String name,
    required String avatarUrl,
    bool isIncoming = false,
  }) {
    context.push(
      AppRouteNames.videoCallScreen,
      extra: CallArguments(
        contactName: name,
        avatarUrl: avatarUrl,
        callType: CallType.video,
        direction: isIncoming ? CallDirection.incoming : CallDirection.outgoing,
      ),
    );
  }

  static void endCall(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}
