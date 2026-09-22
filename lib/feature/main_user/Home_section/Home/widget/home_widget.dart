import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/widgets/pulse_circle.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';

/// =====================================================================
/// SECTION HEADER — reused above "Quick Actions" and "Trusted Circles"
/// =====================================================================
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.15,
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.buttonGradientStart,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.buttonGradientStart,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// =====================================================================
/// HOME APP HEADER — avatar, greeting text, notification bell
/// =====================================================================
class HomeAppHeader extends StatelessWidget {
  const HomeAppHeader({
    super.key,
    required this.userName,
    required this.subtitle,
    required this.hasUnreadNotification,
    this.onNotificationTap,
  });

  final String userName;
  final String subtitle;
  final bool hasUnreadNotification;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 86.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 52.w,
              height: 52.h,
              decoration: const ShapeDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE4E6), Color(0xFFF5E8FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: OvalBorder(),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.buttonGradientStart,
                size: 32.sp,
              ),
            ),
          ),
          Positioned(
            left: 66.w,
            top: 10.h,
            child: Text(
              'Hi $userName',
              style: GoogleFonts.inter(
                color: AppColors.black,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                height: 0.75,
              ),
            ),
          ),
          Positioned(
            left: 66.w,
            top: 36.h,
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                color: AppColors.black,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 4.h,
            child: InkWell(
              onTap: onNotificationTap,
              borderRadius: BorderRadius.circular(20.r),
              child: SizedBox(
                width: 40.w,
                height: 40.h,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textDark,
                        size: 28.sp,
                      ),
                    ),
                    if (hasUnreadNotification)
                      Positioned(
                        right: 0.61.w,
                        top: 0,
                        child: Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF9023FF),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// PROTECTED BANNER — gradient "You are Protected" card
/// =====================================================================
class ProtectedBanner extends StatelessWidget {
  const ProtectedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: const LinearGradient(
          colors: [
            AppColors.homeProtectedBannerStart,
            AppColors.homeProtectedBannerMid,
            AppColors.homeProtectedBannerEnd,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background image (protected_card.png) — covers the whole card
          Positioned.fill(
            child: Image.asset(
              ImageAssets.protectedCard,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          // Left side — text content
          Positioned(
            left: 16.w,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are Protected',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFBFBFB),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.40,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'All System Are Active',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFE0D8FF),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                  ),
                ),
              ],
            ),
          ),
          // Right side — shield icon
          Positioned(
            right: 16.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                ImageAssets.protectedIcon,
                width: 56.w,
                height: 64.h,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shield_rounded,
                  size: 54.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================================
/// LIVE LOCATION CARD
/// =====================================================================
class LiveLocationCard extends StatelessWidget {
  const LiveLocationCard({super.key, this.onViewFullMapTap});

  final VoidCallback? onViewFullMapTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 356.w,
      height: 148.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  Container(
                    width: 110.24.w,
                    height: 148.h,
                    decoration: ShapeDecoration(
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.w,
                          color: AppColors.homeLocationCardBorder,
                        ),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE9F1FF), Color(0xFFC8E0FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CustomPaint(painter: _MapGridPainter()),
                          Positioned(
                            bottom: -1,
                            right: -1,
                            top: 60.h,
                            width: 60.w,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFFA9D8FF,
                                    ).withValues(alpha: 0.85),
                                    const Color(0xFF7FBFFF),
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(260.r),
                                ),
                              ),
                            ),
                          ),
                          _MapAvatarPin(left: 40.w, top: 22.h),
                          _MapAvatarPin(right: 18.w, top: 18.h),
                          _MapAvatarPin(right: 26.w, top: 70.h),
                          Positioned(
                            left: 28.w,
                            bottom: 20.h,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.h,
                                  decoration: const ShapeDecoration(
                                    color: AppColors.homeLocationMapHalo,
                                    shape: OvalBorder(),
                                  ),
                                ),
                                Container(
                                  width: 15.w,
                                  height: 15.h,
                                  decoration: ShapeDecoration(
                                    color: AppColors.homeLocationMapPin,
                                    shape: OvalBorder(
                                      side: BorderSide(
                                        width: 3.w,
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 10.w,
              top: 12.87.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 13.06.w,
                    height: 13.06.h,
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.buttonGradientStart,
                      size: 13.06.sp,
                    ),
                  ),
                  SizedBox(width: 3.73.w),
                  Text(
                    'Live location',
                    style: GoogleFonts.inter(
                      color: AppColors.black,
                      fontSize: 10.26.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.64,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 26.w,
              top: 28.h,
              child: Container(
                width: 51.w,
                height: 11.h,
                decoration: ShapeDecoration(
                  color: AppColors.homeLocationSharedPillBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 4.w,
                      top: 3.55.h,
                      child: Container(
                        width: 3.90.w,
                        height: 3.90.h,
                        decoration: ShapeDecoration(
                          color: AppColors.homeLocationSharedDot,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10.90.w,
                      top: 1.h,
                      child: Text(
                        'Sharing is ON',
                        style: GoogleFonts.inter(
                          color: AppColors.homeLocationSharedText,
                          fontSize: 5.36.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              top: 44.h,
              child: Container(
                width: 76.w,
                height: 22.h,
                decoration: ShapeDecoration(
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.20.w,
                      color: AppColors.homeLocationInfoCardStroke,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 4.w,
                      top: 5.5.h,
                      child: Icon(
                        Icons.shield_rounded,
                        color: AppColors.homeLocationInfoCardText,
                        size: 7.sp,
                      ),
                    ),
                    Positioned(
                      left: 14.w,
                      top: 5.h,
                      child: SizedBox(
                        width: 56.w,
                        child: Text(
                          'Your Location is being shared\nwith trusted contacts',
                          style: GoogleFonts.inter(
                            color: AppColors.homeLocationInfoCardText,
                            fontSize: 4.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.52,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              top: 77.h,
              child: Text(
                '1200 Park ave,\nnew york, ny 10028, USA',
                style: GoogleFonts.inter(
                  color: AppColors.black,
                  fontSize: 7.19.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              top: 116.h,
              child: InkWell(
                onTap: onViewFullMapTap,
                borderRadius: BorderRadius.circular(1000.r),
                child: Container(
                  width: 89.w,
                  height: 20.h,
                  decoration: ShapeDecoration(
                    color: AppColors.homeLocationViewFullMap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000.r),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'View Full Map',
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontSize: 6.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.02,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapAvatarPin extends StatelessWidget {
  const _MapAvatarPin({this.left, this.right, required this.top});

  final double? left;
  final double? right;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 24.w,
            height: 24.h,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFDA4AF), Color(0xFFC084FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: OvalBorder(
                side: BorderSide(
                  width: 3.w,
                  strokeAlign: BorderSide.strokeAlignOutside,
                  color: AppColors.white,
                ),
              ),
              shadows: const [
                BoxShadow(
                  color: AppColors.homeLocationAvatarShadow,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              color: Colors.white.withValues(alpha: 0.95),
              size: 14.sp,
            ),
          ),
          Positioned(
            right: -2.w,
            bottom: -2.h,
            child: Container(
              width: 7.w,
              height: 7.h,
              decoration: ShapeDecoration(
                color: AppColors.homeLocationOnline,
                shape: OvalBorder(
                  side: BorderSide(
                    width: 1.w,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    color: AppColors.white,
                  ),
                ),
                shadows: const [
                  BoxShadow(
                    color: AppColors.homeLocationAvatarShadow,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final blockPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    for (var i = 1; i < 6; i++) {
      final dy = size.height / 6 * i;
      canvas.drawLine(Offset(-6, dy), Offset(size.width + 6, dy), paint);
    }
    for (var i = 1; i < 5; i++) {
      final dx = size.width / 5 * i;
      canvas.drawLine(Offset(dx, -6), Offset(dx, size.height + 6), paint);
    }
    for (final rect in [
      Rect.fromLTWH(4, 16, 36, 22),
      Rect.fromLTWH(50, 48, 28, 20),
      Rect.fromLTWH(10, 80, 42, 20),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2.5)),
        blockPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// =====================================================================
/// QUICK ACTION CARD
/// =====================================================================
class QuickActionCard extends StatelessWidget {
  const QuickActionCard._({
    required this.type,
    required this.title,
    required this.circleColor,
    required this.iconColor,
    required this.circleHasShadow,
    this.onTap,
  });

  final QuickActionType type;
  final String title;
  final Color circleColor;
  final Color iconColor;
  final bool circleHasShadow;
  final VoidCallback? onTap;

  factory QuickActionCard.safety({VoidCallback? onTap}) => QuickActionCard._(
    type: QuickActionType.safety,
    title: 'Safety Tracking',
    circleColor: AppColors.homeQuickSafetyCircle,
    iconColor: AppColors.buttonGradientStart,
    circleHasShadow: false,
    onTap: onTap,
  );

  factory QuickActionCard.checkIn({VoidCallback? onTap}) => QuickActionCard._(
    type: QuickActionType.checkIn,
    title: 'Check in',
    circleColor: AppColors.homeQuickCheckInCircle,
    iconColor: AppColors.homeQuickCheckInBox,
    circleHasShadow: true,
    onTap: onTap,
  );

  factory QuickActionCard.scheduledTimer({VoidCallback? onTap}) =>
      QuickActionCard._(
        type: QuickActionType.scheduledTimer,
        title: 'Scheduled & timer',
        circleColor: AppColors.homeQuickScheduleCircle,
        iconColor: AppColors.homeScheduleIcon,
        circleHasShadow: true,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 109.w,
      height: 90.h,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.50.w, color: AppColors.homeQuickCardBorder),
          borderRadius: BorderRadius.circular(10.r),
        ),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashFactory: InkRipple.splashFactory,
          splashColor: circleColor.withValues(alpha: 0.3),
          child: Container(
            decoration: ShapeDecoration(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.50.w,
                  color: AppColors.homeQuickCardBorder,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              shadows: const [
                BoxShadow(
                  color: AppColors.homeQuickCardShadow,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 30.w,
                  top: 13.h,
                  child: Container(
                    width: 49.w,
                    height: 49.h,
                    decoration: ShapeDecoration(
                      color: circleColor,
                      shape: const OvalBorder(),
                      shadows: circleHasShadow
                          ? const [
                              BoxShadow(
                                color: AppColors.homeLocationAvatarShadow,
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ]
                          : const [],
                    ),
                    child: Center(child: _iconFor(type, iconColor)),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14.h,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.homeQuickLabel,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.20,
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

  Widget _iconFor(QuickActionType type, Color color) {
    switch (type) {
      case QuickActionType.safety:
        return Icon(Icons.shield_rounded, color: color, size: 26.sp);
      case QuickActionType.checkIn:
        return SizedBox(
          width: 26.w,
          height: 26.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 2.17.w,
                top: 2.17.h,
                child: Container(
                  width: 21.67.w,
                  height: 21.67.h,
                  decoration: ShapeDecoration(
                    color: AppColors.homeQuickCheckInBox,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.25.r),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 6.50.w,
                top: 6.50.h,
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 13.sp,
                ),
              ),
            ],
          ),
        );
      case QuickActionType.scheduledTimer:
        return Icon(Icons.schedule_rounded, color: color, size: 24.sp);
    }
  }
}

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

/// =====================================================================
/// ANIMATED SOS BUTTON  (pulse animation identical to splash screen)
/// =====================================================================
class AnimatedSosButton extends StatefulWidget {
  const AnimatedSosButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<AnimatedSosButton> createState() => _AnimatedSosButtonState();
}

class _AnimatedSosButtonState extends State<AnimatedSosButton>
    with SingleTickerProviderStateMixin {
  // Single controller — same 3 000 ms loop used by the splash screen.
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const imageSize = 124.21;
    // Pulse rings expand out to ~2× the image diameter, same ratio as splash.
    final pulseBase = imageSize.w;
    final pulseExpand = imageSize.w * 0.95;

    return RepaintBoundary(
      child: SizedBox(
        width: (imageSize * 2.1).w,
        height: (imageSize * 2.1).h,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ── Three staggered PulseCircles — identical to splash screen ──
            PulseCircle(
              animation: _pulseController,
              delay: 0.0,
              baseSize: pulseBase,
              expandSize: pulseExpand,
              color: AppColors.homeSosHaloStroke,
            ),
            PulseCircle(
              animation: _pulseController,
              delay: 0.33,
              baseSize: pulseBase,
              expandSize: pulseExpand,
              color: AppColors.homeSosHaloStroke,
            ),
            PulseCircle(
              animation: _pulseController,
              delay: 0.66,
              baseSize: pulseBase,
              expandSize: pulseExpand,
              color: AppColors.homeSosHaloStroke,
            ),

            // ── SOS image (tappable) ──
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                splashFactory: InkSparkle.splashFactory,
                splashColor: Colors.white.withValues(alpha: 0.18),
                highlightColor: Colors.transparent,
                borderRadius: BorderRadius.circular(9999.r),
                child: SizedBox(
                  width: imageSize.w,
                  height: imageSize.h,
                  child: Image.asset(
                    ImageAssets.sosAlert,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: imageSize.w,
                      height: imageSize.h,
                      decoration: ShapeDecoration(
                        gradient: SweepGradient(
                          colors: [
                            AppColors.homeSosStart,
                            AppColors.homeSosMid,
                            AppColors.homeSosEnd,
                            AppColors.homeSosMid,
                            AppColors.homeSosStart,
                          ],
                        ),
                        shape: const OvalBorder(),
                        shadows: [
                          BoxShadow(
                            color: AppColors.homeSosStart.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
