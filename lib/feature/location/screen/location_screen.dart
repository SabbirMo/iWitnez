import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/router/app_route_names.dart';

class LocationScreen extends ConsumerWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              // Top Bar with Skip
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    context.go(AppRouteNames.mainUserHome);
                  },
                  child: Text(
                    'Skip for now',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Location Icon with animated halo rings
              Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.homeScheduleBg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.buttonGradientStart,
                          AppColors.primaryBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 48.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 36.h),

              // Title
              Text(
                'Enable Your Location',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bold30(AppColors.textDark).copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12.h),

              // Description
              Text(
                'To keep you and your trusted contacts safe, iWitnez needs access to your real-time location sharing.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Primary Button
              CustomButton(
                text: 'Enable Location',
                icon: Icons.near_me_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location permission enabled!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                  context.go(AppRouteNames.mainUserHome);
                },
              ),
              SizedBox(height: 16.h),

              // Secondary action
              TextButton(
                onPressed: () {
                  context.go(AppRouteNames.mainUserHome);
                },
                child: Text(
                  'Maybe Later',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
