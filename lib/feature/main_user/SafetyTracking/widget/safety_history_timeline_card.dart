import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';

class SafetyHistoryTimelineCard extends StatelessWidget {
  final List<HistoryTimelineItem> items;

  const SafetyHistoryTimelineCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++)
            _buildTimelineRow(
              item: items[i],
              isFirst: i == 0,
              isLast: i == items.length - 1,
            ),
          SizedBox(height: 12.h),

          // Bottom info banner: "Showing history for Today • All times are in local time."
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Showing history for ',
                    style: GoogleFonts.inter(
                      fontSize: 11.2.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  TextSpan(
                    text: 'Today',
                    style: GoogleFonts.inter(
                      fontSize: 11.2.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.callsPurple,
                    ),
                  ),
                  TextSpan(
                    text: ' • All times are in local time.',
                    style: GoogleFonts.inter(
                      fontSize: 11.2.sp,
                      color: const Color(0xFF6B7280),
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

  Widget _buildTimelineRow({
    required HistoryTimelineItem item,
    required bool isFirst,
    required bool isLast,
  }) {
    final (indicatorColor, labelColor) = switch (item.pointType) {
      HistoryPointType.start => (const Color(0xFF10B981), const Color(0xFF16A34A)),
      HistoryPointType.waypoint => (const Color(0xFF6C48F5), const Color(0xFF6C48F5)),
      HistoryPointType.end => (const Color(0xFFEF4444), const Color(0xFFEF4444)),
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
                      color: const Color(0xFFE2E8F0),
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
                  // Time row + Badge/Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.time,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (item.label != null)
                        Text(
                          item.label!,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        )
                      else if (item.duration != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13.sp,
                              color: const Color(0xFF6C48F5),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              item.duration!,
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6C48F5),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Subtitles
                  if (item.pointType == HistoryPointType.start) ...[
                    Text(
                      'Start',
                      style: GoogleFonts.inter(
                        fontSize: 11.8.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],
                  Text(
                    item.address,
                    style: GoogleFonts.inter(
                      fontSize: 11.8.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      height: 1.3,
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
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 3.0;
    const dashSpace = 3.0;
    double startY = 3.0;

    while (startY < size.height - 2.0) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
