import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/model/chat_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/provider/chat_provider.dart';
import 'package:iwitnez/router/app_route_names.dart';

class ChatController {
  ChatController();

  Future<void> openChat(
    BuildContext context,
    ConversationModel entry,
    ChatProvider provider,
  ) async {
    provider.markAsRead(entry);

    await context.push(
      AppRouteNames.chatDetailsScreen,
      extra: {
        'chatId': entry.id,
        'contactName': entry.name,
        'avatarUrl': entry.avatarUrl,
        'isOnline': entry.isOnline,
        'receiverId': entry.otherParticipant.id,
        'contactPhone': entry.otherParticipant.phoneNumber,
      },
    );

    // When returning from ChatDetailsScreen, refresh the conversations
    // so the latest message and timestamp are always in sync with backend
    if (context.mounted) {
      provider.fetchChats(showLoading: false);
    }
  }
}