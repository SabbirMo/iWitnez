import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/model/chat_model.dart';

/// Rounded pill search field, matches the "Search messages" design.
class ChatSearchField extends StatefulWidget {
  const ChatSearchField({super.key, this.onChanged, this.controller});

  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  @override
  State<ChatSearchField> createState() => _ChatSearchFieldState();
}

class _ChatSearchFieldState extends State<ChatSearchField> {
  late final TextEditingController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.25)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isDark
                ? AppColors.white.withValues(alpha: 0.6)
                : AppColors.textMuted,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: CustomTextStyle.regular14(
                isDark ? AppColors.white : AppColors.textDark,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search messages',
                hintStyle: CustomTextStyle.regular14(
                  isDark
                      ? AppColors.white.withValues(alpha: 0.4)
                      : AppColors.textMuted,
                ),
                errorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged?.call('');
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.6)
                        : AppColors.textMuted,
                    size: 18.sp,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One row of the conversation list:
/// Contact Avatar: item['other_participant']['avatar_url']
/// Contact Name: item['other_participant']['full_name']
/// Last Message Preview: item['last_message'] != null ? item['last_message']['text'] : ""
/// Timestamp: item['last_message']['formatted_time']
/// Unread Count Badge: purple circular badge if > 0, hidden if 0.
class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.entry, this.onTap});

  final ConversationModel entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasUnread = entry.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(isDark),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyle.regular16(
                      isDark ? AppColors.white : AppColors.textDark,
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.lastMessagePreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyle.regular14(
                      hasUnread
                          ? (isDark ? AppColors.white : AppColors.textDark)
                          : (isDark
                              ? AppColors.white.withValues(alpha: 0.6)
                              : AppColors.textMuted),
                    ).copyWith(
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (entry.formattedTime.isNotEmpty)
                  Text(
                    entry.formattedTime,
                    style: CustomTextStyle.regular14(
                      hasUnread
                          ? AppColors.buttonGradientStart
                          : (isDark
                              ? AppColors.white.withValues(alpha: 0.45)
                              : AppColors.textMuted),
                    ).copyWith(
                      fontSize: 12.sp,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                SizedBox(height: 6.h),
                if (hasUnread)
                  Container(
                    constraints: BoxConstraints(
                      minWidth: 20.r,
                      minHeight: 20.r,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.buttonGradientStart,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.unreadCount}',
                      style: CustomTextStyle.regular14(
                        Colors.white,
                      ).copyWith(fontSize: 11.sp, fontWeight: FontWeight.w700),
                    ),
                  )
                else
                  SizedBox(height: 20.r),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    final avatarUrl = entry.avatarUrl.trim();
    final cleanUrl = avatarUrl.startsWith('http://')
        ? avatarUrl.replaceFirst('http://', 'https://')
        : avatarUrl;

    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF1E2235) : Colors.grey.shade200,
      ),
      child: ClipOval(
        child: cleanUrl.startsWith('http')
            ? Image.network(
                cleanUrl,
                width: 52.r,
                height: 52.r,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _fallbackAvatar(isDark),
              )
            : _fallbackAvatar(isDark),
      ),
    );
  }

  Widget _fallbackAvatar(bool isDark) {
    final initial = entry.name.trim().isNotEmpty
        ? entry.name.trim()[0].toUpperCase()
        : '?';

    return Container(
      width: 52.r,
      height: 52.r,
      color: isDark ? const Color(0xFF281E48) : const Color(0xFFEDE9FE),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: isDark ? const Color(0xFFC084FC) : const Color(0xFF6D28D9),
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
