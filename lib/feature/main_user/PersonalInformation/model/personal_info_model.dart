class PersonalInfoModel {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String address;
  final String profileImageUrl;

  PersonalInfoModel({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.profileImageUrl,
  });

  // Method to create a copy with updated fields
  PersonalInfoModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? profileImageUrl,
  }) {
    return PersonalInfoModel(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}