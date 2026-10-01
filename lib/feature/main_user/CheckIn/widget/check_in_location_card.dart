import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class CheckInLocationCard extends StatelessWidget {
  final String address;
  final String accuracy;
  final VoidCallback onUpdateTap;

  const CheckInLocationCard({
    super.key,
    required this.address,
    required this.accuracy,
    required this.onUpdateTap,
  });

  @override
  Widget build(BuildContext context) {
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
                onTap: onUpdateTap,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  child: Row(
                    children: [
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

          // Map preview image
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
                          color: const Color(
                            0xFF8B5CF6,
                          ).withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Inner radar halo
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF8B5CF6,
                          ).withValues(alpha: 0.28),
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
                      address,
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Accuracy: $accuracy',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onboardingDesc,
                      ),
                    ),
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
