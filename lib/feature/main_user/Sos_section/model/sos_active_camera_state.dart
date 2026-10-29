class SosActiveCameraState {
  final int elapsedSeconds;
  final bool isRecording;
  final bool isFrontCamera;
  final bool isFlashOn;
  final bool isAudioActive;
  final bool isCameraInitialized;
  final String? errorMessage;
  final String? recordedVideoPath;
  final bool isSosEnded;
  final String? alertId;
  final DateTime? activatedAt;
  final bool isStopping;

  const SosActiveCameraState({
    this.elapsedSeconds = 0,
    this.isRecording = false,
    this.isFrontCamera = false,
    this.isFlashOn = false,
    this.isAudioActive = false,
    this.isCameraInitialized = false,
    this.errorMessage,
    this.recordedVideoPath,
    this.isSosEnded = false,
    this.alertId,
    this.activatedAt,
    this.isStopping = false,
  });

  String get formattedDuration {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$hStr:$mStr:$sStr';
  }

  SosActiveCameraState copyWith({
    int? elapsedSeconds,
    bool? isRecording,
    bool? isFrontCamera,
    bool? isFlashOn,
    bool? isAudioActive,
    bool? isCameraInitialized,
    String? errorMessage,
    String? recordedVideoPath,
    bool? isSosEnded,
    String? alertId,
    DateTime? activatedAt,
    bool? isStopping,
  }) {
    return SosActiveCameraState(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRecording: isRecording ?? this.isRecording,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isAudioActive: isAudioActive ?? this.isAudioActive,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
      recordedVideoPath: recordedVideoPath ?? this.recordedVideoPath,
      isSosEnded: isSosEnded ?? this.isSosEnded,
      alertId: alertId ?? this.alertId,
      activatedAt: activatedAt ?? this.activatedAt,
      isStopping: isStopping ?? this.isStopping,
    );
  }
}
