import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/utils/media_download_helper.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/active_alert_model.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_share_bottom_sheet.dart';

class AlertAudioRecordingCard extends StatefulWidget {
  final AlertAudioRecordingModel audio;

  const AlertAudioRecordingCard({super.key, required this.audio});

  @override
  State<AlertAudioRecordingCard> createState() =>
      _AlertAudioRecordingCardState();
}

class _AlertAudioRecordingCardState extends State<AlertAudioRecordingCard>
    with SingleTickerProviderStateMixin {
  AudioPlayer? _audioPlayer;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerCompleteSubscription;

  bool _isPlaying = false;
  bool _isLoading = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  late final AnimationController _waveAnimController;

  static const List<double> _baseWaveHeights = [
    12, 18, 24, 32, 26, 38, 30, 42, 28, 20, 36, 44, 32, 24,
    18, 26, 34, 40, 30, 22, 32, 26, 20, 16, 24, 18, 14, 10,
  ];

  List<double> get _waveHeights {
    final peaks = widget.audio.waveformPeaks;
    if (peaks.isNotEmpty) {
      final list = <double>[];
      for (int i = 0; i < 28; i++) {
        final peakIndex = (i * peaks.length / 28).floor().clamp(
          0,
          peaks.length - 1,
        );
        final val = (peaks[peakIndex] * 40.0).clamp(8.0, 44.0);
        list.add(val);
      }
      return list;
    }
    return _baseWaveHeights;
  }

  @override
  void initState() {
    super.initState();
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    if (widget.audio.durationSeconds > 0) {
      _totalDuration = Duration(seconds: widget.audio.durationSeconds);
    }
  }

  @override
  void didUpdateWidget(covariant AlertAudioRecordingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio.fileUrl != widget.audio.fileUrl) {
      _stopAndResetPlayer();
    }
    if (widget.audio.durationSeconds > 0) {
      _totalDuration = Duration(seconds: widget.audio.durationSeconds);
    }
  }

  void _initPlayerListeners(AudioPlayer player) {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      final playing = state == PlayerState.playing;
      setState(() => _isPlaying = playing);

      if (playing) {
        if (!_waveAnimController.isAnimating) {
          _waveAnimController.repeat(reverse: true);
        }
      } else {
        if (_waveAnimController.isAnimating) {
          _waveAnimController.stop();
        }
      }
    });

    _positionSubscription?.cancel();
    _positionSubscription = player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      setState(() => _currentPosition = pos);
    });

    _durationSubscription?.cancel();
    _durationSubscription = player.onDurationChanged.listen((dur) {
      if (!mounted) return;
      if (dur > Duration.zero) {
        setState(() => _totalDuration = dur);
      }
    });

    _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
      _waveAnimController.reset();
    });
  }

  void _stopAndResetPlayer() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _waveAnimController.reset();
  }

  Future<void> _toggleAudioPlayPause() async {
    final url = widget.audio.fileUrl;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio file is not available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isPlaying) {
      await _audioPlayer?.pause();
      return;
    }

    if (_audioPlayer == null) {
      final player = AudioPlayer();
      _initPlayerListeners(player);
      _audioPlayer = player;
    }

    setState(() => _isLoading = true);
    try {
      if (_currentPosition >= _totalDuration && _totalDuration > Duration.zero) {
        await _audioPlayer!.seek(Duration.zero);
      }
      await _audioPlayer!.play(UrlSource(url));
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to play audio recording.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _seekToRatio(double ratio) async {
    if (_totalDuration > Duration.zero && _audioPlayer != null) {
      final targetMs = (_totalDuration.inMilliseconds * ratio).toInt();
      final target = Duration(milliseconds: targetMs);
      try {
        await _audioPlayer!.seek(target);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _currentPosition = target;
        });
      }
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _audioPlayer?.dispose();
    _waveAnimController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final heights = _waveHeights;
    final ratio = _totalDuration.inMilliseconds > 0
        ? (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds)
              .clamp(0.0, 1.0)
        : 0.0;

    final activeBarCount = (ratio * heights.length).floor();

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
                    Icons.equalizer_rounded,
                    color: const Color(0xFF7F56D9),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    widget.audio.title.isNotEmpty
                        ? widget.audio.title
                        : 'Audio Recording',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Text(
                widget.audio.recordedBy.isNotEmpty
                    ? widget.audio.recordedBy
                    : 'Recorded by Emma',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7F56D9),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Audio Waveform Player Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFF2F4F7), width: 1.w),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Play / Pause Button
                InkWell(
                  onTap: _toggleAudioPlayPause,
                  borderRadius: BorderRadius.circular(24.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: _isPlaying
                          ? const Color(0xFF7F56D9)
                          : const Color(0xFFE0EAFF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isPlaying
                                  ? const Color(0xFF7F56D9)
                                  : const Color(0xFF2E90FA))
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF7F56D9),
                              ),
                            )
                          : Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: _isPlaying
                                  ? Colors.white
                                  : const Color(0xFF444CE7),
                              size: 24.sp,
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // Animated Waveform & Timestamps
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Audio Waveform Bars with Interactive Seek
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (details) {
                              final seekRatio =
                                  (details.localPosition.dx /
                                          constraints.maxWidth)
                                      .clamp(0.0, 1.0);
                              _seekToRatio(seekRatio);
                            },
                            onHorizontalDragUpdate: (details) {
                              final seekRatio =
                                  (details.localPosition.dx /
                                          constraints.maxWidth)
                                      .clamp(0.0, 1.0);
                              _seekToRatio(seekRatio);
                            },
                            child: SizedBox(
                              height: 44.h,
                              child: AnimatedBuilder(
                                animation: _waveAnimController,
                                builder: (context, _) {
                                  final wave = _waveAnimController.value;

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: List.generate(heights.length, (
                                      index,
                                    ) {
                                      final isPlayed = index <= activeBarCount;
                                      final isCurrentBar =
                                          index == activeBarCount && _isPlaying;

                                      double height = heights[index];
                                      if (isCurrentBar) {
                                        height = (height + (wave * 12)).clamp(
                                          8.0,
                                          44.0,
                                        );
                                      } else if (isPlayed &&
                                          _isPlaying &&
                                          index % 2 == 0) {
                                        height = (height + ((1 - wave) * 4))
                                            .clamp(8.0, 44.0);
                                      }

                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 100,
                                        ),
                                        width: 3.w,
                                        height: height.h,
                                        decoration: BoxDecoration(
                                          color: isPlayed
                                              ? const Color(0xFF7F56D9)
                                              : const Color(0xFFD0D5DD),
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                          boxShadow: isCurrentBar
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF7F56D9,
                                                    ).withValues(alpha: 0.5),
                                                    blurRadius: 4,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 4.h),

                      // Timestamps: Live Elapsed Time & Total Duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_currentPosition),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF7F56D9),
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _totalDuration > Duration.zero
                                ? _formatDuration(_totalDuration)
                                : (widget.audio.durationDisplay.isNotEmpty
                                    ? widget.audio.durationDisplay
                                    : '00:00'),
                            style: GoogleFonts.inter(
                              color: const Color(0xFF667085),
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
                        widget.audio.sentByDisplay.isNotEmpty
                            ? widget.audio.sentByDisplay
                            : 'Sent by emma',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF667085),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.audio.sentAtDisplay.isNotEmpty
                            ? widget.audio.sentAtDisplay
                            : 'Today, 10:32 AM',
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
                  if (widget.audio.canDownload) ...[
                    _buildCircleAction(
                      icon: Icons.download_rounded,
                      onTap: () {
                        MediaDownloadHelper.downloadMedia(
                          context: context,
                          url: widget.audio.fileUrl,
                          mediaType: 'Audio Recording',
                          preferredFileName:
                              'emergency_audio_${DateTime.now().millisecondsSinceEpoch}',
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                  ],
                  if (widget.audio.canShare)
                    _buildCircleAction(
                      icon: Icons.share_rounded,
                      onTap: () {
                        AlertShareBottomSheet.show(
                          context,
                          mediaType: 'Audio Recording',
                          title: widget.audio.recordedBy.isNotEmpty
                              ? widget.audio.recordedBy
                              : 'Emma',
                          timestamp: widget.audio.sentAtDisplay.isNotEmpty
                              ? widget.audio.sentAtDisplay
                              : 'Today, 10:32 AM',
                          shareUrl: widget.audio.fileUrl,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F3FF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE9D7FE), width: 1.w),
        ),
        child: Center(
          child: Icon(icon, color: const Color(0xFF7F56D9), size: 18.sp),
        ),
      ),
    );
  }
}
