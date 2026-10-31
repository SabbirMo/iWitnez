import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/controller/chat_details_controller.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/chat_message_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/provider/chat_details_provider.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/widget/chat_details_widget.dart';

class ChatDetailsScreen extends ConsumerStatefulWidget {
  const ChatDetailsScreen({
    super.key,
    required this.chatId,
    required this.contactName,
    required this.avatarUrl,
    this.isOnline = false,
    this.receiverId,
    this.contactPhone,
    this.contactId,
  });

  final String chatId;
  final String contactName;
  final String avatarUrl;
  final bool isOnline;
  final String? receiverId;
  final String? contactPhone;
  final String? contactId;

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen>
    with WidgetsBindingObserver {
  final ChatDetailsController _controller = ChatDetailsController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(chatDetailsProvider(widget.chatId).notifier).markAsRead();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom([bool animated = true]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final target = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(target);
        }
      }
    });
  }

  String _getResolvedReceiverId(ChatDetailsState? state) {
    if (widget.receiverId != null && widget.receiverId!.isNotEmpty) {
      return widget.receiverId!;
    }
    if (state != null) {
      for (final m in state.messages) {
        if (!m.isMe && m.senderId != null && m.senderId!.isNotEmpty) {
          return m.senderId!;
        }
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatDetailsProvider(widget.chatId));
    final notifier = ref.read(chatDetailsProvider(widget.chatId).notifier);
    final resolvedReceiverId = _getResolvedReceiverId(chatAsync.asData?.value);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E15) : const Color(0xFFF7F9FC),
      appBar: ChatDetailsAppBar(
        name: widget.contactName,
        avatarUrl: widget.avatarUrl,
        isOnline: widget.isOnline,
        onProfileTap: () => _controller.openProfileDetails(
          context,
          name: widget.contactName,
          avatarUrl: widget.avatarUrl,
          isOnline: widget.isOnline,
          receiverId: resolvedReceiverId,
          contactPhone: widget.contactPhone,
          contactId: widget.contactId,
        ),
        onVoiceCall: () => _controller.startVoiceCall(
          context,
          widget.contactName,
          widget.avatarUrl,
          resolvedReceiverId,
          widget.contactPhone,
        ),
        onVideoCall: () => _controller.startVideoCall(
          context,
          widget.contactName,
          widget.avatarUrl,
          resolvedReceiverId,
          widget.contactPhone,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Failed to load messages',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              data: (chatState) {
                final messages = chatState.messages;

                if (messages.length != _lastMessageCount) {
                  _lastMessageCount = messages.length;
                  _scrollToBottom();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: messages.length + 1, // +1 for date chip
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const DateSeparatorChip(label: 'Today');
                    }
                    final message = messages[index - 1];
                    final fallbackAvatar = (message.senderAvatarUrl != null &&
                            message.senderAvatarUrl!.isNotEmpty)
                        ? message.senderAvatarUrl!
                        : widget.avatarUrl;

                    return ChatMessageBubble(
                      message: message,
                      avatarUrl: message.isMe ? null : fallbackAvatar,
                      onLocationTap: message.type == MessageType.liveLocation
                          ? () => _controller.openLiveLocation(context, message)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          // "Sarah is typing..." indicator above the bottom input bar
          if (chatAsync.value?.isOtherUserTyping == true)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 20.w, bottom: 6.h, top: 2.h),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${chatAsync.value?.typingUserName ?? widget.contactName} is typing...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6C4DF6),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  const TypingIndicatorDots(),
                ],
              ),
            ),
          ChatInputBar(
            onSend: notifier.sendMessage,
            onTypingChanged: notifier.sendTyping,
            onAttachmentTap: () =>
                _controller.pickAttachment(context, notifier),
          ),
        ],
      ),
    );
  }
}

