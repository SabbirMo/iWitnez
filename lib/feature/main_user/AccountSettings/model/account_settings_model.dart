/// Immutable state model for the Account Settings screen.
class AccountSettingsState {
  const AccountSettingsState({
    required this.email,
    required this.phone,
    required this.isTwoFactorEnabled,
    this.isLoading = false,
  });

  final String email;
  final String phone;
  final bool isTwoFactorEnabled;
  final bool isLoading;

  factory AccountSettingsState.initial() => const AccountSettingsState(
        email: 'sarahkhan@email.com',
        phone: '+880 1712 345678',
        isTwoFactorEnabled: false,
      );

  AccountSettingsState copyWith({
    String? email,
    String? phone,
    bool? isTwoFactorEnabled,
    bool? isLoading,
  }) {
    return AccountSettingsState(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Actions available on the Account Settings screen.
enum AccountSettingAction {
  emailAddress,
  phoneNumber,
  password,
  twoFactorAuth,
  deleteAccount,
}
