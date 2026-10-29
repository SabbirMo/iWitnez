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
    return Positioned(
      right: 16.w,
      top: 80.h,
      child: Column(
        children: [
          // Compass button
          if (onCompassTap != null) ...[
            _buildCircleMapButton(
              icon: Icons.explore_outlined,
              iconColor: const Color(0xFF8B2CF5),
              onTap: onCompassTap!,
            ),
            SizedBox(height: 10.h),
          ],

          // Layers icon button
          _buildCircleMapButton(
            icon: Icons.layers_outlined,
            onTap: onLayersTap ?? () {},
          ),
          SizedBox(height: 10.h),

          // My Location icon button
          _buildCircleMapButton(
            icon: Icons.my_location_rounded,
            onTap: onMyLocationTap ?? () {},
          ),
          SizedBox(height: 10.h),

          // Zoom In / Zoom Out pill
          Container(
            width: 38.r,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
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
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Color(0xFFE5E7EB),
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
                        color: const Color(0xFF4B5563),
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
    Color iconColor = const Color(0xFF4B5563),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.r),
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 19.sp),
      ),
    );
  }
}
