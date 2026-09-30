import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';
import 'package:iwitnez/router/app_route_names.dart';

class ChatDetailsController {
  ChatDetailsController();

  void openProfileDetails(
    BuildContext context, {
    required String name,
    required String avatarUrl,
    bool isOnline = true,
    String relationship = 'Sister',
    String trustedCircle = 'Family',
  }) {
    context.push(
      AppRouteNames.chatProfileDetailsScreen,
      extra: {
        'name': name,
        'contactName': name,
        'avatarUrl': avatarUrl,
        'isOnline': isOnline,
        'relationship': relationship,
        'trustedCircle': trustedCircle,
      },
    );
  }

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