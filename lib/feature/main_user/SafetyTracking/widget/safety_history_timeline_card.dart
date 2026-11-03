import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/widgets/shimmer_loading.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/location_history_model.dart';

class SafetyHistoryTimelineCard extends StatelessWidget {
  final List<LocationHistoryTimelineItem> items;
  final bool isToday;
  final String dateDisplay;
  final bool isLoading;

  const SafetyHistoryTimelineCard({
    super.key,
    required this.items,
    this.isToday = true,
    this.dateDisplay = 'Today',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            ShimmerEffect(
              child: Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerCircle(size: 14.r),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: 140.w, height: 13.h, borderRadius: 4),
                              SizedBox(height: 5.h),
                              ShimmerBox(width: 90.w, height: 10.h, borderRadius: 4),
                            ],
                          ),
                        ),
                        ShimmerBox(width: 50.w, height: 11.h, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 32.sp,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No location history available for this date.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            for (int i = 0; i < items.length; i++)
              _buildTimelineRow(
                item: items[i],
                isFirst: i == 0,
                isLast: i == items.length - 1,
                isDark: isDark,
              ),
            SizedBox(height: 12.h),

            // Bottom info banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2232) : const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : Colors.transparent,
                ),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Showing history for ',
                      style: GoogleFonts.inter(
                        fontSize: 11.2.sp,
                        color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF6B7280),
                      ),
                    ),
                    TextSpan(
                      text: isToday ? 'Today' : dateDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 11.2.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFA855F7) : AppColors.callsPurple,
                      ),
                    ),
                    TextSpan(
                      text: ' • All times are in local time.',
                      style: GoogleFonts.inter(
                        fontSize: 11.2.sp,
                        color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineRow({
    required LocationHistoryTimelineItem item,
    required bool isFirst,
    required bool isLast,
    required bool isDark,
  }) {
    // Dot indicator color mapping:
    // start -> Green (#2ECC71 / #16A34A)
    // waypoint -> Purple (#6C5CE7)
    // end -> Red (#E74C3C / #EF4444)
    final (indicatorColor, labelColor) = switch (item.pointType.toLowerCase()) {
      'start' => (const Color(0xFF2ECC71), const Color(0xFF16A34A)),
      'end' => (const Color(0xFFE74C3C), const Color(0xFFEF4444)),
      _ => (const Color(0xFF6C5CE7), isDark ? const Color(0xFFA855F7) : const Color(0xFF6C5CE7)),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left indicator column (double circle + dotted line)
          Column(
            children: [
              // Double concentric circle
              Container(
                width: 17.r,
                height: 17.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: indicatorColor,
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Dotted vertical line if not last
              if (!isLast)
                Expanded(
                  child: CustomPaint(
                    size: const Size(2, double.infinity),
                    painter: _DottedVerticalLinePainter(
                      color: isDark ? const Color(0xFF262938) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),

          // Right Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time row + Badge / Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.timeDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      if (item.isStart)
                        Text(
                          'Start',
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        )
                      else if (item.isEnd)
                        Text(
                          'End',
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        )
                      else ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13.sp,
                              color: isDark ? const Color(0xFFA855F7) : const Color(0xFF6C5CE7),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              item.durationDisplay,
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFFA855F7) : const Color(0xFF6C5CE7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Start subtitle tag
                  if (item.isStart) ...[
                    Text(
                      'Start',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ] else if (item.isEnd) ...[
                    Text(
                      'End',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ] else if (item.durationDisplay.isNotEmpty) ...[
                    Text(
                      item.durationDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFA855F7) : const Color(0xFF6C5CE7),
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],

                  // Address
                  Text(
                    item.address,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedVerticalLinePainter extends CustomPainter {
  final Color color;
  _DottedVerticalLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 6.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    while (startY < size.height - 2) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedVerticalLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
