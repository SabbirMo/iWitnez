import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';
import '../controller/account_settings_controller.dart';
import '../model/account_settings_model.dart';
import '../repository/account_settings_repository.dart';

final accountSettingsProvider =
    StateNotifierProvider<AccountSettingsController, AccountSettingsState>(
  (ref) {
    final repository = ref.watch(accountSettingsRepositoryProvider);
    final profileRepository = ref.watch(profileRepositoryProvider);
    return AccountSettingsController(
      repository: repository,
      profileRepository: profileRepository,
    );
  },
);
