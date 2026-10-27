class ContactProfileModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String relationship;
  final String relationshipDisplay;
  final String circle;
  final String circleDisplay;
  final String avatarUrl;
  final String linkedUser;
  final bool isRegisteredUser;
  final bool emergencyAlertsEnabled;
  final bool isOnline;
  final bool isSharingEnabled;

  const ContactProfileModel({
    required this.id,
    required this.name,
    this.email = '',
    this.phoneNumber = '',
    this.relationship = 'other',
    this.relationshipDisplay = 'Other',
    this.circle = 'family',
    this.circleDisplay = 'Family',
    this.avatarUrl = '',
    this.linkedUser = '',
    this.isRegisteredUser = false,
    this.emergencyAlertsEnabled = true,
    this.isOnline = true,
    this.isSharingEnabled = true,
  });

  factory ContactProfileModel.fromJson(Map<String, dynamic> json) {
    return ContactProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? 'other',
      relationshipDisplay:
          json['relationship_display']?.toString() ??
          json['relationship']?.toString() ??
          'Other',
      circle: json['circle']?.toString() ?? 'family',
      circleDisplay:
          json['circle_display']?.toString() ??
          json['circle']?.toString() ??
          'Family',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      linkedUser: json['linked_user']?.toString() ?? '',
      isRegisteredUser: json['is_registered_user'] == true,
      emergencyAlertsEnabled: json['emergency_alerts_enabled'] == true,
      isOnline: json['is_online'] == true,
      isSharingEnabled: json['is_sharing_enabled'] ?? true,
    );
  }

  ContactProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? relationship,
    String? relationshipDisplay,
    String? circle,
    String? circleDisplay,
    String? avatarUrl,
    String? linkedUser,
    bool? isRegisteredUser,
    bool? emergencyAlertsEnabled,
    bool? isOnline,
    bool? isSharingEnabled,
  }) {
    return ContactProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      relationshipDisplay: relationshipDisplay ?? this.relationshipDisplay,
      circle: circle ?? this.circle,
      circleDisplay: circleDisplay ?? this.circleDisplay,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      linkedUser: linkedUser ?? this.linkedUser,
      isRegisteredUser: isRegisteredUser ?? this.isRegisteredUser,
      emergencyAlertsEnabled:
          emergencyAlertsEnabled ?? this.emergencyAlertsEnabled,
      isOnline: isOnline ?? this.isOnline,
      isSharingEnabled: isSharingEnabled ?? this.isSharingEnabled,
    );
  }
}
