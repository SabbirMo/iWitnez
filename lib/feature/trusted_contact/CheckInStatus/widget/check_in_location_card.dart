import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/router/app_route_names.dart';

class CheckInLocationCard extends StatefulWidget {
  final bool isLive;
  final String address;
  final String statusText;
  final String updateTimeText;

  const CheckInLocationCard({
    super.key,
    required this.isLive,
    required this.address,
    required this.statusText,
    required this.updateTimeText,
  });

  @override
  State<CheckInLocationCard> createState() => _CheckInLocationCardState();
}

class _CheckInLocationCardState extends State<CheckInLocationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFF5856D6),
                size: 19.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                'Current Location',
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: BoxDecoration(
                      color: widget.isLive
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF6B7280),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    widget.statusText,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.isLive
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Map with Radar animation
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              height: 135.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    ImageAssets.liveTrackingMap,
                    fit: BoxFit.cover,
                  ),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final wave = _pulseAnimation.value;
                      return Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Large outer ring
                            Container(
                              width: 100.r,
                              height: 100.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF8B5CF6)
                                      .withValues(alpha: 0.15),
                                  width: 1.2.w,
                                ),
                                color: const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.05),
                              ),
                            ),
                            // Mid ring
                            Container(
                              width: 68.r,
                              height: 68.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.22),
                                  width: 1.2.w,
                                ),
                                color: const Color(0xFF4F46E5)
                                    .withValues(alpha: 0.08),
                              ),
                            ),
                            // Pulse wave
                            Container(
                              width: (32 + wave * 30).r,
                              height: (32 + wave * 30).r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF4F46E5).withValues(
                                  alpha: (1.0 - wave) * 0.35,
                                ),
                              ),
                            ),
                            // Center pin dot
                            Container(
                              width: 18.r,
                              height: 18.r,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Bottom Address & View Full Map Button Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFF5856D6),
                size: 19.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.address,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.updateTimeText,
                      style: GoogleFonts.inter(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: () {
                  context.push(AppRouteNames.trustedLiveLocationScreen);
                },
                borderRadius: BorderRadius.circular(100.r),
                child: Container(
                  height: 28.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B2CF5),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Center(
                    child: Text(
                      'View Full Map',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
