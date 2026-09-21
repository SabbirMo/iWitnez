import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(ImageAssets.mainLogo, width: 42.w),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppString.trustedContact,
                        style: CustomTextStyle.bold30(AppColors.textDark)
                            .copyWith(fontSize: 20.sp),
                      ),
                      Text(
                        AppString.trustedContactSubtitle,
                        style: CustomTextStyle.regular14(AppColors.textMuted)
                            .copyWith(fontSize: 12.sp),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, const Color(0xFF12B886)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppString.trustedHome,
                      style: CustomTextStyle.bold32(Colors.white)
                          .copyWith(fontSize: 22.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppString.trustedHomeDesc,
                      style: CustomTextStyle.regular14(
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Home Screen",
                style: CustomTextStyle.bold32(
                  LinearGradient(
                    colors: [AppColors.primaryBlue, const Color(0xFF12B886)],
                  ),
                ).copyWith(fontSize: 40.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                "(Live location status & activity feed will appear here)",
                style: CustomTextStyle.regular16(AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
