import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

/// =====================================================================
/// PROTECTED BANNER — gradient "You are Protected" card
/// =====================================================================
class ProtectedBanner extends StatelessWidget {
  const ProtectedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: const LinearGradient(
          colors: [
            AppColors.homeProtectedBannerStart,
            AppColors.homeProtectedBannerMid,
            AppColors.homeProtectedBannerEnd,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background image (protected_card.png) — covers the whole card
          Positioned.fill(
            child: Image.asset(
              ImageAssets.protectedCard,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
          // Left side — text content
          Positioned(
            left: 16.w,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are Protected',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFBFBFB),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.40,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'All System Are Active',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFE0D8FF),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                  ),
                ),
              ],
            ),
          ),
          // Right side — shield icon
          Positioned(
            right: 16.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                ImageAssets.protectedIcon,
                width: 56.w,
                height: 64.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.shield_rounded,
                  size: 54.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
