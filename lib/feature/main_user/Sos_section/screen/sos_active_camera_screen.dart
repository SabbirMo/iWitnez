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

class SosActiveCameraScreen extends ConsumerWidget {
  const SosActiveCameraScreen({super.key});

  void _navigateToStoppedSummary(BuildContext context) {
    if (!context.mounted) return;
    try {
      context.push(AppRouteNames.sosVideoStoppedScreen);
    } catch (_) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SosVideoStoppedScreen()));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            SizedBox(height: 6.h),

            // ── Camera Video Viewport (NO PICTURE - REAL LIVE CAMERA FEED) ──
            Expanded(
              child: Container(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1. Real Live Camera Stream
                    if (state.isCameraInitialized &&
                        cameraCtrl != null &&
                        cameraCtrl.value.isInitialized)
                      ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: cameraCtrl.value.previewSize?.height ?? 720.0,
                              height: cameraCtrl.value.previewSize?.width ?? 1280.0,
                              child: CameraPreview(cameraCtrl),
                            ),
                          ),
                        ),
                      )
                    else
                      // Dark camera viewfinder while initializing (NO PICTURE)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 68.w,
                              height: 68.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              child: Center(
                                child: state.errorMessage == null
                                    ? SizedBox(
                                        width: 28.w,
                                        height: 28.h,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Color(0xFFE52525),
                                        ),
                                      )
                                    : Icon(
                                        Icons.videocam_off_outlined,
                                        color: Colors.white70,
                                        size: 32.sp,
                                      ),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              state.errorMessage ?? 'Opening Video Camera...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (state.errorMessage != null) ...[
                              SizedBox(height: 14.h),
                              ElevatedButton.icon(
                                onPressed: notifier.initCameraAndRecording,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Retry Camera',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE52525),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                    // 2. Top-Left: REC live indicator badge
                    Positioned(
                      top: 14.h,
                      left: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'REC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Top-Right: Video Recording Timer
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFFFFF5F5), Colors.white],
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
                    onPressed: () async {
                      await ref
                          .read(sosActiveCameraProvider.notifier)
                          .stopSos();
                      if (context.mounted) {
                        _navigateToStoppedSummary(context);
                      }
                    },
                    icon: Container(
                      width: 13.w,
                      height: 13.h,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    label: Text(
                      'Stop SOS',
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
