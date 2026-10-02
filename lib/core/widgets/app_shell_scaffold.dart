import 'dart:ui';

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
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 6.h),
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
    const activeColor = Color(0xFF9124FF);
    const inactiveIconColor = Color(0xFF1D2939);
    const inactiveTextColor = Color(0xFF667085);

    final items = role == UserRole.trustedContact
        ? [
            _NavItemSpec(
              index: 0,
              label: AppString.home,
              svgPath: ImageAssets.home,
            ),
            _NavItemSpec(
              index: 1,
              label: AppString.alerts,
              svgPath: ImageAssets.alertsSvg,
            ),
            _NavItemSpec(
              index: 2,
              label: AppString.chat,
              svgPath: ImageAssets.chat,
            ),
            _NavItemSpec(
              index: 3,
              label: AppString.calls,
              svgPath: ImageAssets.callSvg,
            ),
            _NavItemSpec(
              index: 4,
              label: AppString.profile,
              svgPath: ImageAssets.personSvg,
            ),
          ]
        : [
            _NavItemSpec(
              index: 0,
              label: AppString.home,
              svgPath: ImageAssets.home,
            ),
            _NavItemSpec(
              index: 1,
              label: AppString.chat,
              svgPath: ImageAssets.chat,
            ),
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

    final borderRadius = BorderRadius.circular(16.r);

    return Container(
      width: double.infinity,
      height: 62.h,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.94),
        borderRadius: borderRadius,
        border: Border.all(
          color: const Color(0xff000000).withValues(alpha: 0.15),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in items)
                Expanded(
                  child: _NavItem(
                    spec: item,
                    isActive: currentIndex == item.index,
                    onTap: () => onTap(item.index),
                    activeColor: activeColor,
                    inactiveIconColor: inactiveIconColor,
                    inactiveTextColor: inactiveTextColor,
                  ),
                ),
            ],
          ),
        ),
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
    required this.inactiveIconColor,
    required this.inactiveTextColor,
  });

  final _NavItemSpec spec;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveIconColor;
  final Color inactiveTextColor;

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? activeColor : inactiveIconColor;
    final textColor = isActive ? activeColor : inactiveTextColor;
    final fontWeight = isActive ? FontWeight.w600 : FontWeight.w500;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Column(
        children: [
          SizedBox(height: 5.h),
          // ── SVG Icon ──
          SizedBox(
            width: 22.w,
            height: 22.h,
            child: Center(
              child: SvgPicture.asset(
                spec.svgPath,
                width: 20.w,
                height: 20.h,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                placeholderBuilder: (context) =>
                    SizedBox(width: 20.w, height: 20.h),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // ── Label Text ──
          Text(
            spec.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 11.sp,
              fontWeight: fontWeight,
              letterSpacing: 0.1,
              height: 1.1,
            ),
          ),
          const Spacer(),

          // ── Bottom Active Indicator Pill ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: isActive ? 30.w : 0,
            height: 3.5.h,
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
