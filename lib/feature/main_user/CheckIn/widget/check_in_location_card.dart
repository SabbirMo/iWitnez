import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class CheckInLocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String address;
  final String accuracy;
  final bool isUpdating;
  final VoidCallback onUpdateTap;

  const CheckInLocationCard({
    super.key,
    this.latitude,
    this.longitude,
    required this.address,
    required this.accuracy,
    this.isUpdating = false,
    required this.onUpdateTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = latitude != null &&
        longitude != null &&
        latitude != 0.0 &&
        longitude != 0.0;

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
          // Header: Your Location + Update
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Location',
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: isUpdating ? null : onUpdateTap,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  child: Row(
                    children: [
                      if (isUpdating)
                        SizedBox(
                          width: 14.r,
                          height: 14.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF8B5CF6),
                          ),
                        )
                      else
                        Icon(
                          Icons.refresh_rounded,
                          color: const Color(0xFF8B5CF6),
                          size: 16.sp,
                        ),
                      SizedBox(width: 4.w),
                      Text(
                        'Update',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Map preview (Google Map or Image fallback)
          Container(
            height: 140.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (hasCoordinates)
                  Positioned.fill(
                    child: GoogleMap(
                      key: ValueKey('${latitude}_$longitude'),
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latitude!, longitude!),
                        zoom: 15.0,
                      ),
                      liteModeEnabled: true,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      scrollGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                    ),
                  )
                else
                  Positioned.fill(
                    child: Image.asset(
                      ImageAssets.liveTrackingMap,
                      fit: BoxFit.cover,
                    ),
                  ),

                // Center Pin with Radar Wave
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer radar halo
                      Container(
                        width: 56.r,
                        height: 56.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Inner radar halo
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.28),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Center pin
                      Icon(
                        Icons.location_on_rounded,
                        color: const Color(0xFF7C3AED),
                        size: 26.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Address info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: const Color(0xFF7C3AED),
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.isNotEmpty ? address : 'Fetching address...',
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        height: 1.35,
                      ),
                    ),
                    if (accuracy.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        accuracy.startsWith('Accuracy:')
                            ? accuracy
                            : 'Accuracy: $accuracy',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onboardingDesc,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
