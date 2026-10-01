import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/user_role/user_role.dart';

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.navigationShell,
    required this.role,
  });

  final StatefulNavigationShell navigationShell;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
          child: _FloatingNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => _goBranch(index),
            role: role,
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final activeColor = role == UserRole.mainUser
        ? const Color(0xFF9124FF)
        : const Color(0xFF12B886);
    const inactiveColor = Color(0xFF717680);

    final items = [
      _NavItemSpec(index: 0, label: AppString.home, svgPath: ImageAssets.home),
      _NavItemSpec(index: 1, label: AppString.chat, svgPath: ImageAssets.chat),
      _NavItemSpec(
        index: 2,
        label: AppString.calls,
        svgPath: ImageAssets.callSvg,
      ),
      _NavItemSpec(
        index: 3,
        label: AppString.profile,
        svgPath: ImageAssets.personSvg,
      ),
    ];

    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: _NavItem(
                spec: item,
                isActive: currentIndex == item.index,
                onTap: () => onTap(item.index),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItemSpec {
  const _NavItemSpec({
    required this.index,
    required this.label,
    required this.svgPath,
  });

  final int index;
  final String label;
  final String svgPath;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  final _NavItemSpec spec;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;
    final fontWeight = isActive ? FontWeight.w600 : FontWeight.w500;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.only(top: 7.h, bottom: 4.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── SVG Icon ──
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: Center(
                child: SvgPicture.asset(
                  spec.svgPath,
                  width: 19.w,
                  height: 19.h,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
            ),

            // ── Label Text ──
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 10.5.sp,
                fontWeight: fontWeight,
                letterSpacing: 0.1,
                height: 1.1,
              ),
            ),

            // ── Bottom Active Indicator Pill ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: isActive ? 20.w : 0,
              height: 3.h,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
