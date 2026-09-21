import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/profile_model.dart';

const Color _kAccentPurple = Color(0xFF9023FF);

/// Header card: avatar, name, phone, online status.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kAccentPurple.withOpacity(0.4), width: 2),
          ),
          child: CircleAvatar(
            radius: 32.r,
            backgroundImage: profile.avatarUrl.isNotEmpty
                ? NetworkImage(profile.avatarUrl)
                : null,
            backgroundColor: Colors.grey.shade200,
            child: profile.avatarUrl.isEmpty
                ? Icon(Icons.person, color: Colors.grey.shade400, size: 28.sp)
                : null,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: CustomTextStyle.regular16(AppColors.textDark)
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 17.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                profile.phone,
                style: CustomTextStyle.regular14(AppColors.textMuted),
              ),
              SizedBox(height: 6.h),
              if (profile.isOnline)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Online',
                      style: CustomTextStyle.regular14(Colors.green)
                          .copyWith(fontSize: 12.sp),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One row inside the grouped menu card (icon chip, label, chevron).
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.item,
    this.onTap,
    this.showDivider = true,
  });

  final ProfileMenuItem item;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final iconColor = item.isDestructive ? Colors.red : _kAccentPurple;
    final iconBg = item.isDestructive
        ? Colors.red.withOpacity(0.08)
        : _kAccentPurple.withOpacity(0.08);
    final labelColor = item.isDestructive ? Colors.red : AppColors.textDark;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(item.icon, color: iconColor, size: 18.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    item.label,
                    style: CustomTextStyle.regular16(labelColor)
                        .copyWith(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 20.sp),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 0.6,
              indent: 16.w,
              endIndent: 16.w,
              color: Colors.grey.shade200,
            ),
        ],
      ),
    );
  }
}

/// Rounded card wrapper that groups a set of ProfileMenuTiles together.
class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}