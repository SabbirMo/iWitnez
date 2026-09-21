import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/model/chat_model.dart';

/// Rounded pill search field, matches the "Search messages" design.
class ChatSearchField extends StatelessWidget {
  const ChatSearchField({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: CustomTextStyle.regular14(AppColors.textDark),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search messages',
                hintStyle: CustomTextStyle.regular14(AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of the chat list: avatar, name, last message, time, unread badge.
class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.entry,
    this.onTap,
  });

  final ChatEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnread = entry.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundImage: NetworkImage(entry.avatarUrl),
              backgroundColor: Colors.grey.shade200,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: CustomTextStyle.regular16(AppColors.textDark)
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyle.regular14(AppColors.textMuted),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.time,
                  style: CustomTextStyle.regular14(AppColors.textMuted)
                      .copyWith(fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                if (hasUnread)
                  Container(
                    width: 20.w,
                    height: 20.h,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.unreadCount}',
                      style: CustomTextStyle.regular14(Colors.white)
                          .copyWith(fontSize: 11.sp, fontWeight: FontWeight.w700),
                    ),
                  )
                else
                  SizedBox(height: 20.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}