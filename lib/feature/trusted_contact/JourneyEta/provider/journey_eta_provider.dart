import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/journey_eta_model.dart';
import '../repository/journey_eta_repository.dart';

class JourneyEtaState {
  final bool isLoading;
  final String? error;
  final MonitoredJourneyData? data;
  final DateTime? selectedDate;

  const JourneyEtaState({
    this.isLoading = false,
    this.error,
    this.data,
    this.selectedDate,
  });

  JourneyEtaState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    MonitoredJourneyData? data,
    DateTime? selectedDate,
  }) {
    return JourneyEtaState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

final journeyEtaRepositoryProvider = Provider<JourneyEtaRepository>((ref) {
  return JourneyEtaRepository();
});

class JourneyEtaNotifier extends Notifier<JourneyEtaState> {
  late final JourneyEtaRepository _repository;

  @override
  JourneyEtaState build() {
    _repository = ref.watch(journeyEtaRepositoryProvider);
    // Initial fetch without query params to get current journey
    Future.microtask(() => fetchJourney());
    return const JourneyEtaState(isLoading: true);
  }

  String _formatDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatDisplayDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> fetchJourney({DateTime? date, bool isRefresh = false}) async {
    final targetDate = date ?? state.selectedDate;
    final String? dateParam =
        targetDate != null ? _formatDate(targetDate) : null;

    if (!isRefresh) {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        selectedDate: targetDate,
      );
    } else {
      state = state.copyWith(isLoading: true, selectedDate: targetDate);
    }

    try {
      final response = await _repository.getMonitoredJourney(date: dateParam);

      if (response.success && response.data != null) {
        DateTime? parsedDate;
        if (response.data!.date.isNotEmpty) {
          parsedDate = DateTime.tryParse(response.data!.date);
        }

        state = state.copyWith(
          isLoading: false,
          data: response.data,
          selectedDate: targetDate ?? parsedDate ?? state.selectedDate,
          clearError: true,
        );
      } else {
        // If server returns success: false or empty data for that date
        state = state.copyWith(
          isLoading: false,
          data: MonitoredJourneyData(
            date: dateParam ?? '',
            dateDisplay:
                targetDate != null ? _formatDisplayDate(targetDate) : '',
            route: const [],
            timeline: const [],
          ),
          clearError: true,
        );
      }
    } catch (e, st) {
      debugPrint('[JourneyEtaNotifier] Error: $e\n$st');
      // If server returns 404 (no history found for this date), show empty state for this date
      state = state.copyWith(
        isLoading: false,
        data: MonitoredJourneyData(
          date: dateParam ?? '',
          dateDisplay:
              targetDate != null ? _formatDisplayDate(targetDate) : '',
          route: const [],
          timeline: const [],
        ),
        error: e.toString().contains('SocketException')
            ? 'No internet connection or server is unreachable.'
            : null,
      );
    }
  }

  void setDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      isLoading: true,
      clearError: true,
    );
    fetchJourney(date: date);
  }

  Future<void> refresh() async {
    await fetchJourney(date: state.selectedDate, isRefresh: true);
  }
}

final journeyEtaProvider =
    NotifierProvider<JourneyEtaNotifier, JourneyEtaState>(
  JourneyEtaNotifier.new,
);
