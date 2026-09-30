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

  const SosActiveCameraState({
    this.elapsedSeconds = 0,
    this.isRecording = true,
    this.isFrontCamera = false,
    this.isFlashOn = false,
    this.isAudioActive = true,
    this.isCameraInitialized = false,
    this.errorMessage,
    this.recordedVideoPath,
    this.isSosEnded = false,
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
    );
  }
}
