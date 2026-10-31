import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import 'package:iwitnez/feature/main_user/CheckIn/provider/check_in_provider.dart';
import '../model/scheduled_check_in_model.dart';
import '../repository/scheduled_timer_repository.dart';

class ScheduledTimerState {
  final int hours;
  final int minutes;
  final int seconds;
  final String note;
  final bool remindBeforeTimeEnds;
  final bool notifyIfNotCheckedIn;
  final bool isTimerActive;
  final int? remainingSeconds;
  final bool isLoading;
  final ScheduledCheckInModel? activeCheckIn;

  const ScheduledTimerState({
    this.hours = 1,
    this.minutes = 0,
    this.seconds = 0,
    this.note = "I'm at Office",
    this.remindBeforeTimeEnds = true,
    this.notifyIfNotCheckedIn = true,
    this.isTimerActive = false,
    this.remainingSeconds,
    this.isLoading = false,
    this.activeCheckIn,
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
    bool? isLoading,
    ScheduledCheckInModel? activeCheckIn,
    bool clearActiveCheckIn = false,
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
      isLoading: isLoading ?? this.isLoading,
      activeCheckIn:
          clearActiveCheckIn ? null : (activeCheckIn ?? this.activeCheckIn),
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

  Future<bool> startTimerApi({
    required BuildContext context,
    void Function(ScheduledCheckInModel checkIn)? onSuccess,
  }) async {
    final totalSec = state.totalDurationSeconds;
    if (totalSec <= 0) {
      CustomSnackBar.showError(
        context,
        message: 'Please set a timer duration greater than 0.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(scheduledTimerRepositoryProvider);
      final checkIn = await repository.startCheckInTimer(
        hours: state.hours,
        minutes: state.minutes,
        seconds: state.seconds,
        notes: state.note.trim(),
        remindBeforeEnd: state.remindBeforeTimeEnds,
        notifyIfNotCheckedIn: state.notifyIfNotCheckedIn,
      );

      state = state.copyWith(
        isLoading: false,
        isTimerActive: true,
        activeCheckIn: checkIn,
        remainingSeconds: checkIn.timerDurationSeconds > 0
            ? checkIn.timerDurationSeconds
            : totalSec,
      );

      // Immediately sync with CheckIn provider so Screen 100 has fresh time
      if (checkIn.scheduledTimeDisplay != null &&
          checkIn.scheduledTimeDisplay!.isNotEmpty) {
        try {
          ref
              .read(checkInProvider.notifier)
              .updateCheckInTimeDisplay(checkIn.scheduledTimeDisplay!);
          ref.read(checkInProvider.notifier).loadCheckInPage();
        } catch (_) {}
      }

      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Check-in timer started. Stay safe!',
        );
      }

      onSuccess?.call(checkIn);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: ApiErrorHandler.getMessage(e),
        );
      }
      return false;
    }
  }

  void stopTimer() {
    state = state.copyWith(
      isTimerActive: false,
      remainingSeconds: null,
      clearActiveCheckIn: true,
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
