import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInNotSetupCard extends StatelessWidget {
  final String wardName;
  final String? title;
  final String? subtitle;

  const CheckInNotSetupCard({
    super.key,
    required this.wardName,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTitle = (title != null && title!.isNotEmpty)
        ? title!
        : 'Check-In Not Set Up';
    final displaySubtitle = (subtitle != null && subtitle!.isNotEmpty)
        ? subtitle!
        : (wardName.isNotEmpty
            ? "$wardName hasn't set up check-in yet.\nYou'll be notified when they set it up."
            : "Check-in is not set up yet.\nYou'll be notified when it is set up.");

    final alertName = wardName.isNotEmpty ? wardName : 'they';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
      child: Column(
        children: [
          _buildClipboardGraphic(isDark),
          SizedBox(height: 18.h),

          // Title
          Text(
            displayTitle,
            style: GoogleFonts.inter(
              fontSize: 17.5.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),

          // Subtitle
          if (displaySubtitle.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              displaySubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF6B7280),
                height: 1.35,
              ),
            ),
          ],
          SizedBox(height: 20.h),

          // Alert Info Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF261D42)
                  : const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF35265C)
                        : const Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: isDark
                        ? const Color(0xFFD6BBFB)
                        : const Color(0xFF7C3AED),
                    size: 17.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    "You'll get alerts when $alertName sets up check-in or marks safe.",
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: isDark
                          ? const Color(0xFFD6BBFB)
                          : const Color(0xFF4B5563),
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

  Widget _buildClipboardGraphic(bool isDark) {
    return SizedBox(
      width: 140.r,
      height: 130.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120.r,
            height: 120.r,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF261D42)
                  : const Color(0xFFF3F0FF),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: 8.w,
            top: 40.h,
            child: Icon(
              Icons.spa_rounded,
              color: isDark
                  ? const Color(0xFF3D2C68)
                  : const Color(0xFFDDD6FE),
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
                color: isDark
                    ? const Color(0xFF3D2C68)
                    : const Color(0xFFDDD6FE),
                size: 26.sp,
              ),
            ),
          ),
          Container(
            width: 80.w,
            height: 98.h,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2232) : Colors.white,
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
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF35265C)
                        : const Color(0xFFEDE9FE),
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
