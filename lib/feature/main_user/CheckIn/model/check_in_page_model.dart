class CheckInLocationData {
  final double? latitude;
  final double? longitude;
  final String address;
  final double? accuracy;
  final String accuracyDisplay;

  const CheckInLocationData({
    this.latitude,
    this.longitude,
    this.address = '',
    this.accuracy,
    this.accuracyDisplay = '',
  });

  factory CheckInLocationData.fromJson(Map<String, dynamic> json) {
    return CheckInLocationData(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String? ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      accuracyDisplay: json['accuracy_display'] as String? ?? '',
    );
  }

  CheckInLocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    double? accuracy,
    String? accuracyDisplay,
  }) {
    return CheckInLocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      accuracy: accuracy ?? this.accuracy,
      accuracyDisplay: accuracyDisplay ?? this.accuracyDisplay,
    );
  }
}

class CheckInContactItem {
  final String id;
  final String name;
  final String circle;
  final String? avatarUrl;

  const CheckInContactItem({
    required this.id,
    required this.name,
    this.circle = '',
    this.avatarUrl,
  });

  factory CheckInContactItem.fromJson(Map<String, dynamic> json) {
    return CheckInContactItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      circle: json['circle'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class CheckInSharedWithData {
  final int totalCount;
  final int overflowCount;
  final int circlesCount;
  final String subtitle;
  final List<CheckInContactItem> contacts;

  const CheckInSharedWithData({
    this.totalCount = 0,
    this.overflowCount = 0,
    this.circlesCount = 0,
    this.subtitle = '',
    this.contacts = const [],
  });

  factory CheckInSharedWithData.fromJson(Map<String, dynamic> json) {
    final rawContacts = json['contacts'];
    final list = <CheckInContactItem>[];
    if (rawContacts is List) {
      for (final item in rawContacts) {
        if (item is Map<String, dynamic>) {
          list.add(CheckInContactItem.fromJson(item));
        }
      }
    }

    return CheckInSharedWithData(
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      overflowCount: (json['overflow_count'] as num?)?.toInt() ?? 0,
      circlesCount: (json['circles_count'] as num?)?.toInt() ?? 0,
      subtitle: json['subtitle'] as String? ?? '',
      contacts: list,
    );
  }
}

class ActiveCheckInData {
  final String id;
  final String title;
  final String? scheduledTime;
  final String? scheduledTimeDisplay;
  final String status;
  final String notes;

  const ActiveCheckInData({
    required this.id,
    this.title = 'Scheduled Safety Check-In',
    this.scheduledTime,
    this.scheduledTimeDisplay,
    this.status = 'pending',
    this.notes = '',
  });

  factory ActiveCheckInData.fromJson(Map<String, dynamic> json) {
    return ActiveCheckInData(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Scheduled Safety Check-In',
      scheduledTime: json['scheduled_time'] as String?,
      scheduledTimeDisplay: json['scheduled_time_display'] as String?,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String? ?? '',
    );
  }
}

class CheckInPageData {
  final bool isCheckedInToday;
  final String screenState;
  final bool hasActiveTimer;
  final String? checkInId;
  final String checkInTimeDisplay;
  final String statusBadge;
  final CheckInLocationData yourLocation;
  final CheckInSharedWithData sharedWith;
  final ActiveCheckInData? activeCheckIn;

  const CheckInPageData({
    this.isCheckedInToday = false,
    this.screenState = 'pending',
    this.hasActiveTimer = false,
    this.checkInId,
    this.checkInTimeDisplay = '',
    this.statusBadge = '',
    this.yourLocation = const CheckInLocationData(),
    this.sharedWith = const CheckInSharedWithData(),
    this.activeCheckIn,
  });

  bool get isCompleted =>
      isCheckedInToday ||
      screenState == 'completed' ||
      statusBadge == 'Checked In';

  factory CheckInPageData.fromJson(Map<String, dynamic> json) {
    final rawTime = json['check_in_time_display'] as String? ??
        json['checked_in_time_display'] as String? ??
        json['scheduled_time_display'] as String? ??
        '';

    return CheckInPageData(
      isCheckedInToday: json['is_checked_in_today'] as bool? ?? false,
      screenState: json['screen_state'] as String? ?? 'pending',
      hasActiveTimer: json['has_active_timer'] as bool? ?? false,
      checkInId: json['check_in_id']?.toString() ?? json['id']?.toString(),
      checkInTimeDisplay: rawTime,
      statusBadge: json['status_badge'] as String? ??
          (json['status'] == 'checked_in' ? 'Checked In' : ''),
      yourLocation: json['your_location'] is Map<String, dynamic>
          ? CheckInLocationData.fromJson(
              json['your_location'] as Map<String, dynamic>,
            )
          : const CheckInLocationData(),
      sharedWith: json['shared_with'] is Map<String, dynamic>
          ? CheckInSharedWithData.fromJson(
              json['shared_with'] as Map<String, dynamic>,
            )
          : const CheckInSharedWithData(),
      activeCheckIn: json['active_check_in'] is Map<String, dynamic>
          ? ActiveCheckInData.fromJson(
              json['active_check_in'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  CheckInPageData copyWith({
    bool? isCheckedInToday,
    String? screenState,
    bool? hasActiveTimer,
    String? checkInId,
    String? checkInTimeDisplay,
    String? statusBadge,
    CheckInLocationData? yourLocation,
    CheckInSharedWithData? sharedWith,
    ActiveCheckInData? activeCheckIn,
  }) {
    return CheckInPageData(
      isCheckedInToday: isCheckedInToday ?? this.isCheckedInToday,
      screenState: screenState ?? this.screenState,
      hasActiveTimer: hasActiveTimer ?? this.hasActiveTimer,
      checkInId: checkInId ?? this.checkInId,
      checkInTimeDisplay: checkInTimeDisplay ?? this.checkInTimeDisplay,
      statusBadge: statusBadge ?? this.statusBadge,
      yourLocation: yourLocation ?? this.yourLocation,
      sharedWith: sharedWith ?? this.sharedWith,
      activeCheckIn: activeCheckIn ?? this.activeCheckIn,
    );
  }
}
