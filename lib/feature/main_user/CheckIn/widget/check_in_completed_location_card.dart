import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iwitnez/core/constants/theme/dark_map_style.dart';

class CheckInCompletedLocationCard extends StatelessWidget {
  final String address;
  final double? latitude;
  final double? longitude;

  const CheckInCompletedLocationCard({
    super.key,
    required this.address,
    this.latitude,
    this.longitude,
  });

  void _showMapModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCoords = latitude != null &&
        longitude != null &&
        latitude != 0.0 &&
        longitude != 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: 0.6.sh,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181A26) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: isDark ? const Color(0xFFA855F7) : const Color(0xFF7C3AED),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        address.isNotEmpty ? address : 'Check-In Location',
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: hasCoords
                    ? GoogleMap(
                        key: ValueKey('${latitude}_${longitude}_$isDark'),
                        style: isDark ? darkMapStyleJson : null,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude!, longitude!),
                          zoom: 16.0,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('checkin_loc'),
                            position: LatLng(latitude!, longitude!),
                            infoWindow: InfoWindow(
                              title: 'Check-in Location',
                              snippet: address,
                            ),
                          ),
                        },
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      )
                    : Center(
                        child: Text(
                          address.isNotEmpty
                              ? address
                              : 'No coordinates available',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () => _showMapModal(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2B1D45) : const Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: isDark ? const Color(0xFFA855F7) : const Color(0xFF7C3AED),
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Location',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        address.isNotEmpty ? address : 'Location recorded',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w400,
                          color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF4B5563),
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                  size: 22.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
