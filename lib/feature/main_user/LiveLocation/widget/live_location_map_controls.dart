import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LiveLocationMapControls extends StatelessWidget {
  final VoidCallback? onMyLocationTap;
  final VoidCallback? onLayersTap;
  final VoidCallback? onCompassTap;
  final VoidCallback? onZoomInTap;
  final VoidCallback? onZoomOutTap;

  const LiveLocationMapControls({
    super.key,
    this.onMyLocationTap,
    this.onLayersTap,
    this.onCompassTap,
    this.onZoomInTap,
    this.onZoomOutTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      right: 16.w,
      top: 80.h,
      child: Column(
        children: [
          // Compass button
          if (onCompassTap != null) ...[
            _buildCircleMapButton(
              icon: Icons.explore_outlined,
              iconColor: isDark ? const Color(0xFFA855F7) : const Color(0xFF8B2CF5),
              onTap: onCompassTap!,
              isDark: isDark,
            ),
            SizedBox(height: 10.h),
          ],

          // Layers icon button
          _buildCircleMapButton(
            icon: Icons.layers_outlined,
            onTap: onLayersTap ?? () {},
            isDark: isDark,
          ),
          SizedBox(height: 10.h),

          // My Location icon button
          _buildCircleMapButton(
            icon: Icons.my_location_rounded,
            onTap: onMyLocationTap ?? () {},
            isDark: isDark,
          ),
          SizedBox(height: 10.h),

          // Zoom In / Zoom Out pill
          Container(
            width: 38.r,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181A26) : Colors.white,
              borderRadius: BorderRadius.circular(19.r),
              border: Border.all(
                color: isDark ? const Color(0xFF262938) : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: onZoomInTap,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(19.r),
                  ),
                  child: SizedBox(
                    height: 36.h,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 19.sp,
                        color: isDark ? Colors.white : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFE5E7EB),
                ),
                InkWell(
                  onTap: onZoomOutTap,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(19.r),
                  ),
                  child: SizedBox(
                    height: 36.h,
                    child: Center(
                      child: Icon(
                        Icons.remove,
                        size: 19.sp,
                        color: isDark ? Colors.white : const Color(0xFF4B5563),
                      ),
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

  Widget _buildCircleMapButton({
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final effectiveIconColor = iconColor ?? (isDark ? Colors.white : const Color(0xFF4B5563));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.r),
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181A26) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF262938) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: effectiveIconColor, size: 19.sp),
      ),
    );
  }
}
