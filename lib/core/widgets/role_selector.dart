import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/user_role/user_role.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  final UserRole selectedRole;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.loginAs,
          style: GoogleFonts.inter(
            color: const Color(0xFF4A4A4A),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                role: UserRole.mainUser,
                isSelected: selectedRole == UserRole.mainUser,
                icon: Icons.person_rounded,
                onTap: () => onChanged(UserRole.mainUser),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _RoleCard(
                role: UserRole.trustedContact,
                isSelected: selectedRole == UserRole.trustedContact,
                icon: Icons.group_rounded,
                onTap: () => onChanged(UserRole.trustedContact),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  final UserRole role;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = 11.79.r;
    const borderWidth = 0.98;
    const contentPadding = 11.79;

    final bgColor =
        isSelected ? const Color(0xFFFAF5FF) : AppColors.white;
    final borderColor =
        isSelected ? const Color(0xFFE9D5FF) : const Color(0xFFE5E7EB);
    final iconBg =
        isSelected ? const Color(0xFF9333EA) : const Color(0xFFF3F4F6);
    final iconColor = isSelected ? AppColors.white : const Color(0xFF374151);
    final titleColor =
        isSelected ? const Color(0xFF7E22CE) : const Color(0xFF374151);
    final titleWeight =
        isSelected ? FontWeight.w700 : FontWeight.w600;
    final subtitleColor =
        isSelected ? AppColors.onboardingDesc : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(contentPadding),
        height: 57.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 31.44.w,
              height: 31.44.w,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 17.sp,
              ),
            ),
            SizedBox(width: contentPadding.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.label,
                    style: GoogleFonts.inter(
                      color: titleColor,
                      fontSize: 11.79.sp,
                      fontWeight: titleWeight,
                      height: 1.33,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    role.subtitle,
                    style: GoogleFonts.inter(
                      color: subtitleColor,
                      fontSize: 8.84.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
