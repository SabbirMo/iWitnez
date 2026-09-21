import 'package:flutter/material.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';

class ChatDetailsController {
  ChatDetailsController();

  void startVoiceCall(BuildContext context, String contactName, [String? avatarUrl]) {
    CallFlowController.startAudioCall(
      context,
      name: contactName,
      avatarUrl: avatarUrl ?? 'https://i.pravatar.cc/150?img=5',
    );
  }

  void startVideoCall(BuildContext context, String contactName, [String? avatarUrl]) {
    CallFlowController.startVideoCall(
      context,
      name: contactName,
      avatarUrl: avatarUrl ?? 'https://i.pravatar.cc/150?img=5',
    );
  }

  void openLiveLocation(BuildContext context) {
    // TODO: navigate to map view
    debugPrint('Open live location on map');
  }

  void pickAttachment(BuildContext context) {
    // TODO: open attachment picker
    debugPrint('Open attachment picker');
  }
}