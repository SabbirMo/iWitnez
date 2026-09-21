import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AudioWaveformWidget extends StatefulWidget {
  const AudioWaveformWidget({
    super.key,
    this.isReversed = false,
    this.barCount = 5,
    this.color = const Color(0xFF6366F1),
  });

  final bool isReversed;
  final int barCount;
  final Color color;

  @override
  State<AudioWaveformWidget> createState() => _AudioWaveformWidgetState();
}

class _AudioWaveformWidgetState extends State<AudioWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<double> _baseHeights = [14.0, 26.0, 42.0, 30.0, 18.0];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heights = widget.isReversed
        ? _baseHeights.reversed.toList()
        : _baseHeights;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(heights.length, (index) {
            final base = heights[index];
            final factor = sin((_controller.value * 2 * pi) + (index * 0.7));
            final currentHeight = (base + (factor * 6)).clamp(8.0, 50.0).h;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: 3.5.w,
              height: currentHeight,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.65 + (0.35 * factor.abs())),
                borderRadius: BorderRadius.circular(4.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
