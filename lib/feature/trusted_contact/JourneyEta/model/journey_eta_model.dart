import 'package:google_maps_flutter/google_maps_flutter.dart';

class MonitoredJourneyResponse {
  final bool success;
  final String message;
  final MonitoredJourneyData? data;
  final dynamic errors;

  const MonitoredJourneyResponse({
    this.success = false,
    this.message = '',
    this.data,
    this.errors,
  });

  factory MonitoredJourneyResponse.fromJson(Map<String, dynamic> json) {
    return MonitoredJourneyResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map
          ? MonitoredJourneyData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
      errors: json['errors'],
    );
  }
}

class MonitoredUserBrief {
  final String id;
  final String name;
  final bool isOnline;

  const MonitoredUserBrief({
    this.id = '',
    this.name = '',
    this.isOnline = true,
  });

  factory MonitoredUserBrief.fromJson(Map<String, dynamic> json) {
    return MonitoredUserBrief(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['user_name'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? true,
    );
  }
}

class JourneyTimelineItem {
  final String timeDisplay;
  final String pointType; // "start", "waypoint", "end"
  final String label; // "Start", "50 min", "End"
  final String address;
  final String durationDisplay;
  final double? latitude;
  final double? longitude;

  const JourneyTimelineItem({
    this.timeDisplay = '',
    this.pointType = '',
    this.label = '',
    this.address = '',
    this.durationDisplay = '',
    this.latitude,
    this.longitude,
  });

  bool get isStart => pointType.toLowerCase() == 'start';
  bool get isEnd => pointType.toLowerCase() == 'end';
  bool get isWaypoint => pointType.toLowerCase() == 'waypoint';

  String get effectiveBadgeText {
    if (label.isNotEmpty) return label;
    if (durationDisplay.isNotEmpty) return durationDisplay;
    return '';
  }

  factory JourneyTimelineItem.fromJson(Map<String, dynamic> json) {
    return JourneyTimelineItem(
      timeDisplay: json['time_display'] as String? ?? '',
      pointType: json['point_type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      address: json['address'] as String? ?? '',
      durationDisplay: json['duration_display'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ??
          double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: (json['longitude'] as num?)?.toDouble() ??
          double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }
}

class MonitoredJourneyData {
  final MonitoredUserBrief monitoredUser;
  final String date;
  final String dateDisplay;
  final List<LatLng> route;
  final List<JourneyTimelineItem> timeline;

  const MonitoredJourneyData({
    this.monitoredUser = const MonitoredUserBrief(),
    this.date = '',
    this.dateDisplay = '',
    this.route = const [],
    this.timeline = const [],
  });

  bool get isToday {
    if (dateDisplay.trim().toLowerCase() == 'today') return true;
    if (date.isEmpty) return false;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return date == todayStr;
  }

  factory MonitoredJourneyData.fromJson(Map<String, dynamic> json) {
    // 1. Parse route
    final rawRoute = json['route'];
    final List<LatLng> parsedRoute = [];
    if (rawRoute is List) {
      for (final item in rawRoute) {
        if (item is Map) {
          final lat = (item['latitude'] as num?)?.toDouble() ??
              double.tryParse(item['latitude']?.toString() ?? '');
          final lng = (item['longitude'] as num?)?.toDouble() ??
              double.tryParse(item['longitude']?.toString() ?? '');
          if (lat != null && lng != null) {
            parsedRoute.add(LatLng(lat, lng));
          }
        }
      }
    }

    // 2. Parse timeline
    final rawTimeline = json['timeline'];
    final List<JourneyTimelineItem> parsedTimeline = [];
    if (rawTimeline is List) {
      for (final item in rawTimeline) {
        if (item is Map) {
          parsedTimeline.add(
            JourneyTimelineItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    // 3. Parse user
    final rawUser = json['monitored_user'];
    final user = rawUser is Map
        ? MonitoredUserBrief.fromJson(Map<String, dynamic>.from(rawUser))
        : const MonitoredUserBrief();

    return MonitoredJourneyData(
      monitoredUser: user,
      date: json['date'] as String? ?? '',
      dateDisplay: json['date_display'] as String? ?? '',
      route: parsedRoute,
      timeline: parsedTimeline,
    );
  }
}
