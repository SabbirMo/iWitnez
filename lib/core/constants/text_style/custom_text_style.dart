import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextStyle {
  static TextStyle semiBold14(Color color) {
    return GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle regular16(Color color) {
    return GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle bold32(Object colorOrGradient) {
    if (colorOrGradient is Gradient) {
      return GoogleFonts.inter(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        foreground: Paint()
          ..shader = colorOrGradient.createShader(
            const Rect.fromLTWH(0, 0, 300, 70),
          ),
      );
    }
    return GoogleFonts.inter(
      fontSize: 32.sp,
      fontWeight: FontWeight.w700,
      color: colorOrGradient as Color,
    );
  }
}
