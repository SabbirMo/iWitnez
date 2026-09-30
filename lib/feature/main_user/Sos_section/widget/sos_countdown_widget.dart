import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'sos_slider_button.dart';

/// ─────────────────────────────────────────────────────────────────────
/// 1. 3D GLOWING SOS BUTTON WITH RIPPLE RINGS
/// ─────────────────────────────────────────────────────────────────────
class SosGlowingButton extends StatefulWidget {
  const SosGlowingButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  State<SosGlowingButton> createState() => _SosGlowingButtonState();
}

class _SosGlowingButtonState extends State<SosGlowingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _haloAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _haloAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const buttonDiameter = 146.0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final haloScale = _haloAnimation.value;

        return RepaintBoundary(
          child: SizedBox(
            width: 290.w,
            height: 290.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Ripple Ring 4 (Outermost) ──
                Container(
                  width: (270 * haloScale).w,
                  height: (270 * haloScale).h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.04),
                  ),
                ),

                // ── Ripple Ring 3 ──
                Container(
                  width: (225 * haloScale).w,
                  height: (225 * haloScale).h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.08),
                  ),
                ),

                // ── Ripple Ring 2 ──
                Container(
                  width: (185 * haloScale).w,
                  height: (185 * haloScale).h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.14),
                  ),
                ),

                // ── Ripple Ring 1 (Closest to button) ──
                Container(
                  width: 162.w,
                  height: 162.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.18),
                  ),
                ),

                // ── 3D Push Button ──
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                      width: buttonDiameter.w,
                      height: buttonDiameter.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Outer rim bevel
                        color: const Color(0xFFBF1320),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withValues(alpha: 0.45),
                            blurRadius: 28,
                            spreadRadius: 3,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(7.w),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFF4855),
                              Color(0xFFE5202F),
                              Color(0xFFBD121F),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 34.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.8,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'TAP TO SEND',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.95),
                                letterSpacing: 1.4,
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
      },
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// 2. HEADER INFO SECTION
/// ─────────────────────────────────────────────────────────────────────
class SosHeaderSection extends StatelessWidget {
  const SosHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Help is on the way!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E232C),
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 36.w),
          child: Text(
            'Your trusted contacts will be notified with your live location',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// 3. TIMER & SLIDER CARD
/// ─────────────────────────────────────────────────────────────────────
class SosTimerCard extends StatelessWidget {
  const SosTimerCard({
    super.key,
    required this.formattedTime,
    required this.onSlideComplete,
  });

  final String formattedTime;
  final VoidCallback onSlideComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFFFECEE),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Red Alarm Clock Icon ──
          Icon(
            Icons.alarm_rounded,
            color: const Color(0xFFDC2626),
            size: 26.sp,
          ),
          SizedBox(height: 8.h),

          // ── Alert will be sent in ──
          Text(
            'Alert will be sent in',
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563),
            ),
          ),
          SizedBox(height: 6.h),

          // ── Large Countdown Timer ──
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 44.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFDC2626),
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 22.h),

          // ── Slide to Send SOS ──
          SosSliderButton(
            onSlideComplete: onSlideComplete,
          ),
        ],
      ),
    );
  }
}

