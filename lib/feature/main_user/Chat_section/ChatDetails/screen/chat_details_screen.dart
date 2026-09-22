import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/controller/chat_details_controller.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/chat_message_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/provider/chat_details_provider.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/widget/chat_details_widget.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({
    super.key,
    required this.chatId,
    required this.contactName,
    required this.avatarUrl,
    this.isOnline = false,
  });

  final String chatId;
  final String contactName;
  final String avatarUrl;
  final bool isOnline;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final ChatDetailsProvider _provider = ChatDetailsProvider();
  final ChatDetailsController _controller = ChatDetailsController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider.fetchMessages(widget.chatId);
  }

  @override
  void dispose() {
    _provider.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: ChatDetailsAppBar(
        name: widget.contactName,
        avatarUrl: widget.avatarUrl,
        isOnline: widget.isOnline,
        onVoiceCall: () =>
            _controller.startVoiceCall(context, widget.contactName, widget.avatarUrl),
        onVideoCall: () =>
            _controller.startVideoCall(context, widget.contactName, widget.avatarUrl),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _provider,
              builder: (context, _) {
                if (_provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = _provider.messages;
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: messages.length + 1, // +1 for date chip
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const DateSeparatorChip(label: 'Today');
                    }
                    final message = messages[index - 1];
                    return ChatMessageBubble(
                      message: message,
                      avatarUrl: message.isMe ? null : widget.avatarUrl,
                      onLocationTap: message.type == MessageType.liveLocation
                          ? () => _controller.openLiveLocation(context)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          ChatInputBar(
            onSend: _provider.sendMessage,
            onAttachmentTap: () => _controller.pickAttachment(context),
          ),
        ],
      ),
    );
  }
}