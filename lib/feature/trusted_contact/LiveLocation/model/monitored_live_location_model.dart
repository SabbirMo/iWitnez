class MonitoredUserLiveLocation {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String movementStatus;
  final int batteryLevel;
  final String updatedAgo;

  const MonitoredUserLiveLocation({
    this.id = '',
    this.name = '',
    this.avatarUrl = '',
    this.isOnline = true,
    this.movementStatus = '',
    this.batteryLevel = 0,
    this.updatedAgo = '',
  });

  factory MonitoredUserLiveLocation.fromJson(Map<String, dynamic> json) {
    return MonitoredUserLiveLocation(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? true,
      movementStatus: json['movement_status'] as String? ?? '',
      batteryLevel: (json['battery_level'] as num?)?.toInt() ?? 0,
      updatedAgo: json['updated_ago'] as String? ?? '',
    );
  }
}

class MonitoredLocationData {
  final String address;
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isLive;
  final String updatedAgo;

  const MonitoredLocationData({
    this.address = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.accuracy = 0.0,
    this.isLive = true,
    this.updatedAgo = '',
  });

  factory MonitoredLocationData.fromJson(Map<String, dynamic> json) {
    return MonitoredLocationData(
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      isLive: json['is_live'] as bool? ?? true,
      updatedAgo: json['updated_ago'] as String? ?? '',
    );
  }
}

class SafePlaceEtaItem {
  final String name;
  final String address;
  final String icon;
  final String timeDisplay;
  final String badge;
  final String badgeColor;

  const SafePlaceEtaItem({
    this.name = '',
    this.address = '',
    this.icon = '',
    this.timeDisplay = '',
    this.badge = '',
    this.badgeColor = '',
  });

  factory SafePlaceEtaItem.fromJson(Map<String, dynamic> json) {
    return SafePlaceEtaItem(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      timeDisplay: json['time_display'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      badgeColor: json['badge_color'] as String? ?? '',
    );
  }
}

class MonitoredLiveLocationData {
  final MonitoredUserLiveLocation? monitoredUser;
  final MonitoredLocationData? location;
  final List<SafePlaceEtaItem> safePlaces;

  const MonitoredLiveLocationData({
    this.monitoredUser,
    this.location,
    this.safePlaces = const [],
  });

  factory MonitoredLiveLocationData.fromJson(Map<String, dynamic> json) {
    return MonitoredLiveLocationData(
      monitoredUser: json['monitored_user'] is Map<String, dynamic>
          ? MonitoredUserLiveLocation.fromJson(
              json['monitored_user'] as Map<String, dynamic>,
            )
          : null,
      location: json['location'] is Map<String, dynamic>
          ? MonitoredLocationData.fromJson(
              json['location'] as Map<String, dynamic>,
            )
          : null,
      safePlaces: (json['safe_places'] as List<dynamic>?)
              ?.map(
                  (e) => SafePlaceEtaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class MonitoredLiveLocationResponse {
  final bool success;
  final String message;
  final MonitoredLiveLocationData? data;
  final dynamic errors;

  const MonitoredLiveLocationResponse({
    this.success = false,
    this.message = '',
    this.data,
    this.errors,
  });

  factory MonitoredLiveLocationResponse.fromJson(Map<String, dynamic> json) {
    return MonitoredLiveLocationResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? MonitoredLiveLocationData.fromJson(
              json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'],
    );
  }
}

class MonitoredLiveLocationState {
  final MonitoredLiveLocationData? data;
  final bool isLoading;
  final String? errorMessage;

  const MonitoredLiveLocationState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  factory MonitoredLiveLocationState.initial() =>
      const MonitoredLiveLocationState(
        data: null,
        isLoading: true,
        errorMessage: null,
      );

  MonitoredLiveLocationState copyWith({
    MonitoredLiveLocationData? data,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MonitoredLiveLocationState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

