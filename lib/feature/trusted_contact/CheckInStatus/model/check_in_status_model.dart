class MonitoredCheckInStatusResponse {
  final bool success;
  final String message;
  final CheckInStatusData? data;
  final dynamic errors;

  const MonitoredCheckInStatusResponse({
    this.success = false,
    this.message = '',
    this.data,
    this.errors,
  });

  factory MonitoredCheckInStatusResponse.fromJson(Map<String, dynamic> json) {
    return MonitoredCheckInStatusResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map
          ? CheckInStatusData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
      errors: json['errors'],
    );
  }
}

class CheckInMonitoredUser {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String movementStatus;
  final String updatedAgo;

  const CheckInMonitoredUser({
    this.id = '',
    this.name = '',
    this.avatarUrl = '',
    this.isOnline = true,
    this.movementStatus = '',
    this.updatedAgo = '',
  });

  factory CheckInMonitoredUser.fromJson(Map<String, dynamic> json) {
    return CheckInMonitoredUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['user_name'] as String? ?? 'Emma',
      avatarUrl: json['avatar_url'] as String? ??
          json['avatar'] as String? ??
          json['image'] as String? ??
          '',
      isOnline: json['is_online'] as bool? ?? true,
      movementStatus: json['movement_status'] as String? ?? '',
      updatedAgo: json['updated_ago'] as String? ?? '',
    );
  }
}

class CheckInLocationData {
  final bool isAvailable;
  final String address;
  final double latitude;
  final double longitude;
  final String updatedAgo;

  const CheckInLocationData({
    this.isAvailable = false,
    this.address = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.updatedAgo = '',
  });

  factory CheckInLocationData.fromJson(Map<String, dynamic> json) {
    return CheckInLocationData(
      isAvailable: json['is_available'] as bool? ??
          (json['latitude'] != null && json['latitude'] != 0.0),
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      updatedAgo: json['updated_ago'] as String? ?? '',
    );
  }
}

class CheckInStatusData {
  final String state; // 'checked_in', 'not_set_up', 'missed'
  final CheckInMonitoredUser monitoredUser;
  final String statusBadge;
  final String badgeSubtext;
  final String note;
  final CheckInLocationData location;
  final String cardTitle;
  final String cardSubtitle;
  final String checkedInAtDisplay;

  const CheckInStatusData({
    this.state = 'checked_in',
    this.monitoredUser = const CheckInMonitoredUser(),
    this.statusBadge = '',
    this.badgeSubtext = '',
    this.note = '',
    this.location = const CheckInLocationData(),
    this.cardTitle = '',
    this.cardSubtitle = '',
    this.checkedInAtDisplay = '',
  });

  bool get isCheckedIn => state.toLowerCase() == 'checked_in';
  bool get isNotSetUp => state.toLowerCase() == 'not_set_up';
  bool get isMissed => state.toLowerCase() == 'missed';

  String get wardName =>
      monitoredUser.name.isNotEmpty ? monitoredUser.name : 'Emma';

  factory CheckInStatusData.fromJson(Map<String, dynamic> json) {
    return CheckInStatusData(
      state: json['state'] as String? ?? 'checked_in',
      monitoredUser: json['monitored_user'] != null &&
              json['monitored_user'] is Map
          ? CheckInMonitoredUser.fromJson(
              Map<String, dynamic>.from(json['monitored_user'] as Map),
            )
          : CheckInMonitoredUser(
              name: json['user_name'] as String? ?? 'Emma',
            ),
      statusBadge: json['status_badge'] as String? ?? '',
      badgeSubtext: json['badge_subtext'] as String? ?? '',
      note: json['note'] as String? ?? '',
      location: json['location'] != null && json['location'] is Map
          ? CheckInLocationData.fromJson(
              Map<String, dynamic>.from(json['location'] as Map),
            )
          : const CheckInLocationData(),
      cardTitle: json['card_title'] as String? ?? '',
      cardSubtitle: json['card_subtitle'] as String? ?? '',
      checkedInAtDisplay: json['checked_in_at_display'] as String? ??
          json['last_checked_in_display'] as String? ??
          json['last_check_in_display'] as String? ??
          '',
    );
  }
}
