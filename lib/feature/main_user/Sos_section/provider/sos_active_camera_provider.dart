import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/services/location_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/sos_active_camera_state.dart';
import '../repository/sos_repository.dart';

class SosActiveCameraNotifier extends Notifier<SosActiveCameraState> {
  Timer? _timer;
  Timer? _gpsPingTimer;
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  int _currentCameraIndex = 0;
  DateTime? _recordingStartTime;

  CameraController? get cameraController => _cameraController;

  @override
  SosActiveCameraState build() {
    ref.onDispose(() {
      _stopAndDispose();
    });

    Future.microtask(() {
      if (ref.mounted) {
        initSessionAndRecording();
      }
    });

    return const SosActiveCameraState(
      elapsedSeconds: 0,
      isRecording: false,
      isAudioActive: false,
      isCameraInitialized: false,
    );
  }

  /// Sets or verifies the active emergency session ID
  void setAlertId(String? id) {
    if (id != null && id.isNotEmpty) {
      state = state.copyWith(alertId: id);
    }
  }

  /// 1. Check Active Session & Initialize
  Future<void> initSessionAndRecording({String? alertId}) async {
    if (alertId != null && alertId.isNotEmpty) {
      state = state.copyWith(alertId: alertId);
    }

    // 1. Immediately request permissions and launch camera preview without delay
    final cameraFuture = initCameraAndRecording();

    // 2. Concurrently check active session to sync backend alert_id and started_at
    unawaited(checkActiveSession());

    // 3. Start periodic GPS streaming
    _startGpsStreaming();

    await cameraFuture;
  }

  /// Checks active session from backend
  /// GET /api/v1/emergency/sos/active/
  Future<void> checkActiveSession() async {
    try {
      final repository = ref.read(sosRepositoryProvider);
      final activeData = await repository.getActiveSos();

      if (!ref.mounted) return;

      if (activeData != null) {
        final id = activeData['id']?.toString() ?? state.alertId;
        final rawStartedAt =
            activeData['started_at']?.toString() ??
            activeData['activated_at']?.toString();
        DateTime? activatedAt = rawStartedAt != null
            ? DateTime.tryParse(rawStartedAt)?.toLocal()
            : null;

        state = state.copyWith(
          alertId: id,
          activatedAt: activatedAt ?? state.activatedAt ?? DateTime.now(),
        );
      } else {
        if (state.activatedAt == null) {
          state = state.copyWith(activatedAt: DateTime.now());
        }
      }
    } catch (e) {
      debugPrint('checkActiveSession error: $e');
      if (state.activatedAt == null) {
        state = state.copyWith(activatedAt: DateTime.now());
      }
    }
  }

  /// 2. Periodic GPS Streaming (Every 5–10 seconds)
  /// POST /api/v1/location/ping/
  void _startGpsStreaming() {
    _gpsPingTimer?.cancel();

    // Stagger initial GPS ping slightly so camera hardware gets 100% CPU priority on startup
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!ref.mounted || state.isSosEnded) return;
      _pingCurrentGps();
    });

    // Periodic ping every 8 seconds (within 5-10 second requirement)
    _gpsPingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!ref.mounted || state.isSosEnded) return;
      _pingCurrentGps();
    });
  }

  Future<void> _pingCurrentGps() async {
    try {
      final loc = await const LocationService().getCurrentLocation();
      if (!ref.mounted || !loc.isSuccess || loc.position == null) return;

      final lat = loc.position!.latitude;
      final lng = loc.position!.longitude;

      final repository = ref.read(sosRepositoryProvider);
      await repository.pingLocation(latitude: lat, longitude: lng);
    } catch (e) {
      debugPrint('Periodic GPS ping error: $e');
    }
  }

  /// 3. Local Camera & Microphone Recording (Ultra-fast initialization)
  Future<void> initCameraAndRecording() async {
    try {
      // 1. Fast permission check: only prompt if not already granted
      final cameraGranted = await Permission.camera.isGranted;
      final micGranted = await Permission.microphone.isGranted;
      if (!cameraGranted || !micGranted) {
        await [Permission.camera, Permission.microphone].request();
      }

      if (!ref.mounted) return;

      // 2. Discover cameras
      if (_availableCameras.isEmpty) {
        _availableCameras = await availableCameras();
      }
      if (!ref.mounted) return;

      if (_availableCameras.isEmpty) {
        state = state.copyWith(
          isCameraInitialized: false,
          isRecording: false,
          isAudioActive: false,
          elapsedSeconds: 0,
          errorMessage: 'No camera device detected.',
        );
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
        isRecording: false,
        isAudioActive: false,
        elapsedSeconds: 0,
        errorMessage: 'Unable to start camera: $e',
      );
    }
  }

  Future<void> _initializeCurrentCamera() async {
    if (_availableCameras.isEmpty) return;

    try {
      await _cameraController?.dispose();
      if (!ref.mounted) return;

      final desc = _availableCameras[_currentCameraIndex];
      // ResolutionPreset.medium loads 3x faster than high (480p/720p HD) and uploads rapidly
      _cameraController = CameraController(
        desc,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      if (!ref.mounted) return;

      // Render camera preview IMMEDIATELY so the user sees live video without waiting
      state = state.copyWith(
        isCameraInitialized: true,
        isFrontCamera: desc.lensDirection == CameraLensDirection.front,
        errorMessage: null,
      );

      // Start video & audio recording in the background
      bool recordingStarted = false;
      try {
        if (!_cameraController!.value.isRecordingVideo) {
          await _cameraController!.startVideoRecording();
          recordingStarted = true;
        } else {
          recordingStarted = true;
        }
      } catch (recErr) {
        debugPrint('startVideoRecording error: $recErr');
      }

      if (!ref.mounted) return;

      if (recordingStarted) {
        _recordingStartTime = DateTime.now();
        _startTimer();

        state = state.copyWith(
          isCameraInitialized: true,
          isRecording: true,
          isAudioActive: true,
          elapsedSeconds: 0,
          errorMessage: null,
        );
      }
    } catch (e) {
      debugPrint('Camera setup failed: $e');
      if (!ref.mounted) return;

      // Fallback try without audio if microphone caused an exclusive lock
      try {
        final desc = _availableCameras[_currentCameraIndex];
        _cameraController = CameraController(
          desc,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (!ref.mounted) return;

        // Render preview immediately
        state = state.copyWith(
          isCameraInitialized: true,
          isFrontCamera: desc.lensDirection == CameraLensDirection.front,
          errorMessage: null,
        );

        bool fallbackRecordingStarted = false;
        try {
          if (!_cameraController!.value.isRecordingVideo) {
            await _cameraController!.startVideoRecording();
            fallbackRecordingStarted = true;
          } else {
            fallbackRecordingStarted = true;
          }
        } catch (_) {}

        if (!ref.mounted) return;

        if (fallbackRecordingStarted) {
          _recordingStartTime = DateTime.now();
          _startTimer();

          state = state.copyWith(
            isCameraInitialized: true,
            isRecording: true,
            isAudioActive: false,
            elapsedSeconds: 0,
            errorMessage: null,
          );
        }
      } catch (fallbackErr) {
        debugPrint('Fallback camera failed: $fallbackErr');
        if (!ref.mounted) return;
        state = state.copyWith(
          isCameraInitialized: false,
          isRecording: false,
          isAudioActive: false,
          elapsedSeconds: 0,
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
      if (state.isRecording && _recordingStartTime != null) {
        final diff = DateTime.now().difference(_recordingStartTime!).inSeconds;
        state = state.copyWith(elapsedSeconds: diff >= 0 ? diff : 0);
      }
    });
  }

  Future<void> switchCamera() async {
    if (_availableCameras.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _availableCameras.length;
    await _initializeCurrentCamera();
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

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

  /// 4. Action: "Stop SOS" (Red Button)
  /// Stops local recording, calls POST /api/v1/emergency/sos/{alert_id}/stop/
  Future<String?> stopSos() async {
    _timer?.cancel();
    _gpsPingTimer?.cancel();
    state = state.copyWith(
      isStopping: true,
      isRecording: false,
      isAudioActive: false,
    );

    String? videoPath;

    // Stop local video & audio recording and retrieve file path
    try {
      if (_cameraController != null &&
          _cameraController!.value.isRecordingVideo) {
        // If recording just started (< 2 sec), give MediaRecorder a brief moment
        // to finalize audio/video frames before closing
        if (state.elapsedSeconds < 2) {
          await Future.delayed(const Duration(milliseconds: 1000));
        }

        final XFile file = await _cameraController!.stopVideoRecording();
        videoPath = file.path;

        // Allow Android MediaRecorder to finish flushing to disk
        await Future.delayed(const Duration(milliseconds: 400));
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }

    // Call backend API: POST /api/v1/emergency/sos/{alert_id}/stop/
    final alertId = state.alertId;
    if (alertId != null && alertId.isNotEmpty) {
      try {
        final repository = ref.read(sosRepositoryProvider);
        await repository.stopSos(alertId);
      } catch (e) {
        debugPrint('stopSos API error: $e');
      }
    }

    if (!ref.mounted) return videoPath;

    state = state.copyWith(
      isRecording: false,
      isAudioActive: false,
      isSosEnded: true,
      recordedVideoPath: videoPath,
      isStopping: false,
    );

    return videoPath;
  }

  void _stopAndDispose() {
    _timer?.cancel();
    _gpsPingTimer?.cancel();
    _recordingStartTime = null;
    try {
      if (_cameraController != null &&
          _cameraController!.value.isRecordingVideo) {
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
