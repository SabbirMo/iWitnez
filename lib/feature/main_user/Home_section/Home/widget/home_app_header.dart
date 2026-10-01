import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

/// =====================================================================
/// HOME APP HEADER — avatar, greeting text, notification bell
/// =====================================================================
class HomeAppHeader extends StatelessWidget {
  const HomeAppHeader({
    super.key,
    required this.userName,
    required this.subtitle,
    required this.hasUnreadNotification,
    this.onNotificationTap,
  });

  final String userName;
  final String subtitle;
  final bool hasUnreadNotification;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 86.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 52.w,
              height: 52.h,
              decoration: const ShapeDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE4E6), Color(0xFFF5E8FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: OvalBorder(),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.buttonGradientStart,
                size: 32.sp,
              ),
            ),
          ),
          Positioned(
            left: 66.w,
            top: 10.h,
            child: Text(
              'Hi $userName',
              style: GoogleFonts.inter(
                color: AppColors.black,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                height: 0.75,
              ),
            ),
          ),
          Positioned(
            left: 66.w,
            top: 36.h,
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                color: AppColors.black,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 4.h,
            child: InkWell(
              onTap: onNotificationTap,
              borderRadius: BorderRadius.circular(20.r),
              child: SizedBox(
                width: 40.w,
                height: 40.h,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: SvgPicture.asset(ImageAssets.notificatioBell),
                    ),
                    if (hasUnreadNotification)
                      Positioned(
                        right: 18,
                        top: -8,
                        child: Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF9023FF),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
