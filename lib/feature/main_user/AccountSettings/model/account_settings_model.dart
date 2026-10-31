import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';

/// Immutable state model for the Account Settings screen.
class AccountSettingsState {
  const AccountSettingsState({
    required this.email,
    required this.phone,
    required this.isTwoFactorEnabled,
    this.isLoading = false,
    this.isToggling2FA = false,
    this.errorMessage,
  });

  final String email;
  final String phone;
  final bool isTwoFactorEnabled;
  final bool isLoading;
  final bool isToggling2FA;
  final String? errorMessage;

  factory AccountSettingsState.initial() {
    final cached = ProfileRepository().cachedProfile;
    return AccountSettingsState(
      email: cached?.email ?? '',
      phone: cached?.phoneNumber ?? '',
      isTwoFactorEnabled: cached?.twoFactorEnabled ?? false,
    );
  }

  AccountSettingsState copyWith({
    String? email,
    String? phone,
    bool? isTwoFactorEnabled,
    bool? isLoading,
    bool? isToggling2FA,
    String? errorMessage,
  }) {
    return AccountSettingsState(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      isLoading: isLoading ?? this.isLoading,
      isToggling2FA: isToggling2FA ?? this.isToggling2FA,
      errorMessage: errorMessage,
    );
  }
}
