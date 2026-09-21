import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppString.calls,
                style: CustomTextStyle.bold30(AppColors.textDark)
                    .copyWith(fontSize: 24.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                AppString.trustedContact,
                style: CustomTextStyle.regular14(AppColors.textMuted),
              ),
              SizedBox(height: 30.h),
              Text(
                AppString.trustedCalls,
                style: CustomTextStyle.bold32(
                  LinearGradient(
                    colors: [AppColors.primaryBlue, const Color(0xFF12B886)],
                  ),
                ).copyWith(fontSize: 40.sp),
              ),
              SizedBox(height: 14.h),
              Text(
                AppString.trustedCallsDesc,
                style: CustomTextStyle.regular16(AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
