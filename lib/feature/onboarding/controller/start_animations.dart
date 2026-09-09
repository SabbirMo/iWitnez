import 'package:flutter/material.dart';

/// Manages entrance and pulse animations for OnboardingStartScreen.
class StartAnimations {
  StartAnimations(TickerProvider vsync) {
    // 1. Entrance animation for content (1400ms)
    entranceController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1400),
    );

    // 2. Signal / Pulse ripple animation behind mainLogo (ultra smooth 3s loop)
    pulseController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Header Logo Text ("iWitnez"): fade + slide up
    textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.25, 0.70, curve: Curves.easeIn),
      ),
    );

    textSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entranceController,
            curve: const Interval(0.25, 0.70, curve: Curves.easeOutCubic),
          ),
        );

    // Subtitle / Tagline text: fade + slide up
    taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.40, 0.85, curve: Curves.easeIn),
      ),
    );

    taglineSlide = Tween<Offset>(begin: const Offset(0, 0.30), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entranceController,
            curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    // "Get Start" Button: fade + slide up
    buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: const Interval(0.60, 1.0, curve: Curves.easeIn),
      ),
    );

    buttonSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entranceController,
            curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    entranceController.forward();
  }

  late final AnimationController entranceController;
  late final AnimationController pulseController;

  late final Animation<double> textFade;
  late final Animation<Offset> textSlide;
  late final Animation<double> taglineFade;
  late final Animation<Offset> taglineSlide;
  late final Animation<double> buttonFade;
  late final Animation<Offset> buttonSlide;

  /// Wraps a widget in Header Text fade & slide transition
  Widget textTransition({required Widget child}) {
    return FadeTransition(
      opacity: textFade,
      child: SlideTransition(position: textSlide, child: child),
    );
  }

  /// Wraps a widget in Tagline fade & slide transition
  Widget taglineTransition({required Widget child}) {
    return FadeTransition(
      opacity: taglineFade,
      child: SlideTransition(position: taglineSlide, child: child),
    );
  }

  /// Wraps a widget in Button fade & slide transition
  Widget buttonTransition({required Widget child}) {
    return FadeTransition(
      opacity: buttonFade,
      child: SlideTransition(position: buttonSlide, child: child),
    );
  }

  void reassemble() {
    if (!entranceController.isAnimating && !entranceController.isCompleted) {
      entranceController.forward();
    }
    if (!pulseController.isAnimating) {
      pulseController.repeat();
    }
  }

  void dispose() {
    entranceController.dispose();
    pulseController.dispose();
  }
}
