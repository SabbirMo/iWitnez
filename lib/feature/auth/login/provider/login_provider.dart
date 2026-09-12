import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/auth/create_account/model/create_account_state.dart';

class LoginProvider extends Notifier<CreateAccountState> {
  @override
  CreateAccountState build() => CreateAccountState();

  void passwordToggle() {
    state = state.copyWith(password: !state.password);
  }
}

final loginProvider =
    NotifierProvider.autoDispose<LoginProvider, CreateAccountState>(
      LoginProvider.new,
    );
