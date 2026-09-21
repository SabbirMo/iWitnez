import 'package:flutter_riverpod/legacy.dart';
import '../model/account_settings_model.dart';
import '../controller/account_settings_controller.dart';

final accountSettingsProvider =
    StateNotifierProvider<AccountSettingsController, AccountSettingsState>(
  (ref) => AccountSettingsController(),
);
