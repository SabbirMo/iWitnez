import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationHistoryResponse {
  final bool success;
  final String message;
  final LocationHistoryData? data;

  LocationHistoryResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LocationHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawSuccess = json['success'];
    final bool success = rawSuccess == true ||
        rawSuccess == 1 ||
        rawSuccess?.toString().toLowerCase() == 'true';

    return LocationHistoryResponse(
      success: success,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? LocationHistoryData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LocationHistoryData {
  final String date;
  final String dateDisplay;
  final bool isToday;
  final List<LatLng> route;
  final List<LocationHistoryTimelineItem> timeline;

  LocationHistoryData({
    required this.date,
    required this.dateDisplay,
    required this.isToday,
    required this.route,
    required this.timeline,
  });

  factory LocationHistoryData.fromJson(Map<String, dynamic> json) {
    // Parse route
    final rawRoute = json['route'];
    final List<LatLng> parsedRoute = [];
    if (rawRoute is List) {
      for (final item in rawRoute) {
        if (item is Map<String, dynamic>) {
          final lat = double.tryParse(item['latitude']?.toString() ?? '');
          final lng = double.tryParse(item['longitude']?.toString() ?? '');
          if (lat != null && lng != null) {
            parsedRoute.add(LatLng(lat, lng));
          }
        }
      }
    }

    // Parse timeline
    final rawTimeline = json['timeline'];
    final List<LocationHistoryTimelineItem> parsedTimeline = [];
    if (rawTimeline is List) {
      for (final item in rawTimeline) {
        if (item is Map<String, dynamic>) {
          parsedTimeline.add(LocationHistoryTimelineItem.fromJson(item));
        }
      }
    }

    final rawIsToday = json['is_today'];
    final bool isToday = rawIsToday == true ||
        rawIsToday == 1 ||
        rawIsToday?.toString().toLowerCase() == 'true';

    return LocationHistoryData(
      date: json['date']?.toString() ?? '',
      dateDisplay: json['date_display']?.toString() ?? '',
      isToday: isToday,
      route: parsedRoute,
      timeline: parsedTimeline,
    );
  }
}

class LocationHistoryTimelineItem {
  final String id;
  final double? latitude;
  final double? longitude;
  final String address;
  final String pointType; // "start", "waypoint", "end"
  final String durationDisplay; // "Start", "50 min", "2h 25m", "End"
  final String timeDisplay; // e.g. "8:25 AM"
  final String recordedAt;

  const LocationHistoryTimelineItem({
    required this.id,
    this.latitude,
    this.longitude,
    required this.address,
    required this.pointType,
    required this.durationDisplay,
    required this.timeDisplay,
    required this.recordedAt,
  });

  bool get isStart => pointType.toLowerCase() == 'start';
  bool get isEnd => pointType.toLowerCase() == 'end';
  bool get isWaypoint => !isStart && !isEnd;

  factory LocationHistoryTimelineItem.fromJson(Map<String, dynamic> json) {
    return LocationHistoryTimelineItem(
      id: json['id']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      address: json['address'] as String? ?? '',
      pointType: json['point_type'] as String? ?? 'waypoint',
      durationDisplay: json['duration_display'] as String? ?? '',
      timeDisplay: json['time_display'] as String? ?? '',
      recordedAt: json['recorded_at'] as String? ?? '',
    );
  }
}

