import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';

enum UserRole { mainUser, trustedContact }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.mainUser:
        return AppString.mainUser;
      case UserRole.trustedContact:
        return AppString.trustedContact;
    }
  }

  String get subtitle {
    switch (this) {
      case UserRole.mainUser:
        return AppString.mainUserSubtitle;
      case UserRole.trustedContact:
        return AppString.trustedContactSubtitle;
    }
  }
}

class UserRoleProvider extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.mainUser;

  void set(UserRole role) {
    state = role;
  }
}

final userRoleProvider =
    NotifierProvider.autoDispose<UserRoleProvider, UserRole>(
  UserRoleProvider.new,
);
