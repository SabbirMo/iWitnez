import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/sos_countdown_state.dart';

class SosCountdownNotifier extends Notifier<SosCountdownState> {
  Timer? _timer;

  @override
  SosCountdownState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Safely start timer after the build cycle completes
    Future.microtask(() {
      if (ref.mounted) {
        _startTimer();
      }
    });

    return const SosCountdownState(
      secondsRemaining: 10,
      totalSeconds: 10,
      isAlertSent: false,
      isCancelled: false,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!ref.mounted) {
        timer.cancel();
        return;
      }
      if (state.secondsRemaining > 1) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        timer.cancel();
        state = state.copyWith(secondsRemaining: 0, isAlertSent: true);
      }
    });
  }

  void triggerImmediateSend() {
    if (state.isAlertSent || state.isCancelled) return;
    _timer?.cancel();
    state = state.copyWith(secondsRemaining: 0, isAlertSent: true);
  }

  void cancelAlert() {
    _timer?.cancel();
    state = state.copyWith(isCancelled: true);
  }
}

final sosCountdownProvider =
    NotifierProvider.autoDispose<SosCountdownNotifier, SosCountdownState>(
      SosCountdownNotifier.new,
    );
