import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';

class SafePlaceSavedBottomSheet extends StatelessWidget {
  final SafePlaceModel place;
  final VoidCallback onGreatTap;

  const SafePlaceSavedBottomSheet({
    super.key,
    required this.place,
    required this.onGreatTap,
  });

  static Future<void> show(
    BuildContext context, {
    required SafePlaceModel place,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      builder: (bottomSheetContext) {
        return SafePlaceSavedBottomSheet(
          place: place,
          onGreatTap: () {
            Navigator.of(bottomSheetContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),

            // Safe place saved check icon with glow and confetti from asset
            Image.asset(
              ImageAssets.safePlaceIcon,
              width: 95.r,
              height: 95.r,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.h),

            // Title: "Safe Place saved!"
            Text(
              'Safe Place saved!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 10.h),

            // Subtitle
            Text(
              "You'll get alerts when you arrive at\nor leave this place.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            SizedBox(height: 22.h),

            // Safe Place Summary Card
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.w),
              ),
              child: Row(
                children: [
                  // Place Icon Container
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: place.displayBackgroundColor,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Icon(
                        place.displayIcon,
                        color: place.displayIconColor,
                        size: 26.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // Place Name & Radius
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          place.title,
                          style: GoogleFonts.inter(
                            fontSize: 15.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Radius: ${place.radius ?? 150} m',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // "Great!" Gradient Button
            Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.r),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7E22CE), // Purple
                    Color(0xFF2563EB), // Blue
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E22CE).withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(26.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(26.r),
                  onTap: onGreatTap,
                  child: Center(
                    child: Text(
                      'Great!',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
