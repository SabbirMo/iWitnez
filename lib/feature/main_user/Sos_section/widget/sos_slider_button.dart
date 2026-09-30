import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SosSliderButton extends StatefulWidget {
  const SosSliderButton({
    super.key,
    required this.onSlideComplete,
    this.text = 'Slide to Send SOS',
    this.enabled = true,
  });

  final VoidCallback onSlideComplete;
  final String text;
  final bool enabled;

  @override
  State<SosSliderButton> createState() => _SosSliderButtonState();
}

class _SosSliderButtonState extends State<SosSliderButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;

  double _dragProgress = 0.0; // 0.0 to 1.0
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (!widget.enabled || _isCompleted || maxDrag <= 0) return;

    setState(() {
      final newOffset = (_dragProgress * maxDrag + details.delta.dx)
          .clamp(0.0, maxDrag);
      _dragProgress = newOffset / maxDrag;
    });

    if (_dragProgress >= 0.85 && !_isCompleted) {
      _triggerSuccess();
    }
  }

  void _onDragEnd(DragEndDetails details, double maxDrag) {
    if (!widget.enabled || _isCompleted) return;

    if (_dragProgress >= 0.65) {
      _triggerSuccess();
    } else {
      _animateBack();
    }
  }

  void _triggerSuccess() {
    if (_isCompleted) return;
    setState(() {
      _isCompleted = true;
      _dragProgress = 1.0;
    });
    widget.onSlideComplete();
  }

  void _animateBack() {
    final startVal = _dragProgress;
    _resetAnimation = Tween<double>(begin: startVal, end: 0.0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    )..addListener(() {
        if (mounted) {
          setState(() {
            _dragProgress = _resetAnimation.value;
          });
        }
      });

    _resetController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    const trackHeight = 52.0;
    const knobPadding = 4.0;
    const knobSize = trackHeight - (knobPadding * 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final maxDrag = totalWidth - knobSize - (knobPadding * 2);

        final knobOffset = _dragProgress * (maxDrag > 0 ? maxDrag : 0.0);
        final textOpacity = (1.0 - _dragProgress * 1.6).clamp(0.0, 1.0);

        return Container(
          width: totalWidth,
          height: trackHeight.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFFA6AF),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // ── Center text label ──
              Center(
                child: Opacity(
                  opacity: textOpacity,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // ── Sliding Knob ──
              Positioned(
                left: knobPadding + knobOffset,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _onDragUpdate(details, maxDrag),
                  onHorizontalDragEnd: (details) =>
                      _onDragEnd(details, maxDrag),
                  child: Container(
                    width: knobSize.w,
                    height: knobSize.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        color: const Color(0xFFFA5262),
                        size: 22.sp,
                      ),
                    ),
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
