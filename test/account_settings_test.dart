import 'package:flutter_test/flutter_test.dart';
import 'package:iwitnez/feature/main_user/AccountSettings/model/account_settings_model.dart';
import 'package:iwitnez/feature/main_user/AccountSettings/repository/account_settings_repository.dart';
import 'package:iwitnez/feature/main_user/AccountSettings/provider/change_password_provider.dart';

void main() {
  test('AccountSettingsState initial state test', () {
    final state = AccountSettingsState.initial();
    expect(state.isLoading, false);
    expect(state.isToggling2FA, false);
  });

  test('ChangePasswordState default state test', () {
    const state = ChangePasswordState();
    expect(state.isLoading, false);
    expect(state.isCurrentPasswordVisible, false);
    expect(state.isNewPasswordVisible, false);
    expect(state.isConfirmPasswordVisible, false);
  });
}

