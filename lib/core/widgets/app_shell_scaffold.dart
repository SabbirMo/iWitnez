import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
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
          padding: EdgeInsets.fromLTRB(17.w, 0, 17.w, 10.h),
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
        ? const Color(0xFF9023FF)
        : const Color(0xFF12B886);
    const inactiveColor = Color(0xFF767987);

    final items = [
      _NavItemSpec(
        index: 0,
        label: AppString.home,
        icon: Icons.home_rounded,
      ),
      _NavItemSpec(
        index: 1,
        label: AppString.chat,
        icon: Icons.chat_bubble_rounded,
      ),
      _NavItemSpec(
        index: 2,
        label: AppString.calls,
        icon: Icons.call_rounded,
      ),
      _NavItemSpec(
        index: 3,
        label: AppString.profile,
        icon: Icons.person_rounded,
      ),
    ];

    return Container(
      width: 356.w,
      height: 69.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset.zero,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            _NavItem(
              spec: item,
              isActive: currentIndex == item.index,
              onTap: () => onTap(item.index),
              activeColor: activeColor,
              inactiveColor: inactiveColor,
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
    required this.icon,
  });

  final int index;
  final String label;
  final IconData icon;
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
    final fontWeight =
        isActive ? FontWeight.w600 : FontWeight.w500;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(top: 13.h),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  spec.icon,
                  color: color,
                  size: 24.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  spec.label,
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 10.sp,
                    fontWeight: fontWeight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            if (isActive)
              Positioned(
                bottom: -5.h,
                child: Container(
                  width: 26.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
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
