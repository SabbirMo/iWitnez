import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';

class SafetyTrackingTabSelector extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color activeColor;
  final Color inactiveTextColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const SafetyTrackingTabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.activeColor = AppColors.callsPurple,
    this.inactiveTextColor = AppColors.onboardingDesc,
    this.backgroundColor = const Color(0xFFF3F4F6),
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Container(
        height: height ?? 46.h,
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(26.r),
        ),
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabSelected(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: selectedIndex == i
                          ? activeColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: selectedIndex == i
                          ? [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tabs[i],
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: selectedIndex == i
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selectedIndex == i
                            ? Colors.white
                            : inactiveTextColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
