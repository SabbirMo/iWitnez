import 'package:iwitnez/core/network/base_url/api_base_url.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/model/user_profile_response_model.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    required this.avatarUrl,
    this.isOnline = false,
    this.email = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.address = '',
    this.responseModel,
  });

  final String name;
  final String phone;
  final String avatarUrl;
  final bool isOnline;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String address;
  final UserProfileResponseModel? responseModel;

  factory UserProfile.fromResponse(UserProfileResponseModel model) {
    String avatar = model.profile?.avatarUrl ?? '';
    if (avatar.isEmpty && (model.profile?.avatar.isNotEmpty ?? false)) {
      final av = model.profile!.avatar;
      avatar = av.startsWith('http') ? av : '${ApiBaseUrl.baseUrl}$av';
    }

    return UserProfile(
      name: model.fullName.isNotEmpty ? model.fullName : 'User',
      phone: model.phoneNumber,
      avatarUrl: avatar,
      isOnline: model.isOnline,
      email: model.email,
      dateOfBirth: model.profile?.dateOfBirth ?? '',
      gender: model.profile?.genderDisplay.isNotEmpty == true
          ? model.profile!.genderDisplay
          : (model.profile?.gender ?? ''),
      address: model.profile?.address ?? '',
      responseModel: model,
    );
  }
}

enum ProfileMenuAction {
  personalInformation,
  accountSettings,
  safetySettings,
  notifications,
  trustedCircle,
  helpSupport,
  about,
  logOut,
}

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.action,
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  final ProfileMenuAction action;
  final String label;
  final dynamic icon; // IconData, kept dynamic to avoid importing material in model
  final bool isDestructive;
}
