import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safety_tracking_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/repository/safety_tracking_repository.dart';

class SafetyTrackingState {
  final bool isLoading;
  final bool isLocationSharingActive;
  final MyLocationModel? myLocation;
  final bool alertsEnabled;
  final int selectedTabIndex; // 0: Live Tracking, 1: History
  final double zoomLevel;
  final List<SafePlaceModel> safePlaces;
  final DateTime selectedDate;
  final List<HistoryTimelineItem> timelineItems;

  SafetyTrackingState({
    this.isLoading = false,
    this.isLocationSharingActive = true,
    this.myLocation,
    this.alertsEnabled = true,
    this.selectedTabIndex = 0,
    this.zoomLevel = 1.0,
    this.safePlaces = const [],
    DateTime? selectedDate,
    this.timelineItems = const [],
  }) : selectedDate = selectedDate ?? DateTime.now();

  SafetyTrackingState copyWith({
    bool? isLoading,
    bool? isLocationSharingActive,
    MyLocationModel? myLocation,
    bool? alertsEnabled,
    int? selectedTabIndex,
    double? zoomLevel,
    List<SafePlaceModel>? safePlaces,
    DateTime? selectedDate,
    List<HistoryTimelineItem>? timelineItems,
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
      timelineItems: timelineItems ?? this.timelineItems,
    );
  }
}

class SafetyTrackingNotifier extends Notifier<SafetyTrackingState> {
  @override
  SafetyTrackingState build() {
    // Automatically load safety tracking dashboard on init from real API
    Future.microtask(() => fetchSafetyTracking());
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
          safePlaces: state.safePlaces.map((p) => p.id == id ? details : p).toList(),
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
          safePlaces: state.safePlaces.map((p) => p.id == id ? updated : p).toList(),
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
  }
}

final safetyTrackingProvider =
    NotifierProvider<SafetyTrackingNotifier, SafetyTrackingState>(
      SafetyTrackingNotifier.new,
    );
