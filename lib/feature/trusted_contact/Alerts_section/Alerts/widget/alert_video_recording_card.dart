import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/utils/media_download_helper.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/active_alert_model.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_share_bottom_sheet.dart';

class AlertVideoRecordingCard extends StatefulWidget {
  final AlertVideoRecordingModel video;

  const AlertVideoRecordingCard({super.key, required this.video});

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

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.video.durationSeconds > 0) {
      _totalDuration = Duration(seconds: widget.video.durationSeconds);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideo();
    });
  }

  @override
  void didUpdateWidget(covariant AlertVideoRecordingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.fileUrl != widget.video.fileUrl) {
      _controller?.removeListener(_videoListener);
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final url = widget.video.fileUrl;
    if (url.isEmpty ||
        (!url.startsWith('http://') && !url.startsWith('https://'))) {
      return;
    }

    try {
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: const {'ngrok-skip-browser-warning': 'true'},
      );
      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      _controller?.dispose();
      _controller = ctrl;
      _controller!.addListener(_videoListener);
      setState(() {
        _isInitialized = true;
        if (_controller!.value.duration > Duration.zero) {
          _totalDuration = _controller!.value.duration;
        } else if (widget.video.durationSeconds > 0) {
          _totalDuration = Duration(seconds: widget.video.durationSeconds);
        }
      });
    } catch (e) {
      debugPrint('Error initializing active alert video: $e');
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || !_isInitialized) return;

    final val = _controller!.value;
    final isPlayingNow = val.isPlaying;
    final pos = val.position;
    final dur = val.duration;

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
    if (_controller == null || !_isInitialized) {
      setState(() => _isLoading = true);
      await _initVideo();
      setState(() => _isLoading = false);
    }

    if (_controller != null && _isInitialized) {
      if (_controller!.value.isPlaying) {
        await _controller!.pause();
        _pulseController.stop();
        if (mounted) setState(() => _isPlaying = false);
      } else {
        if (_currentPosition >= _totalDuration &&
            _totalDuration > Duration.zero) {
          await _controller!.seekTo(Duration.zero);
        }
        await _controller!.play();
        _pulseController.repeat(reverse: true);
        if (mounted) setState(() => _isPlaying = true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video recording is currently unavailable.'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _seekToRatio(double ratio) {
    if (_totalDuration > Duration.zero &&
        _controller != null &&
        _isInitialized) {
      final targetMs = (_totalDuration.inMilliseconds * ratio).toInt();
      final target = Duration(milliseconds: targetMs);
      _controller!.seekTo(target);
      setState(() {
        _currentPosition = target;
      });
    }
  }

  void _openFullscreen() {
    if (_isInitialized && _controller != null) {
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

  Widget _buildThumbnail() {
    final thumb = widget.video.thumbnailUrl;
    if (thumb != null && thumb.isNotEmpty) {
      if (thumb.startsWith('http://') || thumb.startsWith('https://')) {
        return Image.network(
          thumb,
          fit: BoxFit.cover,
          headers: const {'ngrok-skip-browser-warning': 'true'},
          errorBuilder: (_, __, ___) =>
              Image.asset(ImageAssets.alertVideoThumbnail, fit: BoxFit.cover),
        );
      } else if (thumb.startsWith('assets/')) {
        return Image.asset(thumb, fit: BoxFit.cover);
      }
    }
    return Image.asset(ImageAssets.alertVideoThumbnail, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFEAECF0),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
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
                    widget.video.title.isNotEmpty
                        ? widget.video.title
                        : 'Video Recording',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Text(
                widget.video.recordedBy.isNotEmpty
                    ? widget.video.recordedBy
                    : 'Recorded by Emma',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF9E77ED)
                      : const Color(0xFF7F56D9),
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
                  // Video Stream when playing, or Thumbnail from API
                  if (_isInitialized && _controller != null && _isPlaying)
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
                    _buildThumbnail(),

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
                            (_isInitialized && _totalDuration > Duration.zero)
                                ? _formatDuration(_totalDuration)
                                : (widget.video.durationDisplay.isNotEmpty
                                      ? widget.video.durationDisplay
                                      : _formatDuration(_totalDuration)),
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

                  // Top-Right Fullscreen Expand Icon
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: InkWell(
                      onTap: _openFullscreen,
                      borderRadius: BorderRadius.circular(6.r),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
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

                  // Center Play/Pause Floating Button
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _togglePlayPause,
                        borderRadius: BorderRadius.circular(32.r),
                        child: Container(
                          width: 54.r,
                          height: 54.r,
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
                      color: isDark
                          ? const Color(0xFF261D42)
                          : const Color(0xFFF4F3FF),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: isDark
                          ? const Color(0xFF9E77ED)
                          : const Color(0xFF7F56D9),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.sentByDisplay.isNotEmpty
                            ? widget.video.sentByDisplay
                            : 'Sent by emma',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? const Color(0xFF98A2B3)
                              : const Color(0xFF667085),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.video.sentAtDisplay.isNotEmpty
                            ? widget.video.sentAtDisplay
                            : 'Today, 10:32 AM',
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Action Buttons: Download & Share
              Row(
                children: [
                  if (widget.video.canDownload) ...[
                    _buildCircleAction(
                      icon: Icons.download_rounded,
                      isDark: isDark,
                      onTap: () {
                        MediaDownloadHelper.downloadMedia(
                          context: context,
                          url: widget.video.fileUrl,
                          mediaType: 'Video Recording',
                          preferredFileName:
                              'emergency_video_${DateTime.now().millisecondsSinceEpoch}',
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                  ],
                  if (widget.video.canShare)
                    _buildCircleAction(
                      icon: Icons.share_rounded,
                      isDark: isDark,
                      onTap: () {
                        AlertShareBottomSheet.show(
                          context,
                          mediaType: 'Video Recording',
                          title: widget.video.recordedBy.isNotEmpty
                              ? widget.video.recordedBy
                              : 'Emma',
                          timestamp: widget.video.sentAtDisplay.isNotEmpty
                              ? widget.video.sentAtDisplay
                              : 'Today, 10:32 AM',
                          shareUrl: widget.video.fileUrl,
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
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 34.r,
      height: 34.r,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF261D42) : const Color(0xFFF4F3FF),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17.r),
          child: Center(
            child: Icon(
              icon,
              color: isDark ? const Color(0xFFD6BBFB) : const Color(0xFF7F56D9),
              size: 16.sp,
            ),
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
                              'Video Recording',
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
