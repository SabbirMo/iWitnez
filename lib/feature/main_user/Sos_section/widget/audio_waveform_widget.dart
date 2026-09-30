import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioWaveformWidget extends StatefulWidget {
  const AudioWaveformWidget({
    super.key,
    this.isActive = true,
  });

  final bool isActive;

  @override
  State<AudioWaveformWidget> createState() => _AudioWaveformWidgetState();
}

class _AudioWaveformWidgetState extends State<AudioWaveformWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<double> _baseHeights = [
    6, 10, 16, 24, 32, 26, 18, 10, 8, 14, 22, 34, 28, 18, 12, 8, 14, 26, 30, 20, 10, 6,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_baseHeights.length, (index) {
            final baseH = _baseHeights[index];
            // Compute dynamic fluctuating height
            final wave = math.sin((progress * 2 * math.pi) + (index * 0.45));
            final dynamicH = widget.isActive
                ? (baseH * 0.55 + (baseH * 0.45 * (wave.abs()))).clamp(4.0, 36.0)
                : 4.0;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              width: 3.2.w,
              height: dynamicH.h,
              decoration: BoxDecoration(
                color: widget.isActive
                    ? const Color(0xFFE52525)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        );
      },
    );
  }
}
