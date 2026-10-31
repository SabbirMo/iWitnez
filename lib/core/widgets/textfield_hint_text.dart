import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';

class TextFieldHintText extends StatelessWidget {
  const TextFieldHintText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 6.h),
      child: Text(
        text,
        style: CustomTextStyle.regular14(
          isDark ? AppColors.white : AppColors.fieldText,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
