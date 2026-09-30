import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/model/calls_model.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/widget/calls_widget.dart';
import 'package:iwitnez/router/app_route_names.dart';

class CallsController {
  CallsController();

  void showCallOptions(BuildContext context, CallLogEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => MessengerCallBottomSheet(
        entry: entry,
        onAudioCall: () {
          Navigator.pop(bottomSheetContext);
          startVoiceCall(context, entry);
        },
        onVideoCall: () {
          Navigator.pop(bottomSheetContext);
          startVideoCall(context, entry);
        },
        onMessage: () {
          Navigator.pop(bottomSheetContext);
          context.push(
            AppRouteNames.chatDetailsScreen,
            extra: {
              'chatId': entry.name,
              'contactName': entry.name,
              'avatarUrl': entry.avatarUrl,
              'isOnline': true,
            },
          );
        },
        onProfile: () {
          Navigator.pop(bottomSheetContext);
          context.push(
            AppRouteNames.chatProfileDetailsScreen,
            extra: {
              'name': entry.name,
              'avatarUrl': entry.avatarUrl,
              'isOnline': true,
            },
          );
        },
      ),
    );
  }

  void openCallDetail(BuildContext context, CallLogEntry entry) {
    showCallOptions(context, entry);
  }

  void startVoiceCall(BuildContext context, CallLogEntry entry) {
    CallFlowController.startAudioCall(
      context,
      name: entry.name,
      avatarUrl: entry.avatarUrl,
    );
  }

  void startVideoCall(BuildContext context, CallLogEntry entry) {
    CallFlowController.startVideoCall(
      context,
      name: entry.name,
      avatarUrl: entry.avatarUrl,
    );
  }

  void callBack(BuildContext context, CallLogEntry entry) {
    showCallOptions(context, entry);
  }
}
