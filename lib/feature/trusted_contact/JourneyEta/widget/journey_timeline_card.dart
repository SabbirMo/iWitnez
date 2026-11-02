import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/journey_eta_model.dart';

class JourneyTimelineCard extends StatelessWidget {
  final List<JourneyTimelineItem> items;
  final bool isToday;
  final String dateDisplay;
  final bool isLoading;

  const JourneyTimelineCard({
    super.key,
    required this.items,
    this.isToday = true,
    this.dateDisplay = 'Today',
    this.isLoading = false,
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
          if (isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 36.h),
              child: const Center(
                child: CupertinoActivityIndicator(radius: 12),
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
                      color: const Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No journey history available for this date.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
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
              ),
            SizedBox(height: 12.h),

            // Bottom info banner
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
                      text: isToday ? 'Today' : dateDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 11.2.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C48F5),
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
        ],
      ),
    );
  }

  Widget _buildTimelineRow({
    required JourneyTimelineItem item,
    required bool isFirst,
    required bool isLast,
  }) {
    final (indicatorColor, labelColor) = switch (item.pointType.toLowerCase()) {
      'start' => (const Color(0xFF2ECC71), const Color(0xFF16A34A)),
      'end' => (const Color(0xFFE74C3C), const Color(0xFFEF4444)),
      _ => (const Color(0xFF6C5CE7), const Color(0xFF6C5CE7)),
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
          SizedBox(width: 12.w),

          // Right details column
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time & Badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.timeDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (item.effectiveBadgeText.isNotEmpty)
                        Text(
                          item.effectiveBadgeText,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Label / subtitle if different from time and present
                  if (item.label.isNotEmpty && item.label != item.timeDisplay)
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                      ),
                    ),
                  SizedBox(height: 4.h),

                  // Address
                  if (item.address.isNotEmpty)
                    Text(
                      item.address,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
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
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    double startY = 4.0;
    while (startY < size.height - 2.0) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, (startY + dashHeight).clamp(0.0, size.height)),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

