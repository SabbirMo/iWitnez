class SosCountdownState {
  final int secondsRemaining;
  final int totalSeconds;
  final bool isAlertSent;
  final bool isCancelled;

  const SosCountdownState({
    this.secondsRemaining = 10,
    this.totalSeconds = 10,
    this.isAlertSent = false,
    this.isCancelled = false,
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
  }) {
    return SosCountdownState(
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isAlertSent: isAlertSent ?? this.isAlertSent,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}
