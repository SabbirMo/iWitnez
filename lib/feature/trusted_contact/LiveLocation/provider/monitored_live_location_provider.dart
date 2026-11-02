import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/error/api_error.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/monitored_live_location_model.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/repository/monitored_live_location_repository.dart';

final monitoredLiveLocationProvider = NotifierProvider<
    MonitoredLiveLocationNotifier, MonitoredLiveLocationState>(
  MonitoredLiveLocationNotifier.new,
);

class MonitoredLiveLocationNotifier
    extends Notifier<MonitoredLiveLocationState> {
  bool _disposed = false;

  MonitoredLiveLocationRepository get _repository =>
      ref.read(monitoredLiveLocationRepositoryProvider);

  @override
  MonitoredLiveLocationState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });

    Future.microtask(() => fetchLiveLocation());

    return MonitoredLiveLocationState.initial();
  }

  Future<void> fetchLiveLocation({bool forceRefresh = false}) async {
    if (forceRefresh || state.data == null) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final response = await _repository.getLiveLocation();
      if (!_disposed) {
        if (response.success && response.data != null) {
          state = state.copyWith(
            data: response.data,
            isLoading: false,
            clearError: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: response.message.isNotEmpty
                ? response.message
                : 'Failed to load live location',
          );
        }
      }
    } catch (e) {
      debugPrint('[MonitoredLiveLocationNotifier] Error: $e');
      if (!_disposed) {
        final msg =
            e is ApiError ? e.message : 'Failed to load live location data.';
        state = state.copyWith(isLoading: false, errorMessage: msg);
      }
    }
  }
}

