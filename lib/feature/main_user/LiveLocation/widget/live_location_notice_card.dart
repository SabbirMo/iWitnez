import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';

class LiveLocationNoticeCard extends StatelessWidget {
  final int contactsCount;
  final VoidCallback? onManageTap;

  const LiveLocationNoticeCard({
    super.key,
    required this.contactsCount,
    this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shield icon
          Image.asset(ImageAssets.protected, width: 40.w, height: 40.h),
          SizedBox(width: 12.w),

          // Message
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textDark,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: 'Your location is being shared \n',
                    style: CustomTextStyle.semiBold14(
                      AppColors.textDark,
                    ).copyWith(fontSize: 12.sp),
                  ),
                  TextSpan(
                    text: 'with $contactsCount trusted contacts',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 11.sp,
                      color: AppColors.onboardingDesc,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Manage link
          InkWell(
            onTap: onManageTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Manage',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.homeSosStart,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16.sp,
                  color: AppColors.homeSosStart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
