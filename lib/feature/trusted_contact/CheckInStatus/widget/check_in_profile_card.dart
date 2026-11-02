import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import '../model/check_in_status_model.dart';

class CheckInProfileCard extends StatelessWidget {
  final CheckInStatusData data;

  const CheckInProfileCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeTextColor;
    IconData badgeIcon;
    String badgeText;
    String subtitle;

    if (data.isNotSetUp) {
      badgeColor = const Color(0xFFF1F5F9);
      badgeTextColor = const Color(0xFF64748B);
      badgeIcon = Icons.info_outline_rounded;
      badgeText = data.statusBadge.isNotEmpty ? data.statusBadge : 'Not Set Up';
      subtitle = data.badgeSubtext.isNotEmpty ? data.badgeSubtext : 'Pending';
    } else if (data.isMissed) {
      badgeColor = const Color(0xFFFFF1E6);
      badgeTextColor = const Color(0xFFF97316);
      badgeIcon = Icons.warning_amber_rounded;
      badgeText = data.statusBadge.isNotEmpty ? data.statusBadge : 'Missed';
      subtitle =
          data.badgeSubtext.isNotEmpty ? data.badgeSubtext : 'Action Needed';
    } else {
      // checked_in (default)
      badgeColor = const Color(0xFFE8F8EE);
      badgeTextColor = const Color(0xFF16A34A);
      badgeIcon = Icons.check_circle_rounded;
      badgeText =
          data.statusBadge.isNotEmpty ? data.statusBadge : 'Checked In';
      subtitle = data.badgeSubtext.isNotEmpty ? data.badgeSubtext : 'Just now';
    }

    final hasNetworkAvatar = data.monitoredUser.avatarUrl.isNotEmpty &&
        data.monitoredUser.avatarUrl.startsWith('http');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ward / Emma Avatar
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: hasNetworkAvatar
                    ? NetworkImage(data.monitoredUser.avatarUrl)
                    : const AssetImage(ImageAssets.emmaAvatar) as ImageProvider,
                fit: BoxFit.cover,
                onError: (error, stackTrace) {},
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Name
          Expanded(
            child: Text(
              data.wardName,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),

          // Badge & Subtitle Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.5.h,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 13.sp, color: badgeTextColor),
                    SizedBox(width: 4.w),
                    Text(
                      badgeText,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
