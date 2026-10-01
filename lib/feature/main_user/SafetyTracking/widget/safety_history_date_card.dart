import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetyHistoryDateCard extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const SafetyHistoryDateCard({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            child: Row(
              children: [
                // Calendar icon
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20.sp,
                  color: const Color(0xFF111827),
                ),
                SizedBox(width: 10.w),

                // Label
                Text(
                  'Select Date',
                  style: GoogleFonts.inter(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const Spacer(),

                // Selected Date Text
                Text(
                  _formatDate(selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(width: 4.w),

                // Chevron Down
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
