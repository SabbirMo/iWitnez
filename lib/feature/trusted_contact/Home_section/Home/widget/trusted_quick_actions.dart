import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/model/home_model.dart';

class TrustedQuickActions extends StatelessWidget {
  const TrustedQuickActions({
    super.key,
    required this.actions,
    this.isDark,
    this.onCheckInStatusTap,
    this.onJourneyEtaTap,
  });

  final List<QuickActionModel> actions;
  final bool? isDark;
  final VoidCallback? onCheckInStatusTap;
  final VoidCallback? onJourneyEtaTap;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    final dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: dark ? Colors.white : const Color(0xFF1D2939),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              if (i > 0) SizedBox(width: 14.w),
              Expanded(
                child: _buildActionItem(actions[i], dark),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(QuickActionModel action, bool dark) {
    final isCheckIn = action.id == 'check_in_status';
    final isJourney = action.id == 'journey_eta';

    return _buildActionCard(
      label: action.title,
      dark: dark,
      circleColor: isCheckIn
          ? (dark ? const Color(0xFF132F20) : const Color(0xFFE8FDF0))
          : (isJourney
              ? (dark ? const Color(0xFF0F253E) : const Color(0xFFEFF8FF))
              : (dark ? const Color(0xFF261D42) : const Color(0xFFF4F3FF))),
      svgAsset: isCheckIn
          ? ImageAssets.quickCheckIn
          : (isJourney ? ImageAssets.quickTimer : null),
      fallbackIcon: isCheckIn
          ? Icons.check_box_rounded
          : (isJourney ? Icons.calendar_today_rounded : Icons.flash_on_rounded),
      fallbackColor: isCheckIn
          ? const Color(0xFF22C55E)
          : (isJourney ? const Color(0xFF007AFF) : const Color(0xFF8B2CF5)),
      onTap: isCheckIn
          ? onCheckInStatusTap
          : (isJourney ? onJourneyEtaTap : null),
    );
  }

  Widget _buildActionCard({
    required String label,
    required bool dark,
    required Color circleColor,
    required String? svgAsset,
    required IconData fallbackIcon,
    required Color fallbackColor,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          width: 1.w,
          color: dark ? const Color(0xFF262938) : const Color(0xFFF2F4F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.3 : 0.03),
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
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon circle with soft background
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: svgAsset != null
                        ? SvgPicture.asset(
                            svgAsset,
                            width: 26.r,
                            height: 26.r,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              fallbackIcon,
                              color: fallbackColor,
                              size: 24.sp,
                            ),
                          )
                        : Icon(
                            fallbackIcon,
                            color: fallbackColor,
                            size: 24.sp,
                          ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Label
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: dark ? Colors.white : const Color(0xFF344054),
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
