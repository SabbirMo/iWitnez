class ManageSharingContactModel {
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? relationship;
  final String? avatarUrl;
  final bool isSharingEnabled;

  const ManageSharingContactModel({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.relationship,
    this.avatarUrl,
    this.isSharingEnabled = true,
  });

  factory ManageSharingContactModel.fromJson(Map<String, dynamic> json) {
    return ManageSharingContactModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      relationship: json['relationship'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isSharingEnabled: json['is_sharing_enabled'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'avatar_url': avatarUrl,
      'is_sharing_enabled': isSharingEnabled,
    };
  }

  ManageSharingContactModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? relationship,
    String? avatarUrl,
    bool? isSharingEnabled,
  }) {
    return ManageSharingContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSharingEnabled: isSharingEnabled ?? this.isSharingEnabled,
    );
  }
}

