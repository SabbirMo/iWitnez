import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/model/home_model.dart';

class TrustedRecentActivitySection extends StatelessWidget {
  const TrustedRecentActivitySection({
    super.key,
    required this.activities,
    this.onViewAllTap,
    this.onItemTap,
  });

  final List<TrustedActivityItem> activities;
  final VoidCallback? onViewAllTap;
  final ValueChanged<TrustedActivityItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D2939),
              ),
            ),
            InkWell(
              onTap: onViewAllTap,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B2CF5),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18.sp,
                      color: const Color(0xFF8B2CF5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Activities Card Container
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              width: 1.w,
              color: const Color(0xFFF2F4F7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < activities.length; i++) ...[
                if (i > 0) SizedBox(height: 18.h),
                _buildActivityTile(activities[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile(TrustedActivityItem item) {
    final isCheckIn = item.type == TrustedActivityType.checkIn;

    final circleColor =
        isCheckIn ? const Color(0xFFD1FADF) : const Color(0xFFFFE4E6);
    final iconColor =
        isCheckIn ? const Color(0xFF039855) : const Color(0xFFE11D48);
    final iconData = isCheckIn
        ? Icons.check_circle_outline_rounded
        : Icons.notifications_none_rounded;

    final badgeBg =
        isCheckIn ? const Color(0xFFD1FADF) : const Color(0xFFF4F3FF);
    final badgeTextColor =
        isCheckIn ? const Color(0xFF039855) : const Color(0xFF6941C6);

    return InkWell(
      onTap: () => onItemTap?.call(item),
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left circle icon
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // Title & Timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D2939),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.time,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Right status pill badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.badgeIcon != null) ...[
                  Icon(
                    item.badgeIcon,
                    size: 13.sp,
                    color: badgeTextColor,
                  ),
                  SizedBox(width: 4.w),
                ],
                Text(
                  item.badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: badgeTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
