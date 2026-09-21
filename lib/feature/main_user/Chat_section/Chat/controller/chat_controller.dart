import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/model/chat_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/provider/chat_provider.dart';
import 'package:iwitnez/router/app_route_names.dart';

class ChatController {
  ChatController();

  void openChat(BuildContext context, ChatEntry entry, ChatProvider provider) {
    provider.markAsRead(entry);

    context.push(
      AppRouteNames.chatDetailsScreen,
      extra: {
        'chatId': entry.name,
        'contactName': entry.name,
        'avatarUrl': entry.avatarUrl,
        'isOnline': true,
      },
    );
  }
}