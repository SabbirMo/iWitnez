import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

/// =====================================================================
/// HOME APP HEADER — avatar, greeting text, notification bell
/// =====================================================================
class HomeAppHeader extends StatelessWidget {
  const HomeAppHeader({
    super.key,
    required this.userName,
    required this.subtitle,
    required this.hasUnreadNotification,
    this.unreadCount = 0,
    this.avatarUrl,
    this.userFullName,
    this.onNotificationTap,
  });

  final String userName;
  final String subtitle;
  final bool hasUnreadNotification;
  final int unreadCount;
  final String? avatarUrl;
  final String? userFullName;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 86.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 52.w,
              height: 52.h,
              clipBehavior: Clip.antiAlias,
              decoration: const ShapeDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE4E6), Color(0xFFF5E8FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: OvalBorder(),
              ),
              child: _buildAvatarContent(),
            ),
          ),
          Positioned(
            left: 66.w,
            top: 10.h,
            child: Text(
              _formatGreeting(),
              style: GoogleFonts.inter(
                color: AppColors.black,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                height: 0.75,
              ),
            ),
          ),
          Positioned(
            left: 66.w,
            top: 36.h,
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                color: AppColors.black,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 4.h,
            child: InkWell(
              onTap: onNotificationTap,
              borderRadius: BorderRadius.circular(20.r),
              child: SizedBox(
                width: 40.w,
                height: 40.h,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: SvgPicture.asset(ImageAssets.notificatioBell),
                    ),
                    if (hasUnreadNotification && unreadCount > 0)
                      Positioned(
                        right: 10.w,
                        top: -6.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.w,
                            minHeight: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9023FF),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      )
                    else if (hasUnreadNotification)
                      Positioned(
                        right: 18,
                        top: -8,
                        child: Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const ShapeDecoration(
                            color: Color(0xFF9023FF),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      return Image.network(
        avatarUrl!,
        width: 52.w,
        height: 52.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitials(),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    final initials = _computeInitials();
    if (initials.isNotEmpty) {
      return Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            color: AppColors.buttonGradientStart,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Icon(
      Icons.person_rounded,
      color: AppColors.buttonGradientStart,
      size: 32.sp,
    );
  }

  String _computeInitials() {
    final nameToUse = (userFullName != null && userFullName!.trim().isNotEmpty)
        ? userFullName!.trim()
        : userName.trim();
    if (nameToUse.isEmpty) return '';
    final parts = nameToUse.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return '$first$second'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '';
  }

  String _formatGreeting() {
    final clean = userName.trim();
    if (clean.toLowerCase().startsWith('hi ')) {
      return clean;
    }
    final firstName = clean.split(RegExp(r'\s+')).first;
    return 'Hi $firstName';
  }
}
