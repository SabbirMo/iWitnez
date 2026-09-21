import 'package:flutter_riverpod/legacy.dart';
import '../model/account_settings_model.dart';

class AccountSettingsController extends StateNotifier<AccountSettingsState> {
  AccountSettingsController() : super(AccountSettingsState.initial());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void toggleTwoFactor(bool value) {
    state = state.copyWith(isTwoFactorEnabled: value);
  }
}
