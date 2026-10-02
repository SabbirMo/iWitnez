import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_share_bottom_sheet.dart';

class AlertAudioRecordingCard extends StatefulWidget {
  const AlertAudioRecordingCard({super.key});

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
  bool _isNativeAudioSupported = true;
  bool _isAudioReady = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 2, seconds: 45);

  Timer? _simulatedTimer;
  late final AnimationController _waveAnimController;

  // 28 waveform bars with realistic voice frequency profile
  static const List<double> _baseWaveHeights = [
    12, 18, 24, 32, 26, 38, 30, 42, 28, 20, 36, 44,
    32, 24, 18, 26, 34, 40, 30, 22, 32, 26, 20, 16,
    24, 18, 14, 10
  ];

  @override
  void initState() {
    super.initState();
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // Warm-up audio player safely in the background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmUpAudioPlayer();
    });
  }

  Future<void> _warmUpAudioPlayer() async {
    try {
      final player = AudioPlayer();
      _playerStateSubscription =
          player.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        final playing = state == PlayerState.playing;
        setState(() {
          _isPlaying = playing;
        });

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

      _positionSubscription = player.onPositionChanged.listen((pos) {
        if (!mounted) return;
        setState(() {
          _currentPosition = pos;
        });
      });

      _durationSubscription = player.onDurationChanged.listen((dur) {
        if (!mounted) return;
        if (dur > Duration.zero) {
          setState(() {
            _totalDuration = dur;
          });
        }
      });

      _playerCompleteSubscription = player.onPlayerComplete.listen((_) {
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
        _waveAnimController.reset();
      });

      await player.setSource(AssetSource('audio/demo_voice.mp3'));
      if (!mounted) {
        player.dispose();
        return;
      }
      _audioPlayer = player;
      _isAudioReady = true;
      _isNativeAudioSupported = true;
    } catch (e) {
      debugPrint('Audio player warmup fallback: $e');
      if (mounted) {
        setState(() {
          _isNativeAudioSupported = false;
        });
      }
    }
  }

  Future<void> _toggleAudioPlayPause() async {
    if (_isAudioReady && _audioPlayer != null && _isNativeAudioSupported) {
      try {
        if (_isPlaying) {
          await _audioPlayer!.pause();
          _waveAnimController.stop();
          setState(() {
            _isPlaying = false;
          });
        } else {
          if (_currentPosition >= _totalDuration &&
              _totalDuration > Duration.zero) {
            await _audioPlayer!.seek(Duration.zero);
          }
          await _audioPlayer!.play(AssetSource('audio/demo_voice.mp3'));
          _waveAnimController.repeat(reverse: true);
          setState(() {
            _isPlaying = true;
          });
        }
        return;
      } catch (e) {
        debugPrint('Error toggling native audio: $e');
        _isNativeAudioSupported = false;
      }
    }

    // Fallback: Safe simulated playback (prevents ANR/crash)
    _toggleSimulatedAudio();
  }

  void _toggleSimulatedAudio() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      if (_currentPosition >= _totalDuration) {
        _currentPosition = Duration.zero;
      }
      _waveAnimController.repeat(reverse: true);

      _simulatedTimer?.cancel();
      _simulatedTimer =
          Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (!mounted || !_isPlaying) {
          timer.cancel();
          return;
        }
        if (_currentPosition >= _totalDuration) {
          setState(() {
            _currentPosition = Duration.zero;
            _isPlaying = false;
          });
          _waveAnimController.reset();
          timer.cancel();
        } else {
          setState(() {
            _currentPosition += const Duration(milliseconds: 200);
          });
        }
      });
    } else {
      _waveAnimController.stop();
      _simulatedTimer?.cancel();
    }
  }

  void _seekToRatio(double ratio) async {
    if (_totalDuration > Duration.zero) {
      final targetMs = (_totalDuration.inMilliseconds * ratio).toInt();
      final target = Duration(milliseconds: targetMs);

      if (_isAudioReady && _audioPlayer != null && _isNativeAudioSupported) {
        try {
          await _audioPlayer!.seek(target);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _currentPosition = target;
        });
      }
    }
  }

  @override
  void dispose() {
    _simulatedTimer?.cancel();
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
    final ratio = _totalDuration.inMilliseconds > 0
        ? (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    final activeBarCount = (ratio * _baseWaveHeights.length).floor();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFEAECF0),
          width: 1.w,
        ),
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
                    'Audio Recording',
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

          // Audio Waveform Player Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFF2F4F7),
                width: 1.w,
              ),
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
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color:
                            _isPlaying ? Colors.white : const Color(0xFF444CE7),
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
                              final seekRatio = (details.localPosition.dx /
                                      constraints.maxWidth)
                                  .clamp(0.0, 1.0);
                              _seekToRatio(seekRatio);
                            },
                            onHorizontalDragUpdate: (details) {
                              final seekRatio = (details.localPosition.dx /
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
                                    children: List.generate(
                                        _baseWaveHeights.length, (index) {
                                      final isPlayed = index <= activeBarCount;
                                      final isCurrentBar =
                                          index == activeBarCount && _isPlaying;

                                      // Calculate dynamic bar height
                                      double height = _baseWaveHeights[index];
                                      if (isCurrentBar) {
                                        // Active pulse
                                        height = (height + (wave * 12))
                                            .clamp(8.0, 44.0);
                                      } else if (isPlayed &&
                                          _isPlaying &&
                                          index % 2 == 0) {
                                        // Subtle pulse on active played bars
                                        height = (height + ((1 - wave) * 4))
                                            .clamp(8.0, 44.0);
                                      }

                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 100),
                                        width: 3.w,
                                        height: height.h,
                                        decoration: BoxDecoration(
                                          color: isPlayed
                                              ? const Color(0xFF7F56D9)
                                              : const Color(0xFFD0D5DD),
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                          boxShadow: isCurrentBar
                                              ? [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF7F56D9)
                                                            .withValues(
                                                                alpha: 0.5),
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
                            _formatDuration(_totalDuration),
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
                          content: Text('Downloading audio recording...'),
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
                        mediaType: 'Audio Recording',
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
