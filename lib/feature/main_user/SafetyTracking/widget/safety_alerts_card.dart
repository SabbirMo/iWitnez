import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyAlertsCard extends StatelessWidget {
  final VoidCallback onTap;

  const SafetyAlertsCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFF3E8FF),
          width: 1.2.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // Bell icon container
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: const Color(0xFF7C3AED),
                      size: 22.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alerts',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'You will get alerts when you arrive at or leave your safe places.',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // Trailing Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF9CA3AF),
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
