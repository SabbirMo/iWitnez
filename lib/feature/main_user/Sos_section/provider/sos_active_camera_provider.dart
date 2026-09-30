import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/sos_active_camera_state.dart';

class SosActiveCameraNotifier extends Notifier<SosActiveCameraState> {
  Timer? _timer;
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0;

  CameraController? get cameraController => _cameraController;

  @override
  SosActiveCameraState build() {
    ref.onDispose(() {
      _stopAndDispose();
    });

    Future.microtask(() {
      if (ref.mounted) {
        initCameraAndRecording();
      }
    });

    return const SosActiveCameraState(
      elapsedSeconds: 0,
      isRecording: true,
      isCameraInitialized: false,
    );
  }

  Future<void> initCameraAndRecording() async {
    try {
      // 1. Request camera and microphone permissions
      await [
        Permission.camera,
        Permission.microphone,
      ].request();

      if (!ref.mounted) return;

      // 2. Discover cameras
      _availableCameras = await availableCameras();
      if (!ref.mounted) return;

      if (_availableCameras.isEmpty) {
        state = state.copyWith(
          errorMessage: 'No camera device detected.',
        );
        _startTimer();
        return;
      }

      // Default to back camera
      _currentCameraIndex = _availableCameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_currentCameraIndex == -1) _currentCameraIndex = 0;

      await _initializeCurrentCamera();
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (!ref.mounted) return;
      state = state.copyWith(
        isCameraInitialized: false,
        errorMessage: 'Unable to start camera: $e',
      );
      _startTimer();
    }
  }

  Future<void> _initializeCurrentCamera() async {
    if (_availableCameras.isEmpty) return;

    try {
      await _cameraController?.dispose();
      if (!ref.mounted) return;

      final desc = _availableCameras[_currentCameraIndex];
      _cameraController = CameraController(
        desc,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      if (!ref.mounted) return;

      // Start recording immediately
      try {
        if (!_cameraController!.value.isRecordingVideo) {
          await _cameraController!.startVideoRecording();
        }
      } catch (recErr) {
        debugPrint('startVideoRecording error: $recErr');
      }

      if (!ref.mounted) return;
      _startTimer();

      state = state.copyWith(
        isCameraInitialized: true,
        isRecording: true,
        isFrontCamera: desc.lensDirection == CameraLensDirection.front,
        errorMessage: null,
      );
    } catch (e) {
      debugPrint('Camera setup failed: $e');
      if (!ref.mounted) return;
      // Fallback try without audio if mic caused issue
      try {
        final desc = _availableCameras[_currentCameraIndex];
        _cameraController = CameraController(
          desc,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (!ref.mounted) return;

        if (!_cameraController!.value.isRecordingVideo) {
          await _cameraController!.startVideoRecording();
        }
        if (!ref.mounted) return;

        _startTimer();
        state = state.copyWith(
          isCameraInitialized: true,
          isRecording: true,
          errorMessage: null,
        );
      } catch (fallbackErr) {
        debugPrint('Fallback camera failed: $fallbackErr');
        if (!ref.mounted) return;
        _startTimer();
        state = state.copyWith(
          isCameraInitialized: false,
          errorMessage: 'Please grant camera permissions and restart app.',
        );
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!ref.mounted) {
        timer.cancel();
        return;
      }
      if (state.isRecording) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  Future<void> switchCamera() async {
    if (_availableCameras.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _availableCameras.length;
    await _initializeCurrentCamera();
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final newFlash = !state.isFlashOn;
      await _cameraController!.setFlashMode(
        newFlash ? FlashMode.torch : FlashMode.off,
      );
      if (!ref.mounted) return;
      state = state.copyWith(isFlashOn: newFlash);
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  Future<void> stopSos() async {
    _timer?.cancel();
    String? videoPath;

    try {
      if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
        final XFile file = await _cameraController!.stopVideoRecording();
        videoPath = file.path;
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }

    // Guard against unmounted ref when provider has been disposed
    if (!ref.mounted) return;

    state = state.copyWith(
      isRecording: false,
      isSosEnded: true,
      recordedVideoPath: videoPath,
    );
  }

  void _stopAndDispose() {
    _timer?.cancel();
    try {
      if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
        _cameraController!.stopVideoRecording().catchError((_) => XFile(''));
      }
    } catch (_) {}
    try {
      _cameraController?.dispose();
    } catch (_) {}
    _cameraController = null;
  }
}

final sosActiveCameraProvider =
    NotifierProvider.autoDispose<SosActiveCameraNotifier, SosActiveCameraState>(
  SosActiveCameraNotifier.new,
);
