import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/constants/user_role/user_role.dart';
import 'package:iwitnez/feature/auth/create_account/model/create_account_state.dart';

class LoginProvider extends Notifier<CreateAccountState> {
  @override
  CreateAccountState build() => CreateAccountState();

  void passwordToggle() {
    state = state.copyWith(password: !state.password);
  }

  void setRole(UserRole role) {
    state = state.copyWith(role: role);
  }
}

final loginProvider =
    NotifierProvider.autoDispose<LoginProvider, CreateAccountState>(
      LoginProvider.new,
    );
