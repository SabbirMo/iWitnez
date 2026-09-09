import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/core/widgets/pulse_circle.dart';
import 'package:iwitnez/feature/onboarding/controller/start_animations.dart';
import 'package:iwitnez/router/app_route_names.dart';

class OnboardingStartScreen extends ConsumerStatefulWidget {
  const OnboardingStartScreen({super.key});

  @override
  ConsumerState<OnboardingStartScreen> createState() =>
      _OnboardingStartScreenState();
}

class _OnboardingStartScreenState extends ConsumerState<OnboardingStartScreen>
    with TickerProviderStateMixin {
  late final StartAnimations _animations;

  @override
  void initState() {
    super.initState();
    _animations = StartAnimations(this);
  }

  @override
  void reassemble() {
    super.reassemble();
    _animations.reassemble();
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content column
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 1. Header Text Section ("iWitnez" + "Stay Connected. Stay Protected")
                  _animations.textTransition(
                    child: Image.asset(
                      ImageAssets.logoText,
                      width: 210.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  _animations.taglineTransition(
                    child: Text(
                      AppString.splashText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 2. Main Logo with Signal / Pulse Ripple Waves
                  RepaintBoundary(
                    child: SizedBox(
                      width: 170.w,
                      height: 170.w,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          PulseCircle(
                            animation: _animations.pulseController,
                            delay: 0.0,
                          ),
                          PulseCircle(
                            animation: _animations.pulseController,
                            delay: 0.33,
                          ),
                          PulseCircle(
                            animation: _animations.pulseController,
                            delay: 0.66,
                          ),
                          // Main Logo (Hero Transition from Splash Screen)
                          Hero(
                            tag: 'app_main_logo',
                            child: Image.asset(
                              ImageAssets.mainLogo,
                              width: 170.w,
                              height: 170.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // 3. "Get Start →" Gradient Button
                  _animations.buttonTransition(
                    child: CustomButton(
                      text: "Get Start",
                      onTap: () {
                        context.pushReplacement(AppRouteNames.onBoardingScreen);
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
