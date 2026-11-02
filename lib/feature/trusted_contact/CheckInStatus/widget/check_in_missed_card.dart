import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInMissedCard extends StatelessWidget {
  final String wardName;
  final String? title;
  final String? subtitle;
  final String? lastCheckInTime;

  const CheckInMissedCard({
    super.key,
    required this.wardName,
    this.title,
    this.subtitle,
    this.lastCheckInTime,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = (title != null && title!.isNotEmpty)
        ? title!
        : "$wardName hasn't Checked In";
    final displaySubtitle = (subtitle != null && subtitle!.isNotEmpty)
        ? subtitle!
        : "We'll notify you when they check in.";
    final displayTime =
        (lastCheckInTime != null && lastCheckInTime!.isNotEmpty)
            ? lastCheckInTime!
            : 'Yesterday, 08:15 PM';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
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
      padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 18.h),
      child: Column(
        children: [
          // Centered Warning with Sparkle Accents
          SizedBox(
            width: 80.r,
            height: 80.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sparkle accents
                Positioned(
                  left: 6.w,
                  top: 18.h,
                  child: Container(
                    width: 6.w,
                    height: 2.h,
                    color: const Color(0xFFFDBA74),
                  ),
                ),
                Positioned(
                  right: 8.w,
                  top: 16.h,
                  child: Container(
                    width: 6.w,
                    height: 2.h,
                    color: const Color(0xFFFDBA74),
                  ),
                ),
                Positioned(
                  right: 8.w,
                  bottom: 22.h,
                  child: Container(
                    width: 3.r,
                    height: 3.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDBA74),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 8.w,
                  bottom: 20.h,
                  child: Container(
                    width: 3.r,
                    height: 3.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDBA74),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Outer Halo
                Container(
                  width: 62.r,
                  height: 62.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1E6),
                    shape: BoxShape.circle,
                  ),
                ),

                // Inner Orange Circle
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97316),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            displayTitle,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // Subtitle
          Text(
            displaySubtitle,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 18.h),

          // Divider
          const Divider(
            color: Color(0xFFF3F4F6),
            height: 1,
            thickness: 1,
          ),
          SizedBox(height: 14.h),

          // Last Check In Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14.sp,
                color: const Color(0xFFF97316),
              ),
              SizedBox(width: 6.w),
              Text(
                'Last Check In',
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),

          // Time text
          Text(
            displayTime,
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF97316),
            ),
          ),
        ],
      ),
    );
  }
}
