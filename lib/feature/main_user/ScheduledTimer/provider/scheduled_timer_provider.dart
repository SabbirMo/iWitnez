import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduledTimerState {
  final int hours;
  final int minutes;
  final int seconds;
  final String note;
  final bool remindBeforeTimeEnds;
  final bool notifyIfNotCheckedIn;
  final bool isTimerActive;
  final int? remainingSeconds;

  const ScheduledTimerState({
    this.hours = 1,
    this.minutes = 0,
    this.seconds = 0,
    this.note = "I'm at Office",
    this.remindBeforeTimeEnds = true,
    this.notifyIfNotCheckedIn = true,
    this.isTimerActive = false,
    this.remainingSeconds,
  });

  ScheduledTimerState copyWith({
    int? hours,
    int? minutes,
    int? seconds,
    String? note,
    bool? remindBeforeTimeEnds,
    bool? notifyIfNotCheckedIn,
    bool? isTimerActive,
    int? remainingSeconds,
  }) {
    return ScheduledTimerState(
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      note: note ?? this.note,
      remindBeforeTimeEnds: remindBeforeTimeEnds ?? this.remindBeforeTimeEnds,
      notifyIfNotCheckedIn: notifyIfNotCheckedIn ?? this.notifyIfNotCheckedIn,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  int get totalDurationSeconds => (hours * 3600) + (minutes * 60) + seconds;

  String get formattedDuration =>
      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class ScheduledTimerNotifier extends Notifier<ScheduledTimerState> {
  @override
  ScheduledTimerState build() {
    return const ScheduledTimerState();
  }

  void setHours(int hours) {
    state = state.copyWith(hours: hours);
  }

  void setMinutes(int minutes) {
    state = state.copyWith(minutes: minutes);
  }

  void setSeconds(int seconds) {
    state = state.copyWith(seconds: seconds);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  void toggleRemindBeforeTimeEnds([bool? value]) {
    state = state.copyWith(
      remindBeforeTimeEnds: value ?? !state.remindBeforeTimeEnds,
    );
  }

  void toggleNotifyIfNotCheckedIn([bool? value]) {
    state = state.copyWith(
      notifyIfNotCheckedIn: value ?? !state.notifyIfNotCheckedIn,
    );
  }

  void startTimer() {
    state = state.copyWith(
      isTimerActive: true,
      remainingSeconds: state.totalDurationSeconds,
    );
  }

  void stopTimer() {
    state = state.copyWith(
      isTimerActive: false,
      remainingSeconds: null,
    );
  }

  void reset() {
    state = const ScheduledTimerState();
  }
}

final scheduledTimerProvider =
    NotifierProvider<ScheduledTimerNotifier, ScheduledTimerState>(
      ScheduledTimerNotifier.new,
    );
