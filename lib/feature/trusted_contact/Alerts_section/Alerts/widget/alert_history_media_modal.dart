import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/alert_history_model.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_share_bottom_sheet.dart';
import 'package:iwitnez/router/app_route_names.dart';
import 'package:video_player/video_player.dart';

class AlertHistoryMediaModal extends StatefulWidget {
  final AlertHistoryModel item;

  const AlertHistoryMediaModal({super.key, required this.item});

  static Future<void> show(BuildContext context, AlertHistoryModel item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => AlertHistoryMediaModal(item: item),
    );
  }

  @override
  State<AlertHistoryMediaModal> createState() => _AlertHistoryMediaModalState();
}

class _AlertHistoryMediaModalState extends State<AlertHistoryMediaModal> {
  // Video Controller
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _isVideoLoading = false;

  // Audio Player
  AudioPlayer? _audioPlayer;
  bool _isAudioPlaying = false;
  Duration _audioPosition = Duration.zero;
  Duration audioDuration = const Duration(minutes: 2, seconds: 45);
  StreamSubscription? _audioStateSub;
  StreamSubscription? _audioPosSub;
  StreamSubscription? _audioDurSub;

  @override
  void initState() {
    super.initState();
    _initMedia();
  }

  Future<void> _initMedia() async {
    final item = widget.item;

    if (item.hasVideo && item.videoUrl != null && item.videoUrl!.isNotEmpty) {
      setState(() => _isVideoLoading = true);
      try {
        final uri = Uri.parse(item.videoUrl!);
        _videoController = VideoPlayerController.networkUrl(
          uri,
          httpHeaders: const {'ngrok-skip-browser-warning': 'true'},
        );
        await _videoController!.initialize();
        _videoController!.addListener(_videoListener);
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _isVideoLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error initializing network video: $e');
        if (mounted) {
          setState(() => _isVideoLoading = false);
        }
      }
    } else if (item.hasAudio &&
        item.audioUrl != null &&
        item.audioUrl!.isNotEmpty) {
      try {
        _audioPlayer = AudioPlayer();
        _audioStateSub = _audioPlayer!.onPlayerStateChanged.listen((state) {
          if (!mounted) return;
          setState(() => _isAudioPlaying = state == PlayerState.playing);
        });
        _audioPosSub = _audioPlayer!.onPositionChanged.listen((pos) {
          if (!mounted) return;
          setState(() => _audioPosition = pos);
        });
        _audioDurSub = _audioPlayer!.onDurationChanged.listen((dur) {
          if (!mounted) return;
          setState(() => audioDuration = dur);
        });
      } catch (e) {
        debugPrint('Error initializing audio player: $e');
      }
    }
  }

  void _videoListener() {
    if (!mounted || _videoController == null) return;
    final val = _videoController!.value;
    if (val.isPlaying != _isVideoPlaying) {
      setState(() => _isVideoPlaying = val.isPlaying);
    }
    if (val.position >= val.duration && val.duration > Duration.zero) {
      _videoController!.pause();
      _videoController!.seekTo(Duration.zero);
      setState(() => _isVideoPlaying = false);
    }
  }

  Future<void> _toggleVideoPlay() async {
    if (_videoController == null || !_isVideoInitialized) return;
    if (_videoController!.value.isPlaying) {
      await _videoController!.pause();
    } else {
      await _videoController!.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleAudioPlay() async {
    if (_audioPlayer == null) return;
    final item = widget.item;
    if (_isAudioPlaying) {
      await _audioPlayer!.pause();
    } else {
      if (item.audioUrl != null && item.audioUrl!.isNotEmpty) {
        await _audioPlayer!.play(UrlSource(item.audioUrl!));
      }
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _audioStateSub?.cancel();
    _audioPosSub?.cancel();
    _audioDurSub?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAECF0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Top Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3F2),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFFECDCA)),
                      ),
                      child: Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD92D20),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      item.timestampDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF667085),
                    size: 20.sp,
                  ),
                  splashRadius: 20.r,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Video Player Area
            if (item.hasVideo) ...[
              Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isVideoInitialized && _videoController != null)
                      AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio > 0
                            ? _videoController!.value.aspectRatio
                            : 16 / 9,
                        child: VideoPlayer(_videoController!),
                      )
                    else if (item.thumbnailUrl != null &&
                        item.thumbnailUrl!.isNotEmpty)
                      Image.network(
                        item.thumbnailUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        headers: const {'ngrok-skip-browser-warning': 'true'},
                        errorBuilder: (_, __, ___) => Image.asset(
                          ImageAssets.historyVideoThumbnail,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Image.asset(
                        ImageAssets.historyVideoThumbnail,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),

                    if (_isVideoLoading)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else
                      // Play/Pause Overlay Button
                      GestureDetector(
                        onTap: _toggleVideoPlay,
                        child: Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isVideoPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                      ),

                    // Duration Badge
                    Positioned(
                      bottom: 10.h,
                      left: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          _isVideoInitialized && _videoController != null
                              ? '${_formatDuration(_videoController!.value.position)} / ${_formatDuration(_videoController!.value.duration)}'
                              : item.durationDisplay,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
            ] else if (item.hasAudio) ...[
              // Audio Player Area
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _toggleAudioPlay,
                      borderRadius: BorderRadius.circular(24.r),
                      child: Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7F56D9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isAudioPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Audio Recording',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${_formatDuration(_audioPosition)} / ${item.durationDisplay}',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: const Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
            ],

            // Address & Location Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: const Color(0xFF7F56D9),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recorded Location',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF667085),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.address,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Bottom Action Buttons: Share & View Live Map
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AlertShareBottomSheet.show(
                        context,
                        mediaType: item.hasVideo
                            ? 'Video Recording'
                            : 'Audio Recording',
                        title: item.title,
                        timestamp: item.timestampDisplay,
                        shareUrl: item.videoUrl ?? item.audioUrl,
                      );
                    },
                    icon: Icon(
                      Icons.share_outlined,
                      size: 16.sp,
                      color: const Color(0xFF344054),
                    ),
                    label: Text(
                      'Share Alert',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF344054),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(AppRouteNames.trustedLiveLocationScreen);
                    },
                    icon: Icon(
                      Icons.map_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                    label: Text(
                      'View Location',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor: const Color(0xFF7F56D9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
