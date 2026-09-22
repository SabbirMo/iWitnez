class TrustedContactModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String relationship;
  final bool emergencyAlerts;
  final String? avatarUrl;

  const TrustedContactModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.relationship,
    this.emergencyAlerts = true,
    this.avatarUrl,
  });

  TrustedContactModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? relationship,
    bool? emergencyAlerts,
    String? avatarUrl,
  }) {
    return TrustedContactModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
