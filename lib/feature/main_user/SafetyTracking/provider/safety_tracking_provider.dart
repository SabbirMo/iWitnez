import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';

class SafetyTrackingState {
  final bool isLocationSharingActive;
  final int selectedTabIndex; // 0: Live Tracking, 1: History
  final double zoomLevel;
  final List<SafePlaceModel> safePlaces;

  SafetyTrackingState({
    this.isLocationSharingActive = true,
    this.selectedTabIndex = 0,
    this.zoomLevel = 1.0,
    this.safePlaces = const [
      SafePlaceModel(
        id: '1',
        title: 'Home',
        address: '1200 Park Ave, New York, NY',
        isInside: true,
        type: SafePlaceType.home,
      ),
      SafePlaceModel(
        id: '2',
        title: 'Work',
        address: '500 5th Ave, New York, NY',
        isInside: false,
        type: SafePlaceType.work,
      ),
      SafePlaceModel(
        id: '3',
        title: 'University',
        address: 'Columbia University, NY',
        isInside: false,
        type: SafePlaceType.university,
      ),
    ],
    DateTime? selectedDate,
    this.timelineItems = const [
      HistoryTimelineItem(
        id: '1',
        time: '08:25 AM',
        label: 'Start',
        address: '1200 Park Ave, New York, NY 10028, USA',
        pointType: HistoryPointType.start,
      ),
      HistoryTimelineItem(
        id: '2',
        time: '09:15 AM',
        duration: '50 min',
        address: '500 5th Ave, New York, NY 10110, USA',
        pointType: HistoryPointType.waypoint,
      ),
      HistoryTimelineItem(
        id: '3',
        time: '11:40 AM',
        duration: '2h 25m',
        address: 'Columbia University, New York, NY 10027, USA',
        pointType: HistoryPointType.waypoint,
      ),
      HistoryTimelineItem(
        id: '4',
        time: '01:10 PM',
        duration: '45 min',
        address: 'Riverside Park, New York, NY 10027, USA',
        pointType: HistoryPointType.waypoint,
      ),
      HistoryTimelineItem(
        id: '5',
        time: '03:35 PM',
        label: 'End',
        address: '500 5th Ave, New York, NY 10110, USA',
        pointType: HistoryPointType.end,
      ),
    ],
  }) : selectedDate = selectedDate ?? DateTime(2024, 5, 15);

  final DateTime selectedDate;
  final List<HistoryTimelineItem> timelineItems;

  SafetyTrackingState copyWith({
    bool? isLocationSharingActive,
    int? selectedTabIndex,
    double? zoomLevel,
    List<SafePlaceModel>? safePlaces,
    DateTime? selectedDate,
    List<HistoryTimelineItem>? timelineItems,
  }) {
    return SafetyTrackingState(
      isLocationSharingActive:
          isLocationSharingActive ?? this.isLocationSharingActive,
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
    return SafetyTrackingState();
  }

  void toggleLocationSharing([bool? value]) {
    final newValue = value ?? !state.isLocationSharingActive;
    state = state.copyWith(isLocationSharingActive: newValue);
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

  void addSafePlace(SafePlaceModel place) {
    state = state.copyWith(safePlaces: [...state.safePlaces, place]);
  }

  void removeSafePlace(String id) {
    state = state.copyWith(
      safePlaces: state.safePlaces.where((p) => p.id != id).toList(),
    );
  }

  void togglePlaceStatus(String id) {
    state = state.copyWith(
      safePlaces: state.safePlaces.map((p) {
        if (p.id == id) {
          return p.copyWith(isInside: !p.isInside);
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
    NotifierProvider.autoDispose<SafetyTrackingNotifier, SafetyTrackingState>(
      SafetyTrackingNotifier.new,
    );
