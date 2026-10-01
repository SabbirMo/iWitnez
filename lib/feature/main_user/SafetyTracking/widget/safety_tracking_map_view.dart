import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/provider/safety_tracking_provider.dart';

class SafetyTrackingMapView extends ConsumerWidget {
  const SafetyTrackingMapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetyTrackingProvider);
    final notifier = ref.read(safetyTrackingProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        final mapHeight = constraints.maxHeight;

        // User pin center coordinate
        final userPinX = mapWidth * 0.44;
        final userPinY = mapHeight * 0.52;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Live Tracking Map Image
            Positioned.fill(
              child: ClipRect(
                child: Transform.scale(
                  scale: state.zoomLevel,
                  child: Image.asset(
                    ImageAssets.liveTrackingMap,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // 2. User Pin with Concentric Radar Wave Rings
            Positioned(
              left: userPinX - 65.r,
              top: userPinY - 65.r,
              child: SizedBox(
                width: 130.r,
                height: 130.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer radar ring
                    Container(
                      width: 130.r,
                      height: 130.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Middle radar ring
                    Container(
                      width: 88.r,
                      height: 88.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Inner halo
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.28),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Center solid blue pin with white border and inner dot
                    Container(
                      width: 26.r,
                      height: 26.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3.5.w),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF2563EB,
                            ).withValues(alpha: 0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 7.r,
                          height: 7.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. "You are here" tooltip positioned above the pin
            Positioned(
              left: userPinX - 48.w,
              top: userPinY - 48.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5.r,
                          height: 5.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'You are here',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Pointer triangle tip
                  CustomPaint(
                    size: Size(8.w, 4.h),
                    painter: _TrianglePainter(color: Colors.white),
                  ),
                ],
              ),
            ),

            // 4. Floating Top Notice Card: "Location Sharing Active"
            Positioned(
              top: 12.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Green concentric beacon icon
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: state.isLocationSharingActive
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 12.r,
                          height: 12.r,
                          decoration: BoxDecoration(
                            color: state.isLocationSharingActive
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.isLocationSharingActive
                                ? 'Location Sharing Active'
                                : 'Location Sharing Paused',
                            style: GoogleFonts.inter(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Your trusted circles can see your location.',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.onboardingDesc,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Toggle Switch
                    Transform.scale(
                      scale: 0.85,
                      child: CupertinoSwitch(
                        value: state.isLocationSharingActive,
                        activeTrackColor: const Color(0xFF22C55E),
                        onChanged: (val) {
                          notifier.toggleLocationSharing(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Right Side Floating Map Controls
            Positioned(
              right: 14.w,
              top: 76.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // My Location / Compass Button
                  _buildCircularButton(
                    icon: Icons.my_location_rounded,
                    onTap: () {
                      notifier.resetZoom();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Centered to your current location'),
                          duration: Duration(milliseconds: 1200),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  // Layers Button
                  _buildCircularButton(
                    icon: Icons.layers_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Map layer: Default Street View'),
                          duration: Duration(milliseconds: 1200),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  // Zoom Pill (+ / -)
                  Container(
                    width: 38.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zoom in
                        InkWell(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                          onTap: () => notifier.zoomIn(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Icon(
                              Icons.add_rounded,
                              color: const Color(0xFF2563EB),
                              size: 19.sp,
                            ),
                          ),
                        ),
                        // Divider
                        Container(
                          width: 20.w,
                          height: 1.h,
                          color: const Color(0xFFE2E8F0),
                        ),
                        // Zoom out
                        InkWell(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20.r),
                          ),
                          onTap: () => notifier.zoomOut(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Icon(
                              Icons.remove_rounded,
                              color: const Color(0xFF2563EB),
                              size: 19.sp,
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
      },
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: const Color(0xFF2563EB), size: 20.sp),
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
