class TrustedContactModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String relationship;
  final String circle;
  final bool emergencyAlerts;
  final String? avatarUrl;

  const TrustedContactModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.relationship,
    this.circle = 'family',
    this.emergencyAlerts = true,
    this.avatarUrl,
  });

  static String defaultCircleFor(String? relationship) {
    if (relationship == null) return 'family';
    final r = relationship.toLowerCase().trim();
    if (r == 'friend' || r == 'friends') return 'friends';
    if (r == 'partner' || r == 'spouse') return 'partner';
    if (r == 'colleague' || r == 'work') return 'work';
    if (r == 'other') return 'other';
    return 'family';
  }

  factory TrustedContactModel.fromJson(Map<String, dynamic> json) {
    final rel = json['relationship'] as String? ?? 'other';
    final circleVal = json['circle'] as String? ?? defaultCircleFor(rel);

    return TrustedContactModel(
      id: json['id']?.toString(),
      fullName: json['name'] as String? ??
          json['full_name'] as String? ??
          json['fullName'] as String? ??
          '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ??
          json['phone'] as String? ??
          json['phoneNumber'] as String? ??
          '',
      relationship: rel,
      circle: circleVal,
      emergencyAlerts: json['emergency_alerts_enabled'] as bool? ??
          json['emergency_alerts'] as bool? ??
          json['emergencyAlerts'] as bool? ??
          true,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'relationship': relationship.toLowerCase().trim(),
      'circle': circle.toLowerCase().trim(),
      'emergency_alerts_enabled': emergencyAlerts,
      if (avatarUrl != null && avatarUrl!.startsWith('http'))
        'avatar_url': avatarUrl,
    };
  }

  TrustedContactModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? relationship,
    String? circle,
    bool? emergencyAlerts,
    String? avatarUrl,
  }) {
    return TrustedContactModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      circle: circle ?? this.circle,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
