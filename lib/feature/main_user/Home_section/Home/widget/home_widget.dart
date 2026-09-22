import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
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
                      child: SvgPicture.asset(ImageAssets.notificatioBell),
                    ),
                    if (hasUnreadNotification)
                      Positioned(
                        right: 18,
                        top: -8,
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
/// LIVE LOCATION / MAP CARD
/// =====================================================================
class LiveLocationCard extends StatefulWidget {
  const LiveLocationCard({
    super.key,
    this.onViewFullMapTap,
    this.onToggleSharing,
    this.isSharing = true,
    this.address = '1200 Park Ave,\nNew York, NY 10028, USA',
  });

  final VoidCallback? onViewFullMapTap;
  final VoidCallback? onToggleSharing;
  final bool isSharing;
  final String address;

  @override
  State<LiveLocationCard> createState() => _LiveLocationCardState();
}

class _LiveLocationCardState extends State<LiveLocationCard>
    with SingleTickerProviderStateMixin {
  late bool _isSharing;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _isSharing = widget.isSharing;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(covariant LiveLocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSharing != widget.isSharing) {
      _isSharing = widget.isSharing;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    setState(() {
      _isSharing = !_isSharing;
    });
    widget.onToggleSharing?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 154.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          width: 0.8.w,
          color: AppColors.homeLocationCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          children: [
            // Left Panel — Location Sharing status & info
            Container(
              width: 130.w,
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  right: BorderSide(
                    width: 0.8.w,
                    color: AppColors.homeLocationCardBorder,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live pill
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: _isSharing
                              ? AppColors.homeLocationSharedPillBg
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5.5.r,
                              height: 5.5.r,
                              decoration: BoxDecoration(
                                color: _isSharing
                                    ? AppColors.homeLocationSharedDot
                                    : const Color(0xFF9CA3AF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _isSharing ? 'Live' : 'Paused',
                              style: GoogleFonts.inter(
                                color: _isSharing
                                    ? AppColors.homeLocationSharedText
                                    : const Color(0xFF6B7280),
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: const Color(0xFF9CA3AF),
                        size: 15.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  Text(
                    'Location Sharing',
                    style: GoogleFonts.inter(
                      color: AppColors.black,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Shared with 3 contacts',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Small avatars stack
                  SizedBox(
                    height: 18.h,
                    child: Stack(
                      children: [
                        _avatarCircle(0, const Color(0xFFFDA4AF)),
                        _avatarCircle(12.w, const Color(0xFFFB923C)),
                        _avatarCircle(24.w, const Color(0xFF60A5FA)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Address snippet
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 10.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          widget.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF475569),
                            fontSize: 7.8.sp,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Action Button (Stop Sharing / Start Sharing)
                  InkWell(
                    onTap: _handleToggle,
                    borderRadius: BorderRadius.circular(6.r),
                    child: Container(
                      width: double.infinity,
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: _isSharing
                            ? AppColors.buttonGradientStart
                            : const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text(
                          _isSharing ? 'Stop Sharing' : 'Start Sharing',
                          style: GoogleFonts.inter(
                            color: AppColors.white,
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Panel — Interactive Map Preview
            Expanded(
              child: Stack(
                children: [
                  // Map background gradient
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE8F2FE), Color(0xFFD3E6FD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  // Map grid pattern
                  Positioned.fill(
                    child: CustomPaint(painter: _MapGridPainter()),
                  ),

                  // Street path simulation
                  Positioned.fill(
                    child: CustomPaint(painter: _MapRoadsPainter()),
                  ),

                  // Friend pin on map 1
                  Positioned(
                    left: 24.w,
                    top: 18.h,
                    child: const _MapPinBadge(
                      avatarColor: Color(0xFFFDA4AF),
                      name: 'Sarah',
                    ),
                  ),

                  // Friend pin on map 2
                  Positioned(
                    right: 20.w,
                    top: 36.h,
                    child: const _MapPinBadge(
                      avatarColor: Color(0xFF60A5FA),
                      name: 'Alex',
                    ),
                  ),

                  // User Current Location Pin (pulsing halo + pin)
                  Positioned(
                    left: 56.w,
                    bottom: 34.h,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final wave = _pulseAnimation.value;
                        return Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Halo wave
                            Container(
                              width: (26 + wave * 18).r,
                              height: (26 + wave * 18).r,
                              decoration: BoxDecoration(
                                color: AppColors.homeLocationMapHalo.withValues(
                                  alpha: (1.0 - wave) * 0.45,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Inner pin
                            Container(
                              width: 16.r,
                              height: 16.r,
                              decoration: BoxDecoration(
                                color: AppColors.homeLocationMapPin,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.homeLocationMapPin
                                        .withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Recenter button (top right)
                  Positioned(
                    right: 8.w,
                    top: 8.h,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onViewFullMapTap,
                        borderRadius: BorderRadius.circular(100.r),
                        child: Container(
                          width: 26.r,
                          height: 26.r,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.my_location_rounded,
                            color: AppColors.buttonGradientStart,
                            size: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // "View Full Map" Pill Button at bottom
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 8.h,
                    child: InkWell(
                      onTap: widget.onViewFullMapTap,
                      borderRadius: BorderRadius.circular(100.r),
                      child: Container(
                        height: 24.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100.r),
                          border: Border.all(
                            width: 0.8.w,
                            color: const Color(0xFFE2E8F0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_rounded,
                              color: AppColors.buttonGradientStart,
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'View Full Map',
                              style: GoogleFonts.inter(
                                color: AppColors.buttonGradientStart,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.buttonGradientStart,
                              size: 8.sp,
                            ),
                          ],
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
    );
  }

  Widget _avatarCircle(double left, Color color) {
    return Positioned(
      left: left,
      top: 0,
      child: Container(
        width: 17.r,
        height: 17.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.2.w),
        ),
        child: Center(
          child: Icon(Icons.person, color: Colors.white, size: 10.sp),
        ),
      ),
    );
  }
}

/// Map grid lines painter for streets & block simulation
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.0;

    final blockPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // Grid lines
    for (int i = 1; i < 5; i++) {
      final dy = size.height / 5 * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
    for (int i = 1; i < 6; i++) {
      final dx = size.width / 6 * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }

    // City blocks
    for (final rect in [
      Rect.fromLTWH(8, 12, 34, 20),
      Rect.fromLTWH(52, 28, 40, 24),
      Rect.fromLTWH(18, 56, 32, 22),
      Rect.fromLTWH(62, 70, 48, 20),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        blockPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Curved road path painter
class _MapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.4)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.35);
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.25,
      size.width * 0.7,
      size.height * 0.65,
    );
    path.lineTo(size.width, size.height * 0.75);

    canvas.drawPath(path, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Small avatar pin shown on map for friends
class _MapPinBadge extends StatelessWidget {
  final Color avatarColor;
  final String name;

  const _MapPinBadge({required this.avatarColor, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20.r,
          height: 20.r,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 3,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: Center(
            child: Icon(Icons.person, color: Colors.white, size: 11.sp),
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(4.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 2,
              ),
            ],
          ),
          child: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 6.8.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
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
    return Container(
      height: 108.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 0.8.w, color: AppColors.homeQuickCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: circleColor.withValues(alpha: 0.25),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    boxShadow: circleHasShadow
                        ? [
                            BoxShadow(
                              color: circleColor.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(child: _iconFor(type, iconColor)),
                ),
                SizedBox(height: 10.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.homeQuickLabel,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
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
        return Container(
          width: 23.r,
          height: 23.r,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: AppColors.white,
              size: 16.sp,
            ),
          ),
        );
      case QuickActionType.scheduledTimer:
        return Icon(
          Icons.access_time_rounded,
          color: const Color(0xFF389BF2),
          size: 26.sp,
        );
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

/// =====================================================================
/// FULL MAP BOTTOM SHEET — Interactive Full Map Preview
/// =====================================================================
class FullMapBottomSheet extends StatelessWidget {
  const FullMapBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FullMapBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.78.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          // Drag handle
          Center(
            child: Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Location Tracking',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'Sharing active · 3 contacts notified',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF64748B),
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Expanded Map Graphic
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Stack(
                  children: [
                    // Gradient map ground
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE8F2FE), Color(0xFFD5E8FD)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),

                    // Grid
                    Positioned.fill(
                      child: CustomPaint(painter: _MapGridPainter()),
                    ),

                    // Roads
                    Positioned.fill(
                      child: CustomPaint(painter: _MapRoadsPainter()),
                    ),

                    // Friend Pin 1: Sarah
                    Positioned(
                      left: 45.w,
                      top: 40.h,
                      child: const _MapPinBadge(
                        avatarColor: Color(0xFFFDA4AF),
                        name: 'Sarah (0.4 mi)',
                      ),
                    ),

                    // Friend Pin 2: Alex
                    Positioned(
                      right: 50.w,
                      top: 80.h,
                      child: const _MapPinBadge(
                        avatarColor: Color(0xFF60A5FA),
                        name: 'Alex (1.2 mi)',
                      ),
                    ),

                    // Friend Pin 3: David
                    Positioned(
                      left: 90.w,
                      bottom: 70.h,
                      child: const _MapPinBadge(
                        avatarColor: Color(0xFF34D399),
                        name: 'David (2.1 mi)',
                      ),
                    ),

                    // User Pin: Center
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.buttonGradientStart,
                              borderRadius: BorderRadius.circular(100.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              'You are here',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            width: 20.r,
                            height: 20.r,
                            decoration: BoxDecoration(
                              color: AppColors.homeLocationMapPin,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.homeLocationMapPin
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Floating GPS Tools
                    Positioned(
                      right: 12.w,
                      bottom: 12.h,
                      child: Column(
                        children: [
                          _mapToolButton(Icons.my_location_rounded),
                          SizedBox(height: 8.h),
                          _mapToolButton(Icons.layers_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // Address Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: AppColors.buttonGradientStart.withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.buttonGradientStart,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1200 Park Ave, New York',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'NY 10028, USA · 40.7769° N, 73.9582° W',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Share Link button
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 20.h),
            child: SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Live tracking link copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
                label: Text(
                  'Share Live Tracking Link',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonGradientStart,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _mapToolButton(IconData icon) {
    return Container(
      width: 32.r,
      height: 32.r,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF475569), size: 16.sp),
    );
  }
}
