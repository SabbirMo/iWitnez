import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/router/app_route_names.dart';

class TrustedContactSuccessScreen extends StatefulWidget {
  final String? contactName;

  const TrustedContactSuccessScreen({super.key, this.contactName});

  @override
  State<TrustedContactSuccessScreen> createState() =>
      _TrustedContactSuccessScreenState();
}

class _TrustedContactSuccessScreenState
    extends State<TrustedContactSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _textController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Orbit rotation animation (continuous slow rotation)
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 2. Entrance scale animation (pops in with overshoot bounce)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );

    // 3. Gentle breathing pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward().then((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });

    // 4. Text entrance (fade in + slide up)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textFadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // 5. Automatically navigate to next page after 5 seconds
    _navigationTimer = Timer(const Duration(seconds: 5), _navigateToNextPage);
  }

  void _navigateToNextPage() {
    if (!mounted) return;
    _navigationTimer?.cancel();
    context.go(AppRouteNames.mainUserHome);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _orbitController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.contactName?.trim().isNotEmpty == true
        ? widget.contactName!.trim()
        : 'Sarah ahmed';

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToNextPage, // Allow tap to skip
        child: SafeArea(
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Animated Shield Badge
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: _ShieldBadgeWidget(
                      orbitController: _orbitController,
                    ),
                  ),
                ),

                SizedBox(height: 36.h),

                // Text details with slide + fade
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: SlideTransition(
                    position: _textSlideAnimation,
                    child: Column(
                      children: [
                        Text(
                          "Trusted Contact Added!",
                          textAlign: TextAlign.center,
                          style: CustomTextStyle.ibold32(AppColors.black)
                              .copyWith(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                        ),
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text(
                            "$displayName has been added to your\ntrusted contacts.",
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.regular14(
                              AppColors.onboardingDesc,
                            ).copyWith(height: 1.45, color: AppColors.gray),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The circular badge with rotating gradient orbit and gradient shield with checkmark
class _ShieldBadgeWidget extends StatelessWidget {
  final AnimationController orbitController;

  const _ShieldBadgeWidget({required this.orbitController});

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6), // Vibrant Purple
      Color(0xFF6366F1), // Indigo
      Color(0xFF0099FF), // Electric Blue
      Color(0xFF00D2FF), // Cyan
    ],
  );

  @override
  Widget build(BuildContext context) {
    final size = 150.w;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            blurRadius: 36,
            spreadRadius: 8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating outer gradient ring with 2 satellite dots
          RotationTransition(
            turns: orbitController,
            child: CustomPaint(
              size: Size(size, size),
              painter: _OrbitRingPainter(
                gradient: _gradient,
                dotColor1: const Color(0xFF8B5CF6),
                dotColor2: const Color(0xFF00D2FF),
              ),
            ),
          ),

          // Central Shield with Checkmark
          SizedBox(
            width: size * 0.52,
            height: size * 0.52,
            child: CustomPaint(
              painter: _ShieldCheckPainter(gradient: _gradient),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the gradient circular ring with 2 orbit nodes (purple and cyan)
class _OrbitRingPainter extends CustomPainter {
  final Gradient gradient;
  final Color dotColor1;
  final Color dotColor2;

  _OrbitRingPainter({
    required this.gradient,
    required this.dotColor1,
    required this.dotColor2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, ringPaint);

    // Left orbit dot (at 180 degrees)
    final dot1Paint = Paint()
      ..style = PaintingStyle.fill
      ..color = dotColor1;
    canvas.drawCircle(Offset(center.dx - radius, center.dy), 5.2, dot1Paint);

    // Right orbit dot (at 0 degrees)
    final dot2Paint = Paint()
      ..style = PaintingStyle.fill
      ..color = dotColor2;
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 5.2, dot2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the gradient shield and checkmark
class _ShieldCheckPainter extends CustomPainter {
  final Gradient gradient;

  _ShieldCheckPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h));

    // Shield outline path
    final shieldPath = Path();
    shieldPath.moveTo(w * 0.50, h * 0.08);

    // Top right shoulder
    shieldPath.cubicTo(
      w * 0.64,
      h * 0.15,
      w * 0.82,
      h * 0.18,
      w * 0.90,
      h * 0.24,
    );

    // Right body curve to bottom apex
    shieldPath.cubicTo(
      w * 0.92,
      h * 0.62,
      w * 0.74,
      h * 0.82,
      w * 0.50,
      h * 0.94,
    );

    // Left body curve from bottom apex
    shieldPath.cubicTo(
      w * 0.26,
      h * 0.82,
      w * 0.08,
      h * 0.62,
      w * 0.10,
      h * 0.24,
    );

    // Top left shoulder back to top point
    shieldPath.cubicTo(
      w * 0.18,
      h * 0.18,
      w * 0.36,
      h * 0.15,
      w * 0.50,
      h * 0.08,
    );
    shieldPath.close();

    canvas.drawPath(shieldPath, paint);

    // Inside checkmark
    final checkPath = Path();
    checkPath.moveTo(w * 0.36, h * 0.51);
    checkPath.lineTo(w * 0.47, h * 0.63);
    checkPath.lineTo(w * 0.67, h * 0.41);

    final checkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
