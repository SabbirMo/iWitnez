import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/widgets/pulse_circle.dart';

/// =====================================================================
/// ANIMATED SOS BUTTON  (pulse animation identical to splash screen)
/// =====================================================================
class AnimatedSosButton extends StatefulWidget {
  const AnimatedSosButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<AnimatedSosButton> createState() => _AnimatedSosButtonState();
}

class _AnimatedSosButtonState extends State<AnimatedSosButton>
    with SingleTickerProviderStateMixin {
  // Single controller — same 3 000 ms loop used by the splash screen.
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const imageSize = 124.21;
    // Pulse rings expand out to ~2× the image diameter, same ratio as splash.
    final pulseBase = imageSize.w;
    final pulseExpand = imageSize.w * 0.95;

    return RepaintBoundary(
      child: SizedBox(
        width: (imageSize * 2.1).w,
        height: (imageSize * 2.1).h,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ── Three staggered PulseCircles — identical to splash screen ──
            PulseCircle(
              animation: _pulseController,
              delay: 0.0,
              baseSize: pulseBase,
              expandSize: pulseExpand,
              color: AppColors.homeSosHaloStroke,
            ),
            PulseCircle(
              animation: _pulseController,
              delay: 0.33,
              baseSize: pulseBase,
              expandSize: pulseExpand,
              color: AppColors.homeSosHaloStroke,
            ),
            PulseCircle(
              animation: _pulseController,
              delay: 0.66,
              baseSize: pulseBase,
              expandSize: pulseExpand,
              color: AppColors.homeSosHaloStroke,
            ),

            // ── SOS image (tappable) ──
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                splashFactory: InkSparkle.splashFactory,
                splashColor: Colors.white.withValues(alpha: 0.18),
                highlightColor: Colors.transparent,
                borderRadius: BorderRadius.circular(9999.r),
                child: SizedBox(
                  width: imageSize.w,
                  height: imageSize.h,
                  child: Image.asset(
                    ImageAssets.sosAlert,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: imageSize.w,
                      height: imageSize.h,
                      decoration: ShapeDecoration(
                        gradient: SweepGradient(
                          colors: [
                            AppColors.homeSosStart,
                            AppColors.homeSosMid,
                            AppColors.homeSosEnd,
                            AppColors.homeSosMid,
                            AppColors.homeSosStart,
                          ],
                        ),
                        shape: const OvalBorder(),
                        shadows: [
                          BoxShadow(
                            color: AppColors.homeSosStart.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
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
}
