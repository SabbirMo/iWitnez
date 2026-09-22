import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/chat_message_model.dart';

const Color _kAccentPurple = Color(0xFF6C4DF6);

/// Top app bar: back arrow, avatar, name + online status, call/video icons.
class ChatDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatDetailsAppBar({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
    this.onBack,
    this.onVoiceCall,
    this.onVideoCall,
  });

  final String name;
  final String avatarUrl;
  final bool isOnline;
  final VoidCallback? onBack;
  final VoidCallback? onVoiceCall;
  final VoidCallback? onVideoCall;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: _kAccentPurple,
                ),
              ),
              CircleAvatar(
                radius: 18.r,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: Colors.grey.shade200,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: CustomTextStyle.regular16(
                        AppColors.textDark,
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
                    ),
                    if (isOnline)
                      Text(
                        'Online',
                        style:
                            CustomTextStyle.regular14(
                              const Color(0xFF10B981),
                            ).copyWith(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onVoiceCall,
                icon: Icon(
                  Icons.call_rounded,
                  size: 20.sp,
                  color: _kAccentPurple,
                ),
              ),
              IconButton(
                onPressed: onVideoCall,
                icon: Icon(
                  Icons.videocam_rounded,
                  size: 22.sp,
                  color: _kAccentPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill chip used to separate messages by day, e.g. "Today".
class DateSeparatorChip extends StatelessWidget {
  const DateSeparatorChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: CustomTextStyle.regular14(
            const Color(0xFF6B7280),
          ).copyWith(fontSize: 12.sp),
        ),
      ),
    );
  }
}

/// A single chat bubble — text or live-location card, aligned by sender.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.avatarUrl,
    this.onLocationTap,
  });

  final ChatMessage message;
  final String? avatarUrl; // shown for incoming messages
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    final bubble = message.type == MessageType.liveLocation
        ? _LiveLocationCard(message: message, onTap: onLocationTap)
        : _TextBubble(message: message, isMe: isMe);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14.r,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              backgroundColor: Colors.grey.shade200,
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 240.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isMe ? _kAccentPurple : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isMe
                ? _kAccentPurple.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8.w,
        runSpacing: 4.h,
        children: [
          Text(
            message.text,
            style: CustomTextStyle.regular14(
              isMe ? Colors.white : AppColors.textDark,
            ).copyWith(fontSize: 13.5.sp),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                message.time,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.8)
                      : const Color(0xFF9CA3AF),
                ),
              ),
              if (isMe) ...[
                SizedBox(width: 3.w),
                Icon(
                  Icons.check_rounded,
                  size: 13.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveLocationCard extends StatelessWidget {
  const _LiveLocationCard({required this.message, this.onTap});

  final ChatMessage message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 230.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: _kAccentPurple,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _kAccentPurple.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.text,
                        style: CustomTextStyle.regular16(Colors.white).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        message.locationLabel ?? '',
                        style: CustomTextStyle.regular14(
                          Colors.white.withValues(alpha: 0.85),
                        ).copyWith(fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.time,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Icon(
                    Icons.check_rounded,
                    size: 13.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom input bar: attachment, text field, emoji, send button.
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSend, this.onAttachmentTap});

  final ValueChanged<String> onSend;
  final VoidCallback? onAttachmentTap;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F9FC),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              // Attachment button
              GestureDetector(
                onTap: widget.onAttachmentTap,
                child: Container(
                  width: 46.w,
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: const Color(0xFF9CA3AF),
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Message text field with emoji
              Expanded(
                child: Container(
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          cursorColor: _kAccentPurple,
                          style: CustomTextStyle.regular14(AppColors.textDark),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Type a message...',
                            hintStyle: CustomTextStyle.regular14(
                              const Color(0xFF9CA3AF),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          onSubmitted: (_) => _handleSend(),
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: Icon(
                          Icons.sentiment_satisfied_alt_outlined,
                          color: const Color(0xFF9CA3AF),
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Send button
              GestureDetector(
                onTap: _handleSend,
                child: Container(
                  width: 46.w,
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: _kAccentPurple,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: _kAccentPurple.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
