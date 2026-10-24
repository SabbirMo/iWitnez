class LiveLocationModel {
  final bool isSharingLive;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? durationDisplay;
  final String? updatedAgoDisplay;
  final int? batteryLevel;
  final String? movementStatus;
  final List<PeopleSharingModel> peopleSharing;

  const LiveLocationModel({
    this.isSharingLive = false,
    this.address,
    this.latitude,
    this.longitude,
    this.durationDisplay,
    this.updatedAgoDisplay,
    this.batteryLevel,
    this.movementStatus,
    this.peopleSharing = const [],
  });

  factory LiveLocationModel.fromJson(Map<String, dynamic> json) {
    final myLoc = json['my_location'] as Map<String, dynamic>?;

    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    final rawPeople = json['people_sharing'] as List<dynamic>?;
    final people = rawPeople != null
        ? rawPeople
            .whereType<Map<String, dynamic>>()
            .map((p) => PeopleSharingModel.fromJson(p))
            .toList()
        : <PeopleSharingModel>[];

    return LiveLocationModel(
      isSharingLive: json['is_sharing_live'] == true,
      durationDisplay: json['duration_display'] as String?,
      address: myLoc?['address'] as String?,
      latitude: parseCoord(myLoc?['latitude']),
      longitude: parseCoord(myLoc?['longitude']),
      batteryLevel: (myLoc?['battery_level'] as num?)?.toInt(),
      updatedAgoDisplay: myLoc?['updated_ago_display'] as String?,
      movementStatus: myLoc?['movement_status'] as String?,
      peopleSharing: people,
    );
  }

  LiveLocationModel copyWith({
    bool? isSharingLive,
    String? address,
    double? latitude,
    double? longitude,
    String? durationDisplay,
    String? updatedAgoDisplay,
    int? batteryLevel,
    String? movementStatus,
    List<PeopleSharingModel>? peopleSharing,
  }) {
    return LiveLocationModel(
      isSharingLive: isSharingLive ?? this.isSharingLive,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      durationDisplay: durationDisplay ?? this.durationDisplay,
      updatedAgoDisplay: updatedAgoDisplay ?? this.updatedAgoDisplay,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      movementStatus: movementStatus ?? this.movementStatus,
      peopleSharing: peopleSharing ?? this.peopleSharing,
    );
  }
}

class PeopleSharingModel {
  final String? id;
  final String? name;
  final String? email;
  final String? relationship;
  final String? avatarUrl;
  final String? distanceDisplay;
  final String? lastSeen;
  final bool isSelf;
  final bool isLive;
  final double? latitude;
  final double? longitude;

  const PeopleSharingModel({
    this.id,
    this.name,
    this.email,
    this.relationship,
    this.avatarUrl,
    this.distanceDisplay,
    this.lastSeen,
    this.isSelf = false,
    this.isLive = false,
    this.latitude,
    this.longitude,
  });

  factory PeopleSharingModel.fromJson(Map<String, dynamic> json) {
    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    return PeopleSharingModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      relationship: json['relationship'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      distanceDisplay: json['distance_display'] as String?,
      lastSeen: json['last_seen'] as String?,
      isSelf: json['is_self'] == true,
      isLive: json['is_live'] == true,
      latitude: parseCoord(json['latitude']),
      longitude: parseCoord(json['longitude']),
    );
  }
}
