import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInNotSetupCard extends StatelessWidget {
  final String wardName;

  const CheckInNotSetupCard({
    super.key,
    required this.wardName,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
      child: Column(
        children: [
          // Clipboard Vector Graphic
          _buildClipboardGraphic(),
          SizedBox(height: 18.h),

          // Title
          Text(
            'Check-In Not Set Up',
            style: GoogleFonts.inter(
              fontSize: 17.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6.h),

          // Subtitle
          Text(
            "$wardName hasn't set up check-in yet.\nYou'll be notified when they set it up.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
          SizedBox(height: 20.h),

          // Alert Info Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: const Color(0xFF7C3AED),
                    size: 17.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    "You'll get alerts when $wardName sets up check-in or marks herself safe.",
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF4B5563),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipboardGraphic() {
    return SizedBox(
      width: 140.r,
      height: 130.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft lavender background circle / foliage
          Container(
            width: 120.r,
            height: 120.r,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F0FF),
              shape: BoxShape.circle,
            ),
          ),

          // Side leaf accents
          Positioned(
            left: 8.w,
            top: 40.h,
            child: Icon(
              Icons.spa_rounded,
              color: const Color(0xFFDDD6FE),
              size: 26.sp,
            ),
          ),
          Positioned(
            right: 8.w,
            top: 40.h,
            child: Transform.flip(
              flipX: true,
              child: Icon(
                Icons.spa_rounded,
                color: const Color(0xFFDDD6FE),
                size: 26.sp,
              ),
            ),
          ),

          // Clipboard body
          Container(
            width: 80.w,
            height: 98.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF6C48F5),
                width: 2.8.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C48F5).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 14.h),
                // Circular question mark
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '?',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6C48F5),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // Checklist lines
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 11.sp,
                            color: const Color(0xFF6C48F5),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Container(
                              height: 3.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 11.sp,
                            color: const Color(0xFF6C48F5),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Container(
                              height: 3.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Clip of Clipboard
          Positioned(
            top: 10.h,
            child: Container(
              width: 32.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: const Color(0xFF6C48F5),
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
          ),

          // Warning badge at bottom right
          Positioned(
            right: 20.w,
            bottom: 8.h,
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
