class SosCountdownState {
  final int secondsRemaining;
  final int totalSeconds;
  final bool isAlertSent;
  final bool isCancelled;
  final String? alertId;
  final bool isStarting;
  final bool isActivating;
  final bool isCancelling;
  final double? latitude;
  final double? longitude;
  final String? address;
  final int? batteryLevel;

  const SosCountdownState({
    this.secondsRemaining = 10,
    this.totalSeconds = 10,
    this.isAlertSent = false,
    this.isCancelled = false,
    this.alertId,
    this.isStarting = false,
    this.isActivating = false,
    this.isCancelling = false,
    this.latitude,
    this.longitude,
    this.address,
    this.batteryLevel,
  });

  String get formattedTime {
    final s = secondsRemaining.clamp(0, 99);
    final secStr = s.toString().padLeft(2, '0');
    return '00:$secStr';
  }

  SosCountdownState copyWith({
    int? secondsRemaining,
    int? totalSeconds,
    bool? isAlertSent,
    bool? isCancelled,
    String? alertId,
    bool? isStarting,
    bool? isActivating,
    bool? isCancelling,
    double? latitude,
    double? longitude,
    String? address,
    int? batteryLevel,
  }) {
    return SosCountdownState(
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isAlertSent: isAlertSent ?? this.isAlertSent,
      isCancelled: isCancelled ?? this.isCancelled,
      alertId: alertId ?? this.alertId,
      isStarting: isStarting ?? this.isStarting,
      isActivating: isActivating ?? this.isActivating,
      isCancelling: isCancelling ?? this.isCancelling,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }
}
