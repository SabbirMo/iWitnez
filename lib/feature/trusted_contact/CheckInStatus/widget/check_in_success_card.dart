import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInSuccessCard extends StatelessWidget {
  final String wardName;
  final String? title;
  final String? subtitle;
  final String? checkInTime;

  const CheckInSuccessCard({
    super.key,
    required this.wardName,
    this.title,
    this.subtitle,
    this.checkInTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTitle = (title != null && title!.isNotEmpty)
        ? title!
        : (wardName.isNotEmpty ? '$wardName is Checked In' : 'Checked In');
    final displaySubtitle = (subtitle != null && subtitle!.isNotEmpty)
        ? subtitle!
        : '';
    final displayTime = (checkInTime != null && checkInTime!.isNotEmpty)
        ? checkInTime!
        : '';

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
      padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 18.h),
      child: Column(
        children: [
          // Centered Green Check with Sparkle Accents
          SizedBox(
            width: 80.r,
            height: 80.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 6.w,
                  top: 18.h,
                  child: Icon(
                    Icons.add,
                    size: 13.sp,
                    color: const Color(0xFF34D399),
                  ),
                ),
                Positioned(
                  right: 8.w,
                  top: 16.h,
                  child: Container(
                    width: 4.r,
                    height: 4.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34D399),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 6.w,
                  bottom: 22.h,
                  child: Icon(
                    Icons.add,
                    size: 14.sp,
                    color: const Color(0xFF34D399),
                  ),
                ),
                Positioned(
                  left: 10.w,
                  bottom: 20.h,
                  child: Container(
                    width: 4.r,
                    height: 4.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34D399),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  width: 62.r,
                  height: 62.r,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF132B1D)
                        : const Color(0xFFE8F8EE),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
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
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),

          // Subtitle
          if (displaySubtitle.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              displaySubtitle,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? const Color(0xFF98A2B3)
                    : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],

          if (displayTime.isNotEmpty) ...[
            SizedBox(height: 18.h),
            Divider(
              color: isDark
                  ? const Color(0xFF262938)
                  : const Color(0xFFF3F4F6),
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 14.sp,
                  color: const Color(0xFF10B981),
                ),
                SizedBox(width: 6.w),
                Text(
                  'Checked In At',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF98A2B3)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              displayTime,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFF16A34A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
