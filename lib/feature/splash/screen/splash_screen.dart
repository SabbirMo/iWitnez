import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/widgets/pulse_circle.dart';
import 'package:iwitnez/router/app_route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _navigationTimer;
  AnimationController? _entranceController;
  AnimationController? _pulseController;

  Animation<double>? _logoScale;
  Animation<double>? _logoFade;
  Animation<double>? _textFade;
  Animation<Offset>? _textSlide;
  Animation<double>? _taglineFade;
  Animation<Offset>? _taglineSlide;
  Animation<double>? _lineWidth;
  Animation<double>? _dotScale;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (!(_entranceController?.isAnimating ?? false) &&
        !(_entranceController?.isCompleted ?? false)) {
      _entranceController?.forward();
    }
    if (!(_pulseController?.isAnimating ?? false)) {
      _pulseController?.repeat();
    }
  }

  void _initAnimations() {
    _entranceController?.dispose();
    _pulseController?.dispose();

    // 1. Entrance animation for content
    final entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _entranceController = entrance;

    // 2. Signal / Pulse ripple animation behind mainLogo (smooth 3s loop)
    final pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _pulseController = pulse;

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: entrance,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entrance,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entrance,
        curve: const Interval(0.3, 0.75, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entrance,
            curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entrance,
        curve: const Interval(0.5, 0.85, curve: Curves.easeIn),
      ),
    );

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entrance,
            curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    _lineWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entrance,
        curve: const Interval(0.65, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _dotScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entrance,
        curve: const Interval(0.75, 1.0, curve: Curves.elasticOut),
      ),
    );

    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.pushReplacement(AppRouteNames.onBoardingStartScreen);
      }
    });

    entrance.forward();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_entranceController == null || _pulseController == null) {
      _initAnimations();
    }

    final entranceController = _entranceController!;
    final pulseController = _pulseController!;
    final logoScale = _logoScale!;
    final logoFade = _logoFade!;
    final textFade = _textFade!;
    final textSlide = _textSlide!;
    final taglineFade = _taglineFade!;
    final taglineSlide = _taglineSlide!;
    final lineWidth = _lineWidth!;
    final dotScale = _dotScale!;

    final screenHeight = MediaQuery.sizeOf(context).height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Bottom static wave background
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                width: double.infinity,
                height: screenHeight * 0.28,
                child: Image.asset(
                  ImageAssets.waveBg,
                  fit: BoxFit.fill,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),

            // Centered content (logo, app name, tagline, accent bar)
            Positioned.fill(
              bottom: screenHeight * 0.20,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Main Shield / Camera Logo with Pulse/Signal Waves (isolated in RepaintBoundary for 60-120 FPS)
                        RepaintBoundary(
                          child: SizedBox(
                            width: 145.w,
                            height: 145.w,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                PulseCircle(
                                  animation: pulseController,
                                  delay: 0.0,
                                ),
                                PulseCircle(
                                  animation: pulseController,
                                  delay: 0.33,
                                ),
                                PulseCircle(
                                  animation: pulseController,
                                  delay: 0.66,
                                ),
                                // Main Shield / Camera Logo (stable entrance, no bouncing)
                                ScaleTransition(
                                  scale: logoScale,
                                  child: FadeTransition(
                                    opacity: logoFade,
                                    child: Hero(
                                      tag: 'app_main_logo',
                                      child: Image.asset(
                                        ImageAssets.mainLogo,
                                        width: 145.w,
                                        height: 145.w,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 48.h),

                        // App Name Logo Text ("iWitnez")
                        FadeTransition(
                          opacity: textFade,
                          child: SlideTransition(
                            position: textSlide,
                            child: Image.asset(
                              ImageAssets.logoText,
                              width: 195.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Subtitle / Tagline
                        FadeTransition(
                          opacity: taglineFade,
                          child: SlideTransition(
                            position: taglineSlide,
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
                        ),
                        SizedBox(height: 14.h),

                        // Gradient Accent Line with Pulsing Red Dot (isolated layer)
                        RepaintBoundary(
                          child: _buildAnimatedAccentLine(
                            entranceController: entranceController,
                            pulseController: pulseController,
                            lineWidth: lineWidth,
                            dotScale: dotScale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Animated progress/accent line with expanding width and pulsing red recording dot
  Widget _buildAnimatedAccentLine({
    required AnimationController entranceController,
    required AnimationController pulseController,
    required Animation<double> lineWidth,
    required Animation<double> dotScale,
  }) {
    final maxLineWidth = 185.w;

    return AnimatedBuilder(
      animation: Listenable.merge([entranceController, pulseController]),
      builder: (context, child) {
        // Subtle pulsing glow on the red dot (like recording indicator)
        final pulse =
            1.0 + 0.12 * math.sin(pulseController.value * 4 * math.pi);
        final glowAlpha =
            0.35 + 0.25 * math.sin(pulseController.value * 4 * math.pi);

        return SizedBox(
          width: maxLineWidth,
          height: 12.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding Gradient Line
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: maxLineWidth * lineWidth.value,
                  height: 2.5.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.r),
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.primaryBlue],
                    ),
                  ),
                ),
              ),

              // Pulsing Red Dot
              Transform.scale(
                scale: dotScale.value * pulse,
                child: Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: AppColors.accentRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentRed.withValues(alpha: glowAlpha),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
