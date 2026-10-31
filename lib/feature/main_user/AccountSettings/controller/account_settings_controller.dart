import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';
import '../model/account_settings_model.dart';
import '../repository/account_settings_repository.dart';

class AccountSettingsController extends StateNotifier<AccountSettingsState> {
  final AccountSettingsRepository _repository;
  final ProfileRepository _profileRepository;

  AccountSettingsController({
    AccountSettingsRepository? repository,
    ProfileRepository? profileRepository,
  })  : _repository = repository ?? AccountSettingsRepository(),
        _profileRepository = profileRepository ?? ProfileRepository(),
        super(AccountSettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _profileRepository.getProfile();
      if (profile != null) {
        state = state.copyWith(
          email: profile.email,
          phone: profile.phoneNumber,
          isTwoFactorEnabled: profile.twoFactorEnabled,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('[AccountSettingsController] loadSettings error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleTwoFactor(BuildContext context) async {
    if (state.isToggling2FA) return;

    final target = !state.isTwoFactorEnabled;
    state = state.copyWith(isToggling2FA: true, errorMessage: null);

    try {
      final updated = await _repository.toggleTwoFactor(enabled: target);
      state = state.copyWith(
        isTwoFactorEnabled: updated,
        isToggling2FA: false,
      );
      _profileRepository.updateTwoFactorEnabled(updated);

      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: updated
              ? 'Two-factor authentication enabled'
              : 'Two-factor authentication disabled',
        );
      }
    } catch (e) {
      final errorMsg = ApiErrorHandler.getMessage(e);
      state = state.copyWith(
        isToggling2FA: false,
        errorMessage: errorMsg,
      );
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: errorMsg,
        );
      }
    }
  }

  Future<String?> deleteAccount({required String password}) async {
    try {
      final msg = await _repository.deleteAccount(password: password);
      _profileRepository.clearCache();
      return msg;
    } catch (e) {
      debugPrint('[AccountSettingsController] deleteAccount error: $e');
      rethrow;
    }
  }
}
