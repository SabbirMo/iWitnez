import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/location_history_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safety_tracking_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/repository/safety_tracking_repository.dart';

class SafetyTrackingState {
  final bool? _isLoading;
  final bool? _isLocationSharingActive;
  final MyLocationModel? myLocation;
  final bool? _alertsEnabled;
  final int selectedTabIndex; // 0: Live Tracking, 1: History
  final double zoomLevel;
  final List<SafePlaceModel> safePlaces;
  final DateTime selectedDate;
  final LocationHistoryData? historyData;
  final bool? _isLoadingHistory;

  bool get isLoading => _isLoading ?? false;
  bool get isLocationSharingActive => _isLocationSharingActive ?? true;
  bool get alertsEnabled => _alertsEnabled ?? true;
  bool get isLoadingHistory => _isLoadingHistory ?? false;

  SafetyTrackingState({
    bool? isLoading,
    bool? isLocationSharingActive,
    this.myLocation,
    bool? alertsEnabled,
    this.selectedTabIndex = 0,
    this.zoomLevel = 1.0,
    this.safePlaces = const [],
    DateTime? selectedDate,
    this.historyData,
    bool? isLoadingHistory,
  }) : _isLoading = isLoading ?? false,
       _isLocationSharingActive = isLocationSharingActive ?? true,
       _alertsEnabled = alertsEnabled ?? true,
       selectedDate = selectedDate ?? DateTime.now(),
       _isLoadingHistory = isLoadingHistory ?? false;

  SafetyTrackingState copyWith({
    bool? isLoading,
    bool? isLocationSharingActive,
    MyLocationModel? myLocation,
    bool? alertsEnabled,
    int? selectedTabIndex,
    double? zoomLevel,
    List<SafePlaceModel>? safePlaces,
    DateTime? selectedDate,
    LocationHistoryData? historyData,
    bool? isLoadingHistory,
  }) {
    return SafetyTrackingState(
      isLoading: isLoading ?? this.isLoading,
      isLocationSharingActive:
          isLocationSharingActive ?? this.isLocationSharingActive,
      myLocation: myLocation ?? this.myLocation,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      safePlaces: safePlaces ?? this.safePlaces,
      selectedDate: selectedDate ?? this.selectedDate,
      historyData: historyData ?? this.historyData,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
    );
  }
}

class SafetyTrackingNotifier extends Notifier<SafetyTrackingState> {
  @override
  SafetyTrackingState build() {
    // Automatically load safety tracking dashboard & history on init from real API
    Future.microtask(() {
      fetchSafetyTracking();
      fetchLocationHistory();
    });
    return SafetyTrackingState();
  }

  Future<void> fetchSafetyTracking() async {
    state = state.copyWith(isLoading: true);
    try {
      final repository = ref.read(safetyTrackingRepositoryProvider);
      final data = await repository.getSafetyTrackingDashboard();

      if (data != null) {
        state = state.copyWith(
          isLoading: false,
          isLocationSharingActive: data.isLocationSharingActive,
          myLocation: data.myLocation,
          alertsEnabled: data.alertsEnabled,
          safePlaces: data.safePlaces,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleLocationSharing([bool? value]) async {
    final newValue = value ?? !state.isLocationSharingActive;
    state = state.copyWith(isLocationSharingActive: newValue);

    try {
      final repository = ref.read(safetyTrackingRepositoryProvider);
      await repository.setLocationSharing(newValue);
    } catch (_) {}
  }

  void setTabIndex(int index) {
    if (state.selectedTabIndex != index) {
      state = state.copyWith(selectedTabIndex: index);
      if (index == 1 && state.historyData == null) {
        fetchLocationHistory();
      }
    }
  }

  Future<void> fetchLocationHistory([String? dateString]) async {
    state = state.copyWith(isLoadingHistory: true);
    try {
      final repository = ref.read(safetyTrackingRepositoryProvider);
      final history = await repository.getLocationHistory(dateString);
      state = state.copyWith(isLoadingHistory: false, historyData: history);
    } catch (_) {
      state = state.copyWith(isLoadingHistory: false);
    }
  }

  void zoomIn() {
    if (state.zoomLevel < 1.8) {
      state = state.copyWith(
        zoomLevel: (state.zoomLevel + 0.15).clamp(0.6, 1.8),
      );
    }
  }

  void zoomOut() {
    if (state.zoomLevel > 0.6) {
      state = state.copyWith(
        zoomLevel: (state.zoomLevel - 0.15).clamp(0.6, 1.8),
      );
    }
  }

  void resetZoom() {
    state = state.copyWith(zoomLevel: 1.0);
  }

  Future<SafePlaceModel?> createSafePlace({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String icon,
    bool alertsEnabled = true,
  }) async {
    try {
      final repository = ref.read(safetyTrackingRepositoryProvider);
      final created = await repository.addSafePlace(
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        icon: icon,
        alertsEnabled: alertsEnabled,
      );

      if (created != null) {
        state = state.copyWith(
          safePlaces: [...state.safePlaces, created],
          selectedTabIndex: 0,
        );
        return created;
      }
    } catch (_) {}
    return null;
  }

  void addSafePlace(SafePlaceModel place) {
    state = state.copyWith(
      safePlaces: [...state.safePlaces, place],
      selectedTabIndex: 0,
    );
  }

  void removeSafePlace(String id) {
    state = state.copyWith(
      safePlaces: state.safePlaces.where((p) => p.id != id).toList(),
    );
  }

  Future<SafePlaceModel?> fetchSafePlaceDetails(String id) async {
    try {
      final repository = ref.read(safetyTrackingRepositoryProvider);
      final details = await repository.getSafePlaceDetails(id);
      if (details != null) {
        state = state.copyWith(
          safePlaces: state.safePlaces
              .map((p) => p.id == id ? details : p)
              .toList(),
        );
        return details;
      }
    } catch (_) {}
    return null;
  }

  Future<SafePlaceModel?> updateSafePlace(
    String id, {
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    String? icon,
    bool? alertsEnabled,
  }) async {
    try {
      final repository = ref.read(safetyTrackingRepositoryProvider);
      final updated = await repository.updateSafePlace(
        id,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        icon: icon,
        alertsEnabled: alertsEnabled,
      );

      if (updated != null) {
        state = state.copyWith(
          safePlaces: state.safePlaces
              .map((p) => p.id == id ? updated : p)
              .toList(),
        );
        return updated;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> deleteSafePlace(String id) async {
    try {
      final repository = ref.read(safetyTrackingRepositoryProvider);
      final success = await repository.deleteSafePlace(id);
      if (success) {
        removeSafePlace(id);
        return true;
      }
    } catch (_) {}
    return false;
  }

  void togglePlaceStatus(String id) {
    state = state.copyWith(
      safePlaces: state.safePlaces.map((p) {
        if (p.id == id) {
          final nextInside = !p.isInside;
          return p.copyWith(
            isInside: nextInside,
            statusDisplay: nextInside ? 'Inside' : 'Outside',
          );
        }
        return p;
      }).toList(),
    );
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    final formattedDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    fetchLocationHistory(formattedDate);
  }
}

final safetyTrackingProvider =
    NotifierProvider<SafetyTrackingNotifier, SafetyTrackingState>(
      SafetyTrackingNotifier.new,
    );
