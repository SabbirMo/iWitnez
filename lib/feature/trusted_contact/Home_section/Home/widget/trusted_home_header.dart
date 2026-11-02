import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class TrustedHomeHeader extends StatelessWidget {
  const TrustedHomeHeader({
    super.key,
    this.greeting,
    required this.userName,
    required this.subtitle,
    required this.avatarUrl,
    required this.hasNotification,
    this.unreadNotificationsCount = 0,
    this.onNotificationTap,
  });

  final String? greeting;
  final String userName;
  final String subtitle;
  final String avatarUrl;
  final bool hasNotification;
  final int unreadNotificationsCount;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: 50.r,
          height: 50.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackAvatar(),
                  )
                : _buildFallbackAvatar(),
          ),
        ),
        SizedBox(width: 14.w),

        // Greeting text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (greeting != null && greeting!.isNotEmpty)
                    ? greeting!
                    : (userName.isNotEmpty ? 'Hi $userName' : ''),
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D2939),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),

        // Notification Bell Icon with purple badge
        InkWell(
          onTap: onNotificationTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(6.r),
            child: SizedBox(
              width: 32.w,
              height: 32.h,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    ImageAssets.notificatioBell,
                    width: 24.w,
                    height: 24.h,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF1D2939),
                      BlendMode.srcIn,
                    ),
                  ),
                  if (hasNotification || unreadNotificationsCount > 0)
                    Positioned(
                      top: 1.h,
                      right: 1.w,
                      child: Container(
                        width: 9.r,
                        height: 9.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9124FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5.w),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: const Color(0xFFF3E8FF),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.buttonGradientStart,
          size: 28.sp,
        ),
      ),
    );
  }
}
