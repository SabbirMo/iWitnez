import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInTimerCard extends StatelessWidget {
  final int hours;
  final int minutes;
  final int seconds;
  final FixedExtentScrollController hoursController;
  final FixedExtentScrollController minutesController;
  final FixedExtentScrollController secondsController;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int> onSecondsChanged;

  const CheckInTimerCard({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.hoursController,
    required this.minutesController,
    required this.secondsController,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.onSecondsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-In Timer',
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16.h),

          // Digital Display Boxes (Hours : Minutes : Seconds)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeBox(hours.toString().padLeft(2, '0')),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  ':',
                  style: GoogleFonts.inter(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              _buildTimeBox(minutes.toString().padLeft(2, '0')),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  ':',
                  style: GoogleFonts.inter(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              _buildTimeBox(seconds.toString().padLeft(2, '0')),
            ],
          ),
          SizedBox(height: 6.h),

          // Labels: Hours, Minutes, Seconds
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 72.w,
                child: Text(
                  'Hours',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              SizedBox(width: 28.w),
              SizedBox(
                width: 72.w,
                child: Text(
                  'Minutes',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
              SizedBox(width: 28.w),
              SizedBox(
                width: 72.w,
                child: Text(
                  'Seconds',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Scrollable Wheels in rounded card
          Container(
            height: 110.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                // Hours Wheel (0 - 23)
                Expanded(
                  child: CupertinoPicker.builder(
                    scrollController: hoursController,
                    itemExtent: 36.h,
                    selectionOverlay: const SizedBox.shrink(),
                    onSelectedItemChanged: onHoursChanged,
                    childCount: 24,
                    itemBuilder: (context, index) {
                      final isSelected = index == hours;
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: GoogleFonts.inter(
                            fontSize: isSelected ? 16.sp : 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF6D28D9)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Minutes Wheel (0 - 59)
                Expanded(
                  child: CupertinoPicker.builder(
                    scrollController: minutesController,
                    itemExtent: 36.h,
                    selectionOverlay: const SizedBox.shrink(),
                    onSelectedItemChanged: onMinutesChanged,
                    childCount: 60,
                    itemBuilder: (context, index) {
                      final val = index % 60;
                      final isSelected = val == minutes;
                      return Center(
                        child: Text(
                          val.toString().padLeft(2, '0'),
                          style: GoogleFonts.inter(
                            fontSize: isSelected ? 16.sp : 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF6D28D9)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Seconds Wheel (0 - 59)
                Expanded(
                  child: CupertinoPicker.builder(
                    scrollController: secondsController,
                    itemExtent: 36.h,
                    selectionOverlay: const SizedBox.shrink(),
                    onSelectedItemChanged: onSecondsChanged,
                    childCount: 60,
                    itemBuilder: (context, index) {
                      final val = index % 60;
                      final isSelected = val == seconds;
                      return Center(
                        child: Text(
                          val.toString().padLeft(2, '0'),
                          style: GoogleFonts.inter(
                            fontSize: isSelected ? 16.sp : 14.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF6D28D9)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String text) {
    return Container(
      width: 72.w,
      height: 68.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF6D28D9),
          ),
        ),
      ),
    );
  }
}
