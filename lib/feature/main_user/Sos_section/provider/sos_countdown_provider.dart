import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/services/location_service.dart';
import '../model/sos_countdown_state.dart';
import '../repository/sos_repository.dart';

class SosCountdownNotifier extends Notifier<SosCountdownState> {
  Timer? _timer;
  Completer<String?>? _startCompleter;

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
        _onCountdownFinished();
      }
    });
  }

  /// Step 1: User Taps the SOS Button - initiates session and returns alert ID
  Future<void> initiateSos({
    double? latitude,
    double? longitude,
    String? address,
    int countdownSeconds = 10,
  }) async {
    if (_startCompleter != null) return;
    _startCompleter = Completer<String?>();

    state = state.copyWith(isStarting: true);

    double lat = latitude ?? 40.785091;
    double lng = longitude ?? -73.968285;
    String addr = (address != null && address.isNotEmpty)
        ? address
        : '1200 Park Ave, New York, NY 10028, USA';

    // If coordinates were not passed, attempt to fetch current GPS location
    if (latitude == null || longitude == null) {
      try {
        final loc = await const LocationService().getCurrentLocation();
        if (loc.isSuccess && loc.position != null) {
          lat = loc.position!.latitude;
          lng = loc.position!.longitude;
        }
      } catch (_) {}
    }

    if (!ref.mounted) return;

    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      address: addr,
    );

    try {
      final repository = ref.read(sosRepositoryProvider);
      final alertId = await repository.startSos(
        latitude: lat,
        longitude: lng,
        address: addr,
        countdownSeconds: countdownSeconds,
      );

      _startCompleter?.complete(alertId);

      if (!ref.mounted) return;

      state = state.copyWith(
        alertId: alertId,
        isStarting: false,
      );

      // Handle race condition: If user activated while start was in-flight
      if (state.isAlertSent && alertId != null && !state.isActivating) {
        _activateSos(alertId);
      } else if (state.isCancelled && alertId != null) {
        // If user cancelled while start was in-flight
        repository.cancelSos(alertId);
      }
    } catch (_) {
      _startCompleter?.complete(null);
      if (ref.mounted) {
        state = state.copyWith(isStarting: false);
      }
    }
  }

  /// Step 2: Countdown Finishes (or User confirms "Send Help Now")
  void triggerImmediateSend() {
    if (state.isAlertSent || state.isCancelled) return;
    _timer?.cancel();
    state = state.copyWith(secondsRemaining: 0, isAlertSent: true);

    if (state.alertId != null) {
      _activateSos(state.alertId!);
    } else {
      _startCompleter?.future.then((alertId) {
        if (alertId != null && ref.mounted) {
          _activateSos(alertId);
        }
      });
    }
  }

  void _onCountdownFinished() {
    if (state.isAlertSent || state.isCancelled) return;
    state = state.copyWith(secondsRemaining: 0, isAlertSent: true);

    if (state.alertId != null) {
      _activateSos(state.alertId!);
    } else {
      _startCompleter?.future.then((alertId) {
        if (alertId != null && ref.mounted) {
          _activateSos(alertId);
        }
      });
    }
  }

  Future<void> _activateSos(String alertId) async {
    if (state.isActivating) return;
    state = state.copyWith(isActivating: true);

    try {
      final repository = ref.read(sosRepositoryProvider);
      await repository.activateSos(alertId);
    } catch (_) {}

    if (ref.mounted) {
      state = state.copyWith(isActivating: false);
    }
  }

  /// Step 3: User Cancels During Countdown
  Future<void> cancelAlert({
    String reason = 'False alarm / Accidental tap',
  }) async {
    _timer?.cancel();
    state = state.copyWith(isCancelled: true);

    final alertId = state.alertId;
    if (alertId != null) {
      try {
        final repository = ref.read(sosRepositoryProvider);
        await repository.cancelSos(alertId, reason: reason);
      } catch (_) {}
    } else {
      _startCompleter?.future.then((resolvedId) {
        if (resolvedId != null && ref.mounted) {
          try {
            ref.read(sosRepositoryProvider).cancelSos(resolvedId, reason: reason);
          } catch (_) {}
        }
      });
    }
  }
}

final sosCountdownProvider =
    NotifierProvider.autoDispose<SosCountdownNotifier, SosCountdownState>(
      SosCountdownNotifier.new,
    );
