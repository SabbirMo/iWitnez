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
          // Header: Safe Places + Manage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Safe Places',
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              if (places.isNotEmpty)
                InkWell(
                  onTap: onManageTap,
                  borderRadius: BorderRadius.circular(6.r),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Text(
                      'Manage',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFA855F7) : const Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Safe Places List (or empty state if none exist yet)
          if (places.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 32.sp,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No safe places added yet.',
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
          else
            for (int i = 0; i < places.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(
                    color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                    height: 1,
                    thickness: 1,
                  ),
                ),
              _buildPlaceTile(context, places[i], isDark),
            ],

          SizedBox(height: 18.h),

          // "Add Safe Place" Button with dashed outline border
          _buildAddSafePlaceButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildPlaceTile(BuildContext context, SafePlaceModel place, bool isDark) {
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
                        color: isDark ? Colors.white : const Color(0xFF111827),
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
                        color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Status badge (Inside / Outside) with Chevron
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: place.isInside
                      ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7))
                      : (isDark ? const Color(0xFF1F2232) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: place.isInside
                        ? const Color(0xFF22C55E).withValues(alpha: 0.6)
                        : (isDark ? const Color(0xFF262938) : const Color(0xFFE2E8F0)),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.displayStatus,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: place.isInside
                            ? const Color(0xFF22C55E)
                            : (isDark ? const Color(0xFF98A2B3) : const Color(0xFF64748B)),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16.sp,
                      color: place.isInside
                          ? const Color(0xFF22C55E)
                          : (isDark ? const Color(0xFF98A2B3) : const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddSafePlaceButton(BuildContext context, bool isDark) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: const Color(0xFF5B17B0).withValues(alpha: isDark ? 0.7 : 0.45),
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
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
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
                          'Home, Work, School, or other places',
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 20.sp,
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

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  _DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 4.0,
    this.dashSpace = 3.0,
    this.radius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace ||
      oldDelegate.radius != radius;
}
