import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';

class SafePlacesCard extends StatelessWidget {
  final List<SafePlaceModel> places;
  final VoidCallback onManageTap;
  final ValueChanged<SafePlaceModel>? onPlaceTap;
  final VoidCallback onAddSafePlaceTap;

  const SafePlacesCard({
    super.key,
    required this.places,
    required this.onManageTap,
    this.onPlaceTap,
    required this.onAddSafePlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.w),
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
          // Header: Safe Places + Manage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Safe Places',
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: onManageTap,
                borderRadius: BorderRadius.circular(6.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Text(
                    'Manage',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6D28D9),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Safe Places List
          for (int i = 0; i < places.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Divider(
                  color: Color(0xFFF1F5F9),
                  height: 1,
                  thickness: 1,
                ),
              ),
            _buildPlaceTile(context, places[i]),
          ],

          SizedBox(height: 18.h),

          // "Add Safe Place" Button with dashed outline border
          _buildAddSafePlaceButton(context),
        ],
      ),
    );
  }

  Widget _buildPlaceTile(BuildContext context, SafePlaceModel place) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPlaceTap?.call(place),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            children: [
              // Circular icon container
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: place.displayBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    place.displayIcon,
                    color: place.displayIconColor,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),

              // Title and address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      style: GoogleFonts.inter(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      place.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Status badge (Inside / Outside) with Chevron
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    place.isInside ? 'Inside' : 'Outside',
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      fontWeight: place.isInside
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: place.isInside
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: place.isInside
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddSafePlaceButton(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: const Color(0xFF5B17B0).withValues(alpha: 0.45),
        strokeWidth: 1.5,
        dashWidth: 4,
        dashSpace: 3,
        radius: 18.r,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.callsPurple,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            onTap: onAddSafePlaceTap,
            borderRadius: BorderRadius.circular(16.r),
            splashColor: Colors.white.withValues(alpha: 0.15),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              child: Row(
                children: [
                  // White circular plus icon
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: const Color(0xFF1E1B4B),
                        size: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Safe Place',
                          style: GoogleFonts.inter(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Set a new safe place',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Painter for the subtle dashed border around the Add Safe Place button
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  _DashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-1.5, -1.5, size.width + 3.0, size.height + 3.0),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}
