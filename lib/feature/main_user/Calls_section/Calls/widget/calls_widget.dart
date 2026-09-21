import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/model/calls_model.dart';

class CallSearchField extends StatelessWidget {
  const CallSearchField({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
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
                hintText: 'Search calls',
                hintStyle: CustomTextStyle.regular14(AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CallLogTile extends StatelessWidget {
  const CallLogTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onCallBack,
  });

  final CallLogEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onCallBack;

  Color get _directionColor => switch (entry.direction) {
        CallDirection.incoming => Colors.green,
        CallDirection.outgoing => AppColors.textDark,
        CallDirection.missed => Colors.red,
      };

  IconData get _directionIcon => switch (entry.direction) {
        CallDirection.incoming => Icons.call_received_rounded,
        CallDirection.outgoing => Icons.call_made_rounded,
        CallDirection.missed => Icons.call_missed_rounded,
      };

  IconData get _typeIcon =>
      entry.type == CallType.video ? Icons.videocam_rounded : Icons.call_rounded;

  @override
  Widget build(BuildContext context) {
    final nameColor =
        entry.direction == CallDirection.missed ? Colors.red : AppColors.textDark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
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
                    style: CustomTextStyle.regular16(nameColor)
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(_directionIcon, size: 14.sp, color: _directionColor),
                      SizedBox(width: 4.w),
                      Text(
                        entry.callCount > 1
                            ? '${entry.time} (${entry.callCount})'
                            : entry.time,
                        style: CustomTextStyle.regular14(AppColors.textMuted)
                            .copyWith(fontSize: 12.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCallBack,
              icon: Icon(_typeIcon, color: AppColors.textDark, size: 20.sp),
            ),
          ],
        ),
      ),
    );
  }
}