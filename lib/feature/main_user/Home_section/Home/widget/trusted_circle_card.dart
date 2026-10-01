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
    this.onTap,
  });

  final TrustedCircleKind kind;
  final String title;
  final int memberCount;
  final Color memberColor;
  final Color badgeCircleBg;
  final IconData badgeIcon;
  final Color badgeIconColor;
  final VoidCallback? onTap;

  factory TrustedCircleCard.family({
    VoidCallback? onTap,
    int memberCount = 3,
  }) => TrustedCircleCard(
    kind: TrustedCircleKind.family,
    title: 'Family',
    memberCount: memberCount,
    memberColor: AppColors.homeTrustedMemberCountFamily,
    badgeCircleBg: AppColors.homeTrustedBadgeFamily,
    badgeIcon: Icons.group_add_rounded,
    badgeIconColor: AppColors.homeTrustedFamily,
    onTap: onTap,
  );

  factory TrustedCircleCard.friends({
    VoidCallback? onTap,
    int memberCount = 2,
  }) => TrustedCircleCard(
    kind: TrustedCircleKind.friends,
    title: 'Friends',
    memberCount: memberCount,
    memberColor: AppColors.homeTrustedMemberCountFamily,
    badgeCircleBg: AppColors.homeTrustedBadgeFriends,
    badgeIcon: Icons.person_add_alt_rounded,
    badgeIconColor: AppColors.homeTrustedFriends,
    onTap: onTap,
  );

  factory TrustedCircleCard.partner({
    VoidCallback? onTap,
    int memberCount = 1,
  }) => TrustedCircleCard(
    kind: TrustedCircleKind.partner,
    title: 'Partner',
    memberCount: memberCount,
    memberColor: AppColors.homeTrustedPartner,
    badgeCircleBg: AppColors.homeTrustedBadgePartner,
    badgeIcon: Icons.favorite_rounded,
    badgeIconColor: AppColors.homeTrustedPartner,
    onTap: onTap,
  );

  factory TrustedCircleCard.work({VoidCallback? onTap, int memberCount = 3}) =>
      TrustedCircleCard(
        kind: TrustedCircleKind.work,
        title: 'Work',
        memberCount: memberCount,
        memberColor: AppColors.homeTrustedWork,
        badgeCircleBg: AppColors.homeTrustedBadgeWork,
        badgeIcon: Icons.work_history_rounded,
        badgeIconColor: AppColors.homeTrustedWork,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    const w = 80.16;
    const h = 71.36;
    final badgeSize = switch (kind) {
      TrustedCircleKind.family => 19.60,
      TrustedCircleKind.friends => 18.86,
      TrustedCircleKind.partner => 19.10,
      TrustedCircleKind.work => 19.34,
    };
    const avatarSize = 23.46;

    return SizedBox(
      width: w.w,
      height: h.h,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.49.w,
            color: AppColors.homeTrustedCardBorder,
          ),
          borderRadius: BorderRadius.circular(9.78.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashFactory: InkRipple.splashFactory,
          splashColor: memberColor.withValues(alpha: 0.10),
          child: Container(
            decoration: ShapeDecoration(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.49.w,
                  color: AppColors.homeTrustedCardBorder,
                ),
                borderRadius: BorderRadius.circular(9.78.r),
              ),
              shadows: const [
                BoxShadow(
                  color: AppColors.homeTrustedCardShadow,
                  blurRadius: 2.93,
                  offset: Offset(0, 0.98),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 5.87.w,
                  top: 10.h,
                  child: SizedBox(
                    width: avatarSize.w * 2.1,
                    height: avatarSize.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _avatarCircle(0.0, 0),
                        _avatarCircle(avatarSize - 8, 1),
                        if (memberCount >= 3)
                          _avatarCircle((avatarSize - 8) * 2, 2),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: badgeSize.w,
                    height: badgeSize.h,
                    decoration: ShapeDecoration(
                      color: badgeCircleBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(badgeSize * 100.r),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        badgeIcon,
                        color: badgeIconColor,
                        size: 10.sp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 5.87.w,
                  bottom: 16.h,
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: AppColors.homeTrustedTitleColor,
                      fontSize: 8.82.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                    ),
                  ),
                ),
                Positioned(
                  left: 5.87.w,
                  bottom: 4.5.h,
                  child: Text(
                    '$memberCount Members',
                    style: GoogleFonts.inter(
                      color: memberColor,
                      fontSize: 6.62.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarCircle(double left, int index) {
    final gradients = switch (kind) {
      TrustedCircleKind.family => [
        [const Color(0xFF0EA5E9), const Color(0xFFF97316)],
        [const Color(0xFF38BDF8), const Color(0xFF4ADE80)],
        [const Color(0xFFC084FC), const Color(0xFFF0ABFC)],
      ],
      TrustedCircleKind.friends => [
        [const Color(0xFF22D3EE), const Color(0xFF7C3AED)],
        [const Color(0xFFFB923C), const Color(0xFFF59E0B)],
        [const Color(0xFFFDE68A), const Color(0xFF34D399)],
      ],
      TrustedCircleKind.partner => [
        [const Color(0xFFFBCFE8), const Color(0xFFF472B6)],
        [const Color(0xFFF87171), const Color(0xFFF43F5E)],
        [const Color(0xFFFDBA74), const Color(0xFF86EFAC)],
      ],
      TrustedCircleKind.work => [
        [const Color(0xFF60A5FA), const Color(0xFF34D399)],
        [const Color(0xFFF59E0B), const Color(0xFFF472B6)],
        [const Color(0xFFA78BFA), const Color(0xFF6EE7B7)],
      ],
    };
    final colors = gradients[index % gradients.length];
    final hasWhiteBorder = index > 0;

    return Positioned(
      left: left.w,
      top: 0,
      child: Container(
        width: 23.46.w,
        height: 23.46.h,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: OvalBorder(
            side: hasWhiteBorder
                ? BorderSide(width: 0.98.w, color: AppColors.white)
                : BorderSide.none,
          ),
        ),
        child: Icon(
          Icons.person_rounded,
          color: Colors.white.withValues(alpha: 0.95),
          size: 13.sp,
        ),
      ),
    );
  }
}
