import 'package:flutter/material.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/model/calls_model.dart';

/// Holds UI-triggered actions for the Calls screen, kept separate from
/// the provider so screen/widget code stays declarative.
class CallsController {
  CallsController();

  void openCallDetail(BuildContext context, CallLogEntry entry) {
    if (entry.type == CallType.video) {
      CallFlowController.startVideoCall(
        context,
        name: entry.name,
        avatarUrl: entry.avatarUrl,
        isIncoming: entry.direction == CallDirection.incoming,
      );
    } else {
      CallFlowController.startAudioCall(
        context,
        name: entry.name,
        avatarUrl: entry.avatarUrl,
      );
    }
  }

  void callBack(BuildContext context, CallLogEntry entry) {
    if (entry.type == CallType.video) {
      CallFlowController.startVideoCall(
        context,
        name: entry.name,
        avatarUrl: entry.avatarUrl,
      );
    } else {
      CallFlowController.startAudioCall(
        context,
        name: entry.name,
        avatarUrl: entry.avatarUrl,
      );
    }
  }
}