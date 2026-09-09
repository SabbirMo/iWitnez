import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final double? width;
  final double? height;
  final double? borderRadius;
  final List<Color>? gradientColors;
  final TextStyle? textStyle;
  final Color? iconColor;
  final double? iconSize;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon = Icons.arrow_forward_rounded,
    this.width = double.infinity,
    this.height,
    this.borderRadius,
    this.gradientColors,
    this.textStyle,
    this.iconColor = Colors.white,
    this.iconSize,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 30.r;

    return Container(
      width: width,
      height: height ?? 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors:
              gradientColors ??
              const [AppColors.primaryPurple, AppColors.primaryBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: isLoading ? null : onTap,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style:
                            textStyle ??
                            GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                      ),
                      if (icon != null) ...[
                        SizedBox(width: 8.w),
                        Icon(icon, color: iconColor, size: iconSize ?? 20.sp),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
