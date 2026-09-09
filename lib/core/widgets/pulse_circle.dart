import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';

/// Signal / Pulse wave circle behind mainLogo (ultra smooth easing & fade)
class PulseCircle extends StatelessWidget {
  const PulseCircle({
    super.key,
    required this.animation,
    required this.delay,
    this.baseSize,
    this.expandSize,
    this.color,
  });

  final Animation<double> animation;
  final double delay;
  final double? baseSize;
  final double? expandSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveBaseSize = baseSize ?? 140.w;
    final effectiveExpandSize = expandSize ?? 135.w;
    final primaryColor = color ?? AppColors.primaryPurple;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = (animation.value + delay) % 1.0;
        final curved = Curves.easeOutCubic.transform(progress);
        final size = effectiveBaseSize + (curved * effectiveExpandSize);

        // Smooth fade-in as it emerges, then gradual smooth fade-out
        double baseOpacity;
        if (progress < 0.18) {
          baseOpacity = progress / 0.18;
        } else {
          final fadeProgress = (progress - 0.18) / 0.82;
          baseOpacity = math.pow(1.0 - fadeProgress, 1.8).toDouble();
        }

        final opacity = (baseOpacity * 0.55).clamp(0.0, 1.0);
        final borderWidth = (1.6 - progress * 0.6).clamp(0.9, 1.6).w;

        return OverflowBox(
          minWidth: 0,
          minHeight: 0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withValues(alpha: opacity),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: opacity * 0.22),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  primaryColor.withValues(alpha: opacity * 0.15),
                  AppColors.primaryBlue.withValues(alpha: opacity * 0.04),
                  Colors.transparent,
                ],
                stops: const [0.55, 0.85, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}
