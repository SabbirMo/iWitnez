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

    // Start 10-second timer countdown immediately
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

  /// Step 1: User Taps the SOS Button - initiates session with real live location & battery
  /// Endpoint: POST /api/v1/emergency/sos/start/
  Future<void> initiateSos({
    double? latitude,
    double? longitude,
    String? address,
    int? batteryLevel,
    int countdownSeconds = 10,
  }) async {
    if (_startCompleter != null) return;
    _startCompleter = Completer<String?>();

    state = state.copyWith(isStarting: true);

    double? lat = latitude;
    double? lng = longitude;
    String? addr = address;
    int? battery = batteryLevel;

    // If coordinates were not passed from caller, fetch real current GPS position
    if (lat == null || lng == null) {
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
      batteryLevel: battery,
    );

    // If device location could not be determined at all, abort gracefully without sending fake data
    if (lat == null || lng == null) {
      _startCompleter?.complete(null);
      if (ref.mounted) {
        state = state.copyWith(isStarting: false);
      }
      return;
    }

    try {
      final repository = ref.read(sosRepositoryProvider);
      final alertId = await repository.startSos(
        latitude: lat,
        longitude: lng,
        address: addr,
        batteryLevel: battery,
        countdownSeconds: countdownSeconds,
      );

      _startCompleter?.complete(alertId);

      if (!ref.mounted) return;

      state = state.copyWith(alertId: alertId, isStarting: false);

      // Handle race condition: If user activated while start was in-flight
      if (state.isAlertSent && alertId != null && !state.isActivating) {
        _activateSos(alertId);
      } else if (state.isCancelled && alertId != null) {
        // If user cancelled while start was in-flight
        repository.cancelSos(alertId, reason: 'Accidental tap');
      }
    } catch (_) {
      _startCompleter?.complete(null);
      if (ref.mounted) {
        state = state.copyWith(isStarting: false);
      }
    }
  }

  /// Step 2: Option A - "Slide to Send SOS" (Immediate Activation)
  /// If user slides the slider OR when 10s countdown hits 0
  /// Endpoint: POST /api/v1/emergency/sos/{alert_id}/activate/
  void triggerImmediateSend() {
    _triggerActivation();
  }

  void _onCountdownFinished() {
    _triggerActivation();
  }

  void _triggerActivation() {
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

  /// Step 3: Option B - "Cancel SOS" (Accidental Tap)
  /// Endpoint: POST /api/v1/emergency/sos/{alert_id}/cancel/
  Future<void> cancelAlert({String reason = 'Accidental tap'}) async {
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
            ref
                .read(sosRepositoryProvider)
                .cancelSos(resolvedId, reason: reason);
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
