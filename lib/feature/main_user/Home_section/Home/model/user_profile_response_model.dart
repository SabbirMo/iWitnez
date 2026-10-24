class UserData {
  final String? fullName;
  final String? avatarUrl;
  final bool isProtected;

  const UserData({this.fullName, this.avatarUrl, this.isProtected = false});

  factory UserData.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final safety = json['safety_settings'];

    return UserData(
      fullName: json['full_name'] as String?,
      avatarUrl: profile is Map ? profile['avatar_url'] as String? : null,
      isProtected: safety is Map && safety['sos_alerts_enabled'] == true,
    );
  }

  String get firstName {
    if (fullName == null || fullName!.trim().isEmpty) return 'Emma';
    return fullName!.trim().split(' ').first;
  }
}
