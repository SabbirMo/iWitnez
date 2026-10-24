import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';

/// =====================================================================
/// TRUSTED CIRCLE CARD
/// =====================================================================
class TrustedCircleCard extends StatelessWidget {
  const TrustedCircleCard({
    super.key,
    required this.kind,
    required this.title,
    required this.memberCount,
    required this.memberColor,
    required this.badgeCircleBg,
    required this.badgeIcon,
    required this.badgeIconColor,
    this.avatars = const [],
    this.onTap,
  });

  final TrustedCircleKind kind;
  final String title;
  final int memberCount;
  final Color memberColor;
  final Color badgeCircleBg;
  final IconData badgeIcon;
  final Color badgeIconColor;
  final List<String>? avatars;
  final VoidCallback? onTap;

  factory TrustedCircleCard.family({
    VoidCallback? onTap,
    int memberCount = 0,
    List<String> avatars = const [],
  }) => TrustedCircleCard(
    kind: TrustedCircleKind.family,
    title: 'Family',
    memberCount: memberCount,
    memberColor: AppColors.homeTrustedMemberCountFamily,
    badgeCircleBg: AppColors.homeTrustedBadgeFamily,
    badgeIcon: Icons.group_add_rounded,
    badgeIconColor: AppColors.homeTrustedFamily,
    avatars: avatars,
    onTap: onTap,
  );

  factory TrustedCircleCard.friends({
    VoidCallback? onTap,
    int memberCount = 0,
    List<String> avatars = const [],
  }) => TrustedCircleCard(
    kind: TrustedCircleKind.friends,
    title: 'Friends',
    memberCount: memberCount,
    memberColor: AppColors.homeTrustedMemberCountFamily,
    badgeCircleBg: AppColors.homeTrustedBadgeFriends,
    badgeIcon: Icons.person_add_alt_rounded,
    badgeIconColor: AppColors.homeTrustedFriends,
    avatars: avatars,
    onTap: onTap,
  );

  factory TrustedCircleCard.partner({
    VoidCallback? onTap,
    int memberCount = 0,
    List<String> avatars = const [],
  }) => TrustedCircleCard(
    kind: TrustedCircleKind.partner,
    title: 'Partner',
    memberCount: memberCount,
    memberColor: AppColors.homeTrustedPartner,
    badgeCircleBg: AppColors.homeTrustedBadgePartner,
    badgeIcon: Icons.favorite_rounded,
    badgeIconColor: AppColors.homeTrustedPartner,
    avatars: avatars,
    onTap: onTap,
  );

  factory TrustedCircleCard.work({
    VoidCallback? onTap,
    int memberCount = 0,
    List<String> avatars = const [],
  }) => TrustedCircleCard(
    kind: TrustedCircleKind.work,
    title: 'Work',
    memberCount: memberCount,
    memberColor: AppColors.homeTrustedWork,
    badgeCircleBg: AppColors.homeTrustedBadgeWork,
    badgeIcon: Icons.work_history_rounded,
    badgeIconColor: AppColors.homeTrustedWork,
    avatars: avatars,
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context) {
    const avatarSize = 23.46;
    final safeAvatars = avatars ?? const [];
    final effectiveDisplayCount = safeAvatars.isNotEmpty
        ? safeAvatars.length.clamp(1, 3)
        : (memberCount == 0 ? 0 : memberCount.clamp(1, 3));

    return Container(
      width: 80.w,
      height: 72.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          width: 0.5.w,
          color: AppColors.homeTrustedCardBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.homeTrustedCardShadow,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: memberColor.withValues(alpha: 0.10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 6.w,
                top: 10.h,
                child: SizedBox(
                  width: avatarSize.w * 2.1,
                  height: avatarSize.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (effectiveDisplayCount == 0)
                        _emptyAvatarCircle()
                      else
                        for (int i = 0; i < effectiveDisplayCount; i++)
                          _avatarCircle(i * 12.0, i),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                width: 19.w,
                height: 19.h,
                child: Container(
                  decoration: BoxDecoration(
                    color: badgeCircleBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(badgeIcon, color: badgeIconColor, size: 10.sp),
                ),
              ),
              Positioned(
                left: 6.w,
                bottom: 16.h,
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.homeTrustedTitleColor,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              Positioned(
                left: 6.w,
                bottom: 4.5.h,
                child: Text(
                  memberCount == 1 ? '1 Member' : '$memberCount Members',
                  style: GoogleFonts.inter(
                    color: memberColor,
                    fontSize: 7.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarCircle(double left, int index) {
    final safeAvatars = avatars ?? const [];
    final avatarUrl = index < safeAvatars.length ? safeAvatars[index] : '';

    return Positioned(
      left: left.w,
      top: 0,
      width: 23.5.r,
      height: 23.5.r,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: index > 0
              ? Border.all(width: 1.w, color: AppColors.white)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(child: _buildAvatarImage(avatarUrl, index)),
      ),
    );
  }

  Widget _buildAvatarImage(String url, int index) {
    final cleanUrl = url.startsWith('http://')
        ? url.replaceFirst('http://', 'https://')
        : url;
    if (cleanUrl.startsWith('http')) {
      return Image.network(
        cleanUrl,
        width: 23.5.r,
        height: 23.5.r,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _fallbackGradientAvatar(index),
      );
    } else if (cleanUrl.isNotEmpty &&
        (cleanUrl.startsWith('/') || cleanUrl.startsWith('file:'))) {
      final file = File(cleanUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 23.5.r,
          height: 23.5.r,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _fallbackGradientAvatar(index),
        );
      }
    }
    return _fallbackGradientAvatar(index);
  }

  Widget _fallbackGradientAvatar(int index) {
    return Container(
      width: 23.5.r,
      height: 23.5.r,
      decoration: BoxDecoration(
        color: badgeCircleBg.withValues(alpha: 0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_rounded, color: badgeIconColor, size: 13.sp),
    );
  }

  Widget _emptyAvatarCircle() {
    return Container(
      width: 23.5.r,
      height: 23.5.r,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline_rounded,
        color: Color(0xFF94A3B8),
        size: 13.sp,
      ),
    );
  }
}
