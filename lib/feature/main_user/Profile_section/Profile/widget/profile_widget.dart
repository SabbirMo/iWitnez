import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/network/base_url/api_base_url.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/profile_model.dart';

const Color _kAccentPurple = Color(0xFF9023FF);

ImageProvider? _resolveAvatarImage(String url) {
  if (url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return NetworkImage(url);
  }
  final file = File(url);
  if (file.existsSync()) {
    return FileImage(file);
  }
  if (url.startsWith('/')) {
    return NetworkImage('${ApiBaseUrl.baseUrl}$url');
  }
  return NetworkImage(url);
}

/// Header card: avatar, name, phone, online status.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarImage = _resolveAvatarImage(profile.avatarUrl);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _kAccentPurple.withValues(alpha: isDark ? 0.6 : 0.4),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 32.r,
            backgroundImage: avatarImage,
            onBackgroundImageError: avatarImage != null ? (_, __) {} : null,
            backgroundColor:
                isDark ? const Color(0xFF1E2030) : Colors.grey.shade200,
            child: avatarImage == null
                ? Icon(
                    Icons.person,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    size: 28.sp,
                  )
                : null,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name.isNotEmpty ? profile.name : 'User',
                style: CustomTextStyle.regular16(
                  isDark ? Colors.white : AppColors.textDark,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 17.sp),
              ),
              if (profile.phone.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  profile.phone,
                  style: CustomTextStyle.regular14(
                    isDark ? const Color(0xFF98A2B3) : AppColors.textMuted,
                  ),
                ),
              ],
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
    this.trailing,
  });

  final ProfileMenuItem item;
  final VoidCallback? onTap;
  final bool showDivider;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = item.isDestructive
        ? Colors.red
        : (isDark ? const Color(0xFFA855F7) : _kAccentPurple);
    final iconBg = item.isDestructive
        ? Colors.red.withValues(alpha: isDark ? 0.16 : 0.08)
        : _kAccentPurple.withValues(alpha: isDark ? 0.2 : 0.08);
    final labelColor = item.isDestructive
        ? Colors.red
        : (isDark ? Colors.white : AppColors.textDark);

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
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark
                          ? const Color(0xFF98A2B3)
                          : AppColors.textMuted,
                      size: 20.sp,
                    ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 0.6,
              indent: 16.w,
              endIndent: 16.w,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
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
