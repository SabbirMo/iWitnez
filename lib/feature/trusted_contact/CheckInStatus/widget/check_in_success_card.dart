import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInSuccessCard extends StatelessWidget {
  final String wardName;
  final String checkInTime;

  const CheckInSuccessCard({
    super.key,
    required this.wardName,
    required this.checkInTime,
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
                // Sparkle accents
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

                // Outer Halo
                Container(
                  width: 62.r,
                  height: 62.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F8EE),
                    shape: BoxShape.circle,
                  ),
                ),

                // Inner Green Button
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
            '$wardName is Checked In',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 4.h),

          // Subtitle
          Text(
            'She marked herself safe',
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 18.h),

          // Divider
          const Divider(
            color: Color(0xFFF3F4F6),
            height: 1,
            thickness: 1,
          ),
          SizedBox(height: 14.h),

          // Checked In At Row
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
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),

          // Time text
          Text(
            checkInTime,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}
