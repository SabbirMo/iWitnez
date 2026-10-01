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
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
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
                errorBuilder: (context, error, stackTrace) => Icon(
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
      height: 182.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 1.w, color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          children: [
            // Left Panel — Live Location details & View Full Map button
            Container(
              width: 142.w,
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Pin icon + Live Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF8B2CF5),
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Live Location',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF111827),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),

                      // "Sharing is ON" pill badge
                      InkWell(
                        onTap: _handleToggle,
                        borderRadius: BorderRadius.circular(100.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: _isSharing
                                ? const Color(0xFFE8FDF0)
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
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFF9CA3AF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _isSharing ? 'Sharing is ON' : 'Sharing is OFF',
                                style: GoogleFonts.inter(
                                  color: _isSharing
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF6B7280),
                                  fontSize: 8.8.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Shield notice box
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: const Color(0xFFEDE4FE),
                            width: 0.8.w,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.buttonGradientStart,
                              size: 13.sp,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                'Your Location is being shared with trusted contacts',
                                style: GoogleFonts.inter(
                                  color: AppColors.buttonGradientStart,
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Address
                      Text(
                        '1200 Park Ave, New York, Ny 10028, USA',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF111827),
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),

                  // "View Full Map" Pill Button
                  InkWell(
                    onTap: widget.onViewFullMapTap,
                    borderRadius: BorderRadius.circular(100.r),
                    child: Container(
                      width: double.infinity,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: AppColors.buttonGradientStart,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Center(
                        child: Text(
                          'View Full Map',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Panel — Detailed Interactive Dummy Map
            Expanded(
              child: InkWell(
                onTap: widget.onViewFullMapTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  child: Stack(
                    children: [
                      // Vector-styled map matching Manhattan grid layout
                      Positioned.fill(
                        child: CustomPaint(
                          painter: const _DetailedMapPainter(),
                        ),
                      ),

                      // User Location (pulsing halo + vibrant blue dot)
                      Positioned(
                        left: 36.w,
                        bottom: 22.h,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final wave = _pulseAnimation.value;
                            return Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Outer pulse halo
                                Container(
                                  width: (34 + wave * 16).r,
                                  height: (34 + wave * 16).r,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: (1.0 - wave) * 0.35),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                // Static halo ring
                                Container(
                                  width: 30.r,
                                  height: 30.r,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF93C5FD,
                                    ).withValues(alpha: 0.45),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                // Center blue circle with white border
                                Container(
                                  width: 17.r,
                                  height: 17.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.2.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF007AFF,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 5,
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

                      // Avatar 1 (Woman - top left / middle)
                      Positioned(
                        left: 18.w,
                        top: 14.h,
                        child: _buildMapAvatar(
                          imageUrl:
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                          fallbackName: 'Sarah',
                          fallbackColor: const Color(0xFFFDA4AF),
                        ),
                      ),

                      // Avatar 2 (Young man - top right)
                      Positioned(
                        right: 36.w,
                        top: 12.h,
                        child: _buildMapAvatar(
                          imageUrl:
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                          fallbackName: 'Alex',
                          fallbackColor: const Color(0xFF60A5FA),
                        ),
                      ),

                      // Avatar 3 (Man with beard - middle right)
                      Positioned(
                        right: 12.w,
                        top: 60.h,
                        child: _buildMapAvatar(
                          imageUrl:
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
                          fallbackName: 'John',
                          fallbackColor: const Color(0xFFFB923C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapAvatar({
    required String imageUrl,
    required String fallbackName,
    required Color fallbackColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.2.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: fallbackColor,
                  child: Center(
                    child: Text(
                      fallbackName.isNotEmpty ? fallbackName[0] : '?',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 9.r,
            height: 9.r,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders a vector-styled Manhattan map matching the reference design:
/// angled avenues, cross-streets, green park patches, water feature, FDR Dr,
/// and street name labels.
class _DetailedMapPainter extends CustomPainter {
  const _DetailedMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base land background (light map grey)
    final basePaint = Paint()..color = const Color(0xFFF1F3F5);
    canvas.drawRect(Offset.zero & size, basePaint);

    // 2. Water at bottom right (East River)
    final waterPaint = Paint()..color = const Color(0xFF9FD3FB);
    final waterPath = Path()
      ..moveTo(size.width * 0.72, size.height)
      ..lineTo(size.width, size.height * 0.28)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Shoreline accent / FDR highway yellow edge line
    final fdrYellowPaint = Paint()
      ..color = const Color(0xFFFCD34D)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.72, size.height),
      Offset(size.width, size.height * 0.28),
      fdrYellowPaint,
    );

    // FDR Road border (white line)
    final fdrRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.70, size.height),
      Offset(size.width, size.height * 0.26),
      fdrRoadPaint,
    );

    // 3. Green park patches
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);

    // Park 1 (top-left edge)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-6, -4, size.width * 0.20, size.height * 0.35),
        const Radius.circular(6),
      ),
      parkPaint,
    );

    // Park 2 (mid right)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.46, size.height * 0.58, 22, 16),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    // Park 3 (bottom right near FDR)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, size.height * 0.74, 18, 14),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    // 4. Angled street grid lines in white
    final avenuePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.square;

    final crossStreetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.square;

    // Avenues (running from bottom-left to top-center/right)
    canvas.drawLine(
      Offset(-10, size.height * 0.50),
      Offset(size.width * 0.45, -10),
      avenuePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, size.height + 10),
      Offset(size.width * 0.75, -10),
      avenuePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.42, size.height + 10),
      Offset(size.width * 1.05, -10),
      avenuePaint,
    );

    // Cross streets (running perpendicular from top-left to bottom-right)
    canvas.drawLine(
      Offset(-10, size.height * 0.15),
      Offset(size.width * 0.85, size.height + 10),
      crossStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.08, -10),
      Offset(size.width * 0.95, size.height * 0.78),
      crossStreetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, -10),
      Offset(size.width * 1.10, size.height * 0.60),
      crossStreetPaint,
    );

    // 5. Street Labels rotated along roads
    _drawAngledText(
      canvas,
      'Madison Ave',
      Offset(size.width * 0.06, size.height * 0.36),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'E 86th St',
      Offset(size.width * 0.38, size.height * 0.16),
      0.70,
    );
    _drawAngledText(
      canvas,
      '1st Ave',
      Offset(size.width * 0.55, size.height * 0.38),
      -0.72,
    );
    _drawAngledText(
      canvas,
      'FDR Dr',
      Offset(size.width * 0.74, size.height * 0.78),
      -0.72,
    );
    _drawAngledText(canvas, 'nd St', Offset(-2, size.height * 0.82), 0.70);
  }

  void _drawAngledText(
    Canvas canvas,
    String text,
    Offset position,
    double radians,
  ) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(radians);

    final textSpan = TextSpan(
      text: text,
      style: GoogleFonts.inter(
        color: const Color(0xFF64748B),
        fontSize: 7.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );

    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset.zero);

    canvas.restore();
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
                    errorBuilder: (context, error, stackTrace) => Container(
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
