import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class TrustedCareBanner extends StatelessWidget {
  const TrustedCareBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5544FA),
            Color(0xFF6B4CFE),
            Color(0xFF8C47FA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4CFE).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Someone You Care About\nIs safe with Us',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Get Real Time updates and safety alerts',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),

            // Right 3D Shield checkmark
            Image.asset(
              ImageAssets.protectedIcon,
              width: 58.w,
              height: 64.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
