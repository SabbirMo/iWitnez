class UserProfileResponseModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String roleDisplay;
  final bool isOnline;
  final String appVersion;
  final bool isEmailVerified;
  final bool isActive;
  final bool termsAccepted;
  final bool twoFactorEnabled;
  final ProfileData? profile;
  final SafetySettingsData? safetySettings;

  const UserProfileResponseModel({
    this.id = '',
    this.email = '',
    this.fullName = '',
    this.phoneNumber = '',
    this.role = '',
    this.roleDisplay = '',
    this.isOnline = false,
    this.appVersion = '',
    this.isEmailVerified = false,
    this.isActive = false,
    this.termsAccepted = false,
    this.twoFactorEnabled = false,
    this.profile,
    this.safetySettings,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      role: json['role'] as String? ?? '',
      roleDisplay: json['role_display'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? false,
      appVersion: json['app_version'] as String? ?? '',
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
      termsAccepted: json['terms_accepted'] as bool? ?? false,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
      profile: json['profile'] is Map<String, dynamic>
          ? ProfileData.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      safetySettings: json['safety_settings'] is Map<String, dynamic>
          ? SafetySettingsData.fromJson(
              json['safety_settings'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  UserProfileResponseModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? role,
    String? roleDisplay,
    bool? isOnline,
    String? appVersion,
    bool? isEmailVerified,
    bool? isActive,
    bool? termsAccepted,
    bool? twoFactorEnabled,
    ProfileData? profile,
    SafetySettingsData? safetySettings,
  }) {
    return UserProfileResponseModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      roleDisplay: roleDisplay ?? this.roleDisplay,
      isOnline: isOnline ?? this.isOnline,
      appVersion: appVersion ?? this.appVersion,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      profile: profile ?? this.profile,
      safetySettings: safetySettings ?? this.safetySettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'role_display': roleDisplay,
      'is_online': isOnline,
      'app_version': appVersion,
      'is_email_verified': isEmailVerified,
      'is_active': isActive,
      'terms_accepted': termsAccepted,
      'two_factor_enabled': twoFactorEnabled,
      'profile': profile?.toJson(),
      'safety_settings': safetySettings?.toJson(),
    };
  }
}

class ProfileData {
  final String avatar;
  final String avatarUrl;
  final String dateOfBirth;
  final String gender;
  final String genderDisplay;
  final String address;
  final String relationship;

  const ProfileData({
    this.avatar = '',
    this.avatarUrl = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.genderDisplay = '',
    this.address = '',
    this.relationship = '',
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      avatar: json['avatar'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      genderDisplay: json['gender_display'] as String? ?? '',
      address: json['address'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
    );
  }

  ProfileData copyWith({
    String? avatar,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    String? genderDisplay,
    String? address,
    String? relationship,
  }) {
    return ProfileData(
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      genderDisplay: genderDisplay ?? this.genderDisplay,
      address: address ?? this.address,
      relationship: relationship ?? this.relationship,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'gender_display': genderDisplay,
      'address': address,
      'relationship': relationship,
    };
  }
}

class SafetySettingsData {
  final bool sosAlertsEnabled;
  final bool liveLocationEmergencyEnabled;
  final bool safePlacesAlertsEnabled;
  final bool safePlaceSuggestionsEnabled;
  final bool doNotDisturb;

  const SafetySettingsData({
    this.sosAlertsEnabled = false,
    this.liveLocationEmergencyEnabled = false,
    this.safePlacesAlertsEnabled = false,
    this.safePlaceSuggestionsEnabled = false,
    this.doNotDisturb = false,
  });

  factory SafetySettingsData.fromJson(Map<String, dynamic> json) {
    return SafetySettingsData(
      sosAlertsEnabled: json['sos_alerts_enabled'] as bool? ?? false,
      liveLocationEmergencyEnabled:
          json['live_location_emergency_enabled'] as bool? ?? false,
      safePlacesAlertsEnabled:
          json['safe_places_alerts_enabled'] as bool? ?? false,
      safePlaceSuggestionsEnabled:
          json['safe_place_suggestions_enabled'] as bool? ?? false,
      doNotDisturb: json['do_not_disturb'] as bool? ?? false,
    );
  }

  SafetySettingsData copyWith({
    bool? sosAlertsEnabled,
    bool? liveLocationEmergencyEnabled,
    bool? safePlacesAlertsEnabled,
    bool? safePlaceSuggestionsEnabled,
    bool? doNotDisturb,
  }) {
    return SafetySettingsData(
      sosAlertsEnabled: sosAlertsEnabled ?? this.sosAlertsEnabled,
      liveLocationEmergencyEnabled:
          liveLocationEmergencyEnabled ?? this.liveLocationEmergencyEnabled,
      safePlacesAlertsEnabled:
          safePlacesAlertsEnabled ?? this.safePlacesAlertsEnabled,
      safePlaceSuggestionsEnabled:
          safePlaceSuggestionsEnabled ?? this.safePlaceSuggestionsEnabled,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sos_alerts_enabled': sosAlertsEnabled,
      'live_location_emergency_enabled': liveLocationEmergencyEnabled,
      'safe_places_alerts_enabled': safePlacesAlertsEnabled,
      'safe_place_suggestions_enabled': safePlaceSuggestionsEnabled,
      'do_not_disturb': doNotDisturb,
    };
  }
}

