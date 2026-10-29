import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../provider/sos_active_camera_provider.dart';
import '../widget/audio_waveform_widget.dart';
import 'sos_video_stopped_screen.dart';

class SosActiveCameraScreen extends ConsumerStatefulWidget {
  final String? alertId;

  const SosActiveCameraScreen({super.key, this.alertId});

  @override
  ConsumerState<SosActiveCameraScreen> createState() =>
      _SosActiveCameraScreenState();
}

class _SosActiveCameraScreenState extends ConsumerState<SosActiveCameraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(sosActiveCameraProvider.notifier).setAlertId(widget.alertId);
      }
    });
  }

  void _navigateToStoppedSummary(BuildContext context, {String? videoPath}) {
    if (!context.mounted) return;
    final activeState = ref.read(sosActiveCameraProvider);
    final alertId = activeState.alertId ?? widget.alertId;

    final extra = {
      'video_path': videoPath ?? activeState.recordedVideoPath,
      'alert_id': alertId,
      'duration_seconds': activeState.elapsedSeconds,
    };

    try {
      context.pushReplacement(
        AppRouteNames.sosVideoStoppedScreen,
        extra: extra,
      );
    } catch (_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SosVideoStoppedScreen(
            videoPath: videoPath ?? activeState.recordedVideoPath,
            alertId: alertId,
            durationSeconds: activeState.elapsedSeconds,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sosActiveCameraProvider);
    final notifier = ref.read(sosActiveCameraProvider.notifier);
    final cameraCtrl = notifier.cameraController;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Header Section (Back button, Red Shield, Title) ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        size: 34.sp,
                        color: const Color(0xFF1E232C),
                      ),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Red glowing shield active icon image
                      Image.asset(
                        ImageAssets.sosActive,
                        width: 42.w,
                        height: 42.h,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE52525),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.priority_high_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        'SOS Active',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE52525),
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Help is on the way',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // ── Camera Video Viewport Area ──
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Live Camera Preview
                    if (state.isCameraInitialized &&
                        cameraCtrl != null &&
                        cameraCtrl.value.isInitialized)
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: cameraCtrl.value.previewSize?.height ?? 1,
                            height: cameraCtrl.value.previewSize?.width ?? 1,
                            child: CameraPreview(cameraCtrl),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFF1F242F),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFFE52525),
                                strokeWidth: 2.5,
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                state.errorMessage ??
                                    'Initializing Secure Video Recording...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Top Gradient Scrim for readable badges
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 80.h,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.65),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 2. Top-Left: "Recording Evidence" Red Badge
                    Positioned(
                      top: 14.h,
                      left: 14.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE52525),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFE52525,
                              ).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7.w,
                              height: 7.h,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Recording Evidence',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Top-Right: Video Recording Timer (00:05:23)
                    Positioned(
                      top: 14.h,
                      right: 16.w,
                      child: Text(
                        state.formattedDuration,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              blurRadius: 8,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Audio Recording Section (Waveform, Flash, Flip & Timer) ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF5F5), Colors.white],
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Audio',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E232C),
                        ),
                      ),
                      Text(
                        'Recording',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Center(
                      child: AudioWaveformWidget(isActive: state.isAudioActive),
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // ── Flash Toggle Button (⚡) ──
                  GestureDetector(
                    onTap: notifier.toggleFlash,
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: state.isFlashOn
                            ? const Color(0xFFE52525)
                            : const Color(0xFF6B7280),
                      ),
                      child: Icon(
                        state.isFlashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: Colors.white,
                        size: 19.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // ── Flip Camera Button (🔄) ──
                  GestureDetector(
                    onTap: notifier.switchCamera,
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF6B7280),
                      ),
                      child: Icon(
                        Icons.flip_camera_ios_rounded,
                        color: Colors.white,
                        size: 19.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Audio Duration text
                  Text(
                    state.formattedDuration,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Stop SOS Button ──
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: state.isStopping
                        ? null
                        : () async {
                            final videoPath = await ref
                                .read(sosActiveCameraProvider.notifier)
                                .stopSos();
                            if (context.mounted) {
                              _navigateToStoppedSummary(
                                context,
                                videoPath: videoPath,
                              );
                            }
                          },
                    icon: state.isStopping
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Container(
                            width: 13.w,
                            height: 13.h,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                          ),
                    label: Text(
                      state.isStopping ? 'Stopping SOS...' : 'Stop SOS',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE52525),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 4,
                      shadowColor: const Color(
                        0xFFE52525,
                      ).withValues(alpha: 0.35),
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
