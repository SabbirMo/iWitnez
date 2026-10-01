import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/provider/live_location_screen_provider.dart';

class LiveLocationMapControls extends ConsumerWidget {
  final VoidCallback? onMyLocationTap;
  final VoidCallback? onLayersTap;
  final VoidCallback? onCompassTap;

  const LiveLocationMapControls({
    super.key,
    this.onMyLocationTap,
    this.onLayersTap,
    this.onCompassTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(liveLocationScreenProvider.notifier);

    return Stack(
      children: [
        // Floating Compass Button (center-left)
        Positioned(
          left: 140.w,
          top: 140.h,
          child: InkWell(
            onTap: onCompassTap ?? () {},
            borderRadius: BorderRadius.circular(100.r),
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.explore_outlined,
                  color: const Color(0xFF8B2CF5),
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ),

        // Floating Control Buttons on Right Side
        Positioned(
          right: 16.w,
          top: 76.h,
          child: Column(
            children: [
              // Layers icon button
              _buildCircleMapButton(
                icon: Icons.layers_outlined,
                onTap: onLayersTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Map layer: Standard'),
                          duration: Duration(milliseconds: 1200),
                        ),
                      );
                    },
              ),
              SizedBox(height: 10.h),

              // My Location icon button
              _buildCircleMapButton(
                icon: Icons.my_location_rounded,
                onTap: onMyLocationTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Centered to current location'),
                          duration: Duration(milliseconds: 1200),
                        ),
                      );
                    },
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
                      onTap: notifier.zoomIn,
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
                    Divider(
                      height: 1,
                      thickness: 0.8,
                      color: const Color(0xFFE5E7EB),
                    ),
                    InkWell(
                      onTap: notifier.zoomOut,
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
        ),
      ],
    );
  }

  Widget _buildCircleMapButton({
    required IconData icon,
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
        child: Icon(icon, color: const Color(0xFF4B5563), size: 19.sp),
      ),
    );
  }
}
