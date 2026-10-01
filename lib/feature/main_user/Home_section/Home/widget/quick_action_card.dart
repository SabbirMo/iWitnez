import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';

/// Extension providing metadata and styling for each quick action type.
extension QuickActionTypeX on QuickActionType {
  String get title => switch (this) {
    QuickActionType.safety => 'Safety Tracking',
    QuickActionType.checkIn => 'Check In',
    QuickActionType.scheduledTimer => 'Scheduled & Timer',
  };

  String get iconAsset => switch (this) {
    QuickActionType.safety => ImageAssets.quickSafety,
    QuickActionType.checkIn => ImageAssets.quickCheckIn,
    QuickActionType.scheduledTimer => ImageAssets.quickTimer,
  };

  Color get circleColor => switch (this) {
    QuickActionType.safety => AppColors.homeQuickSafetyCircle,
    QuickActionType.checkIn => AppColors.homeQuickCheckInCircle,
    QuickActionType.scheduledTimer => AppColors.homeQuickScheduleCircle,
  };

  Color get shadowColor => switch (this) {
    QuickActionType.safety => AppColors.buttonGradientStart,
    QuickActionType.checkIn => const Color(0xFF28A745),
    QuickActionType.scheduledTimer => const Color(0xFF007AFF),
  };

  double get iconSize => switch (this) {
    QuickActionType.safety => 26.0,
    QuickActionType.checkIn => 24.0,
    QuickActionType.scheduledTimer => 26.0,
  };
}

/// =====================================================================
/// QUICK ACTION CARD
/// =====================================================================
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.type,
    this.onTap,
  });

  final QuickActionType type;
  final VoidCallback? onTap;

  // Convenience named factories for backward compatibility
  factory QuickActionCard.safety({VoidCallback? onTap}) =>
      QuickActionCard(type: QuickActionType.safety, onTap: onTap);

  factory QuickActionCard.checkIn({VoidCallback? onTap}) =>
      QuickActionCard(type: QuickActionType.checkIn, onTap: onTap);

  factory QuickActionCard.scheduledTimer({VoidCallback? onTap}) =>
      QuickActionCard(type: QuickActionType.scheduledTimer, onTap: onTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 0.8.w, color: AppColors.homeQuickCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: type.circleColor.withValues(alpha: 0.25),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular icon container with soft downward elevation shadow
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: type.circleColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 7,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: type.shadowColor.withValues(alpha: 0.20),
                        blurRadius: 9,
                        offset: const Offset(0, 4),
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      type.iconAsset,
                      width: type.iconSize.sp,
                      height: type.iconSize.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  type.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.homeQuickLabel,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
