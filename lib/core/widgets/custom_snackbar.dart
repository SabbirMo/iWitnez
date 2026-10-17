import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  CustomSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        padding: EdgeInsets.zero,
        duration: duration,
        content: _SnackBarContent(
          message: message,
          title: title,
          type: type,
        ),
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackBarType.info,
      duration: duration,
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final String? title;
  final SnackBarType type;

  const _SnackBarContent({
    required this.message,
    this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStyleConfig(type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: config.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: config.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: config.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              config.icon,
              color: config.iconColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.trim().isNotEmpty) ...[
                  Text(
                    title!,
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: config.titleColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    color: config.textColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _SnackBarConfig _getStyleConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          backgroundColor: const Color(0xFFF0FDF4),
          borderColor: const Color(0xFFBBF7D0),
          iconBgColor: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          titleColor: const Color(0xFF15803D),
          textColor: const Color(0xFF166534),
          shadowColor: const Color(0x1F16A34A),
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          backgroundColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFECACA),
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: AppColors.accentRed,
          titleColor: const Color(0xFFB91C1C),
          textColor: const Color(0xFF991B1B),
          shadowColor: const Color(0x1FFF2424),
          icon: Icons.error_rounded,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          backgroundColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
          iconBgColor: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          titleColor: const Color(0xFFB45309),
          textColor: const Color(0xFF92400E),
          shadowColor: const Color(0x1FD97706),
          icon: Icons.warning_amber_rounded,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          backgroundColor: const Color(0xFFF5F3FF),
          borderColor: const Color(0xFFDDD6FE),
          iconBgColor: const Color(0xFFEDE9FE),
          iconColor: AppColors.buttonGradientStart,
          titleColor: const Color(0xFF6D28D9),
          textColor: const Color(0xFF5B21B6),
          shadowColor: const Color(0x1F7C3AED),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _SnackBarConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBgColor;
  final Color iconColor;
  final Color titleColor;
  final Color textColor;
  final Color shadowColor;
  final IconData icon;

  const _SnackBarConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.titleColor,
    required this.textColor,
    required this.shadowColor,
    required this.icon,
  });
}
