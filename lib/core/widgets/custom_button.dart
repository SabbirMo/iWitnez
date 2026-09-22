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
  final bool isEnabled;
  final bool isLeadingIcon;
  final IconData? trailingIcon;

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
    this.isEnabled = true,
    this.isLeadingIcon = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 30.r;
    final bool canTap = isEnabled && !isLoading && onTap != null;

    final List<Color> activeGradient =
        gradientColors ??
        const [AppColors.buttonGradientStart, AppColors.primaryBlue];

    final List<Color> disabledGradient = const [
      Color(0xFFD1D5DB),
      Color(0xFFD1D5DB),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: width,
      height: height ?? 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: isEnabled ? activeGradient : disabledGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: canTap ? onTap : null,
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
                      if (icon != null && isLeadingIcon) ...[
                        Icon(
                          icon,
                          color: isEnabled
                              ? iconColor
                              : const Color(0xFF9CA3AF),
                          size: iconSize ?? 20.sp,
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        text,
                        style:
                            textStyle ??
                            GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isEnabled
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                              letterSpacing: 0.3,
                            ),
                      ),
                      if (trailingIcon != null) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          trailingIcon,
                          color: isEnabled
                              ? iconColor
                              : const Color(0xFF9CA3AF),
                          size: iconSize ?? 20.sp,
                        ),
                      ] else if (icon != null && !isLeadingIcon) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          icon,
                          color: isEnabled
                              ? iconColor
                              : const Color(0xFF9CA3AF),
                          size: iconSize ?? 20.sp,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
