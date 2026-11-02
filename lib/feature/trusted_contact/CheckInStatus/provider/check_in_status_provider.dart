import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/check_in_status_model.dart';
import '../repository/check_in_status_repository.dart';

class CheckInStatusState {
  final bool isLoading;
  final String? error;
  final CheckInStatusData? data;

  const CheckInStatusState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  CheckInStatusState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    CheckInStatusData? data,
  }) {
    return CheckInStatusState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
    );
  }
}

final checkInStatusRepositoryProvider = Provider<CheckInStatusRepository>((ref) {
  return CheckInStatusRepository();
});

class CheckInStatusNotifier extends Notifier<CheckInStatusState> {
  late final CheckInStatusRepository _repository;

  @override
  CheckInStatusState build() {
    _repository = ref.watch(checkInStatusRepositoryProvider);
    Future.microtask(() => fetchCheckInStatus());
    return const CheckInStatusState(isLoading: true);
  }

  Future<void> fetchCheckInStatus({bool isRefresh = false}) async {
    if (!isRefresh && state.data == null) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await _repository.getCheckInStatus();

      if (response.success && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          data: response.data,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message.isNotEmpty
              ? response.message
              : 'Failed to retrieve check-in status',
        );
      }
    } catch (e, st) {
      debugPrint('[CheckInStatusNotifier] Error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().contains('SocketException')
            ? 'No internet connection or server is unreachable.'
            : 'Could not load check-in status. Tap retry.',
      );
    }
  }

  Future<void> refresh() async {
    await fetchCheckInStatus(isRefresh: true);
  }
}

final checkInStatusProvider =
    NotifierProvider<CheckInStatusNotifier, CheckInStatusState>(
  CheckInStatusNotifier.new,
);
