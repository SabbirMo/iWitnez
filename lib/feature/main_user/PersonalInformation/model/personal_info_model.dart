import 'package:iwitnez/core/network/base_url/api_base_url.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/user_profile_response_model.dart';

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

  factory PersonalInfoModel.fromResponse(UserProfileResponseModel model) {
    String avatarUrl = model.profile?.avatarUrl ?? '';
    if (avatarUrl.isEmpty && (model.profile?.avatar.isNotEmpty ?? false)) {
      final av = model.profile!.avatar;
      avatarUrl = av.startsWith('http') ? av : '${ApiBaseUrl.baseUrl}$av';
    }

    String formattedDob = '';
    final dob = model.profile?.dateOfBirth ?? '';
    if (dob.isNotEmpty) {
      final parsed = DateTime.tryParse(dob.trim());
      if (parsed != null) {
        const monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        formattedDob =
            '${parsed.day} ${monthNames[parsed.month - 1]} ${parsed.year}';
      } else {
        formattedDob = dob;
      }
    }

    String gender = model.profile?.genderDisplay ?? '';
    if (gender.isEmpty && (model.profile?.gender.isNotEmpty ?? false)) {
      final g = model.profile!.gender;
      gender =
          g.isNotEmpty ? (g[0].toUpperCase() + g.substring(1).toLowerCase()) : '';
    }

    return PersonalInfoModel(
      fullName: model.fullName,
      phoneNumber: model.phoneNumber,
      email: model.email,
      dateOfBirth: formattedDob,
      gender: gender,
      address: model.profile?.address ?? '',
      profileImageUrl: avatarUrl,
    );
  }

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
