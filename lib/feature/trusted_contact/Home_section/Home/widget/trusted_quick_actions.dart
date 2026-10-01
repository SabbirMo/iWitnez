import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class TrustedQuickActions extends StatelessWidget {
  const TrustedQuickActions({
    super.key,
    this.onCheckInStatusTap,
    this.onJourneyEtaTap,
  });

  final VoidCallback? onCheckInStatusTap;
  final VoidCallback? onJourneyEtaTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D2939),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            // Check In Status
            Expanded(
              child: _buildActionCard(
                label: 'Check In Status',
                circleColor: const Color(0xFFE8FDF0),
                svgAsset: ImageAssets.quickCheckIn,
                fallbackIcon: Icons.check_box_rounded,
                fallbackColor: const Color(0xFF22C55E),
                onTap: onCheckInStatusTap,
              ),
            ),
            SizedBox(width: 14.w),

            // Journey & ETA
            Expanded(
              child: _buildActionCard(
                label: 'Journey & ETA',
                circleColor: const Color(0xFFEFF8FF),
                svgAsset: ImageAssets.quickTimer,
                fallbackIcon: Icons.calendar_today_rounded,
                fallbackColor: const Color(0xFF007AFF),
                onTap: onJourneyEtaTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String label,
    required Color circleColor,
    required String svgAsset,
    required IconData fallbackIcon,
    required Color fallbackColor,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 1.w, color: const Color(0xFFF2F4F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon circle with soft background
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      svgAsset,
                      width: 26.r,
                      height: 26.r,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(fallbackIcon, color: fallbackColor, size: 24.sp),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Label
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF344054),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
