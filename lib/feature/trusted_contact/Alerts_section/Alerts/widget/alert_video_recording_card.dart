import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_share_bottom_sheet.dart';

class AlertVideoRecordingCard extends StatefulWidget {
  const AlertVideoRecordingCard({super.key});

  @override
  State<AlertVideoRecordingCard> createState() =>
      _AlertVideoRecordingCardState();
}

class _AlertVideoRecordingCardState extends State<AlertVideoRecordingCard>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isNativeSupported = true;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 2, seconds: 45);

  Timer? _simulatedTimer;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Safely warm-up video controller in the background without blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmUpVideo();
    });
  }

  Future<void> _warmUpVideo() async {
    try {
      final ctrl = VideoPlayerController.asset(ImageAssets.demoAlertVideo);
      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      _controller = ctrl;
      _controller!.addListener(_videoListener);
      setState(() {
        _isInitialized = true;
        _isNativeSupported = true;
        if (_controller!.value.duration > Duration.zero) {
          _totalDuration = _controller!.value.duration;
        }
      });
    } catch (e) {
      debugPrint('Video player warmup fallback: $e');
      if (mounted) {
        setState(() {
          _isNativeSupported = false;
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || !_isInitialized) return;

    final val = _controller!.value;
    final isPlayingNow = val.isPlaying;
    final pos = val.position;
    final dur = val.duration;

    // Check completion
    if (dur > Duration.zero && pos >= dur) {
      _controller!.pause();
      _controller!.seekTo(Duration.zero);
      _pulseController.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      }
      return;
    }

    if (isPlayingNow != _isPlaying ||
        (pos - _currentPosition).abs() >= const Duration(milliseconds: 250)) {
      if (mounted) {
        setState(() {
          _isPlaying = isPlayingNow;
          _currentPosition = pos;
          if (dur > Duration.zero) {
            _totalDuration = dur;
          }
        });
      }

      if (isPlayingNow && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      } else if (!isPlayingNow && _pulseController.isAnimating) {
        _pulseController.stop();
      }
    }
  }

  Future<void> _togglePlayPause() async {
    // If native player initialized successfully
    if (_isInitialized && _controller != null && _isNativeSupported) {
      try {
        if (_controller!.value.isPlaying) {
          await _controller!.pause();
          _pulseController.stop();
          setState(() {
            _isPlaying = false;
          });
        } else {
          if (_currentPosition >= _totalDuration &&
              _totalDuration > Duration.zero) {
            await _controller!.seekTo(Duration.zero);
          }
          await _controller!.play();
          _pulseController.repeat(reverse: true);
          setState(() {
            _isPlaying = true;
          });
        }
        return;
      } catch (e) {
        debugPrint('Error toggling native video playback: $e');
        _isNativeSupported = false;
      }
    }

    // If native not ready yet, try initializing on demand
    if (!_isInitialized && _isNativeSupported && !_isLoading) {
      setState(() => _isLoading = true);
      try {
        final ctrl = VideoPlayerController.asset(ImageAssets.demoAlertVideo);
        await ctrl.initialize();
        if (!mounted) {
          ctrl.dispose();
          return;
        }
        _controller = ctrl;
        _controller!.addListener(_videoListener);
        _isInitialized = true;
        _isLoading = false;
        if (_controller!.value.duration > Duration.zero) {
          _totalDuration = _controller!.value.duration;
        }
        await _controller!.play();
        _pulseController.repeat(reverse: true);
        setState(() {
          _isPlaying = true;
        });
        return;
      } catch (e) {
        debugPrint('On-demand video init failed: $e');
        _isNativeSupported = false;
        _isLoading = false;
      }
    }

    // Fallback: Safe simulated playback (prevents ANR/crash on emulators/uncompiled builds)
    _toggleSimulatedPlayback();
  }

  void _toggleSimulatedPlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      if (_currentPosition >= _totalDuration) {
        _currentPosition = Duration.zero;
      }
      _pulseController.repeat(reverse: true);

      _simulatedTimer?.cancel();
      _simulatedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || !_isPlaying) {
          timer.cancel();
          return;
        }
        if (_currentPosition >= _totalDuration) {
          setState(() {
            _currentPosition = Duration.zero;
            _isPlaying = false;
          });
          _pulseController.stop();
          timer.cancel();
        } else {
          setState(() {
            _currentPosition += const Duration(seconds: 1);
          });
        }
      });
    } else {
      _pulseController.stop();
      _simulatedTimer?.cancel();
    }
  }

  void _seekToRatio(double ratio) {
    final targetMs = (_totalDuration.inMilliseconds * ratio).toInt();
    final target = Duration(milliseconds: targetMs);

    if (_isInitialized && _controller != null && _isNativeSupported) {
      try {
        _controller!.seekTo(target);
      } catch (_) {}
    }

    setState(() {
      _currentPosition = target;
    });
  }

  void _openFullscreen() {
    if (_isInitialized && _controller != null && _isNativeSupported) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => _FullscreenVideoPlayer(
            controller: _controller!,
            totalDuration: _totalDuration,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video preview active'),
          duration: Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _simulatedTimer?.cancel();
    _pulseController.dispose();
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double _getProgress() {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEAECF0), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.videocam_rounded,
                    color: const Color(0xFF7F56D9),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Video Recording',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Text(
                'Recorded by Emma',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7F56D9),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Video Player Box
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Video Stream or Initial Thumbnail
                  if (_isInitialized &&
                      _controller != null &&
                      _isNativeSupported &&
                      _isPlaying)
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: _controller!.value.size.width > 0
                                ? _controller!.value.size.width
                                : 16,
                            height: _controller!.value.size.height > 0
                                ? _controller!.value.size.height
                                : 9,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      ),
                    )
                  else
                    // Always show the beautiful thumbnail when paused or warming up
                    AnimatedScale(
                      scale: _isPlaying ? 1.03 : 1.0,
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOut,
                      child: Image.asset(
                        ImageAssets.alertVideoThumbnail,
                        fit: BoxFit.cover,
                      ),
                    ),

                  // Top & Bottom Gradient Overlay for readability
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Top-Left Duration / Live REC Badge
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isPlaying) ...[
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                return Container(
                                  width: 7.r,
                                  height: 7.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF04438).withValues(
                                      alpha:
                                          0.4 + (_pulseController.value * 0.6),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 5.w),
                          ],
                          Text(
                            _formatDuration(_totalDuration),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-Right Fullscreen Icon
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: InkWell(
                      onTap: _openFullscreen,
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),

                  // Center Circular Play / Pause Button
                  Center(
                    child: InkWell(
                      onTap: _togglePlayPause,
                      borderRadius: BorderRadius.circular(30.r),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isPlaying ? 0.85 : 0.95,
                        child: Container(
                          width: 52.r,
                          height: 52.r,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    width: 24.r,
                                    height: 24.r,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xFF1D2939),
                                    ),
                                  )
                                : Icon(
                                    _isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: const Color(0xFF1D2939),
                                    size: 30.sp,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Scrub Bar & Timestamps
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 10.h,
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (details) {
                                  final ratio =
                                      (details.localPosition.dx /
                                              constraints.maxWidth)
                                          .clamp(0.0, 1.0);
                                  _seekToRatio(ratio);
                                },
                                onHorizontalDragUpdate: (details) {
                                  final ratio =
                                      (details.localPosition.dx /
                                              constraints.maxWidth)
                                          .clamp(0.0, 1.0);
                                  _seekToRatio(ratio);
                                },
                                child: Container(
                                  height: 20.h,
                                  alignment: Alignment.center,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: SizedBox(
                                      height: 4.h,
                                      width: double.infinity,
                                      child: LinearProgressIndicator(
                                        value: _getProgress(),
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.35),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF7F56D9),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _formatDuration(_totalDuration),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Footer Row: Metadata & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sent by Emma • Time
              Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F3FF),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: const Color(0xFF7F56D9),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sent by emma',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF667085),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Today, 10:32 AM',
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Action Buttons: Download & Share
              Row(
                children: [
                  _buildCircleAction(
                    icon: Icons.download_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Downloading video recording...'),
                          duration: Duration(milliseconds: 1000),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8.w),
                  _buildCircleAction(
                    icon: Icons.share_rounded,
                    onTap: () {
                      AlertShareBottomSheet.show(
                        context,
                        mediaType: 'Video Recording',
                        title: 'Emma',
                        timestamp: 'Today, 10:32 AM',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 34.r,
      height: 34.r,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F3FF),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17.r),
          child: Center(
            child: Icon(icon, color: const Color(0xFF7F56D9), size: 16.sp),
          ),
        ),
      ),
    );
  }
}

/// Fullscreen player page
class _FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final Duration totalDuration;

  const _FullscreenVideoPlayer({
    required this.controller,
    required this.totalDuration,
  });

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
    _startHideTimer();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final position = controller.value.position;
    final duration = controller.value.duration > Duration.zero
        ? controller.value.duration
        : widget.totalDuration;
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Center Video
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio > 0
                      ? controller.value.aspectRatio
                      : 16 / 9,
                  child: VideoPlayer(controller),
                ),
              ),

              // Controls Overlay
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showControls ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Stack(
                    children: [
                      // Top Bar with Back Button & Title
                      Positioned(
                        top: 10.h,
                        left: 14.w,
                        right: 14.w,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Video Recording - Emma',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Center Play / Pause
                      Center(
                        child: InkWell(
                          onTap: () {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                            }
                            _startHideTimer();
                          },
                          borderRadius: BorderRadius.circular(40.r),
                          child: Container(
                            width: 64.r,
                            height: 64.r,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 40.sp,
                              color: const Color(0xFF1D2939),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Progress Slider & Timestamps
                      Positioned(
                        left: 20.w,
                        right: 20.w,
                        bottom: 24.h,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (details) {
                                    final ratio =
                                        (details.localPosition.dx /
                                                constraints.maxWidth)
                                            .clamp(0.0, 1.0);
                                    final targetMs =
                                        (duration.inMilliseconds * ratio)
                                            .toInt();
                                    controller.seekTo(
                                      Duration(milliseconds: targetMs),
                                    );
                                    _startHideTimer();
                                  },
                                  onHorizontalDragUpdate: (details) {
                                    final ratio =
                                        (details.localPosition.dx /
                                                constraints.maxWidth)
                                            .clamp(0.0, 1.0);
                                    final targetMs =
                                        (duration.inMilliseconds * ratio)
                                            .toInt();
                                    controller.seekTo(
                                      Duration(milliseconds: targetMs),
                                    );
                                    _startHideTimer();
                                  },
                                  child: Container(
                                    height: 24.h,
                                    alignment: Alignment.center,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4.r),
                                      child: SizedBox(
                                        height: 5.h,
                                        width: double.infinity,
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.35),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Color(0xFF7F56D9)),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
