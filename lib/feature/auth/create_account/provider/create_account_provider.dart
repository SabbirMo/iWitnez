import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/auth/create_account/model/create_account_state.dart';

class CreateAccountProvider extends Notifier<CreateAccountState> {
  @override
  CreateAccountState build() => CreateAccountState();

  void passwordToggle() {
    state = state.copyWith(password: !state.password);
  }

  void confirmPasswordToggle() {
    state = state.copyWith(confirmPassword: !state.confirmPassword);
  }

  void checkTermsAndConditions(bool value) {
    state = state.copyWith(termsAndConditions: value);
  }
}

final createAccountProvider =
    NotifierProvider.autoDispose<CreateAccountProvider, CreateAccountState>(
      CreateAccountProvider.new,
    );
