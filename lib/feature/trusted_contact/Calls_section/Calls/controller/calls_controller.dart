import 'package:flutter/material.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';

class CallsController {
  CallsController();

  void startVoiceCall(BuildContext context, {required String name, required String avatarUrl}) {
    CallFlowController.startAudioCall(context, name: name, avatarUrl: avatarUrl);
  }

  void startVideoCall(BuildContext context, {required String name, required String avatarUrl}) {
    CallFlowController.startVideoCall(context, name: name, avatarUrl: avatarUrl);
  }
}
