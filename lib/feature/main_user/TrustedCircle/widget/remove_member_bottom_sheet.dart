import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';

class RemoveMemberBottomSheet extends StatelessWidget {
  final CircleMember member;
  final String circleTitle;
  final VoidCallback onConfirmRemove;

  const RemoveMemberBottomSheet({
    super.key,
    required this.member,
    required this.circleTitle,
    required this.onConfirmRemove,
  });

  static Future<void> show({
    required BuildContext context,
    required CircleMember member,
    required String circleTitle,
    required VoidCallback onConfirmRemove,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RemoveMemberBottomSheet(
        member: member,
        circleTitle: circleTitle,
        onConfirmRemove: onConfirmRemove,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Close Button (top-right 'x')
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF374151),
                    size: 18.sp,
                  ),
                ),
              ),
            ),

            // Trash Icon with Soft Pink Radial Halo & Particles
            Center(child: Image.asset(ImageAssets.deleteEffect, width: 100.w)),
            SizedBox(height: 6.h),

            // Title: "Removed Member?"
            Text(
              'Removed Member?',
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Description with member name highlighted in bold red
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Are you sure you want to remove\n'),
                  TextSpan(
                    text: member.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  const TextSpan(text: ' from your trusted circle?'),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // Notice Box (Lavender/Pink with red shield person icon)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFFFE4E6), width: 1),
              ),
              child: Row(
                children: [
                  // Red Shield with person
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: const Color(0xFFEF4444),
                        size: 30.sp,
                      ),
                      Icon(
                        Icons.person_outline,
                        color: const Color(0xFFEF4444),
                        size: 13.sp,
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'She will no longer be able to\nview your location or receive alerts.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Action Buttons: Cancel (outlined) and Removed (filled red)
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: removedMemberButton(
                    context,
                    buttonText: "Cancel",
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    backgroundColor: Colors.white,
                    textColor: const Color(0xFFEF4444),
                    isBorder: true,
                  ),
                ),
                SizedBox(width: 14.w),

                // Removed button
                Expanded(
                  child: removedMemberButton(
                    context,
                    buttonText: "Removed",
                    isIconRemoved: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirmRemove();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget removedMemberButton(
    BuildContext context, {
    VoidCallback? onTap,
    Color? backgroundColor,
    Color? textColor,
    String? buttonText,
    bool isIconRemoved = false,
    bool isBorder = false,
  }) {
    return SizedBox(
      height: 48.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFFEF4444),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(
              color: isBorder ? const Color(0xFFEF4444) : Colors.transparent,
              width: 1.2,
            ),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isIconRemoved)
              Image.asset(
                ImageAssets.deleteIcon,
                width: 20.w,
                color: AppColors.white,
              ),
            SizedBox(width: 6.w),
            Text(
              buttonText ?? 'Removed',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
