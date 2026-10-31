import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import '../repository/account_settings_repository.dart';

class ChangePasswordState {
  final bool isCurrentPasswordVisible;
  final bool isNewPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ChangePasswordState({
    this.isCurrentPasswordVisible = false,
    this.isNewPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ChangePasswordState copyWith({
    bool? isCurrentPasswordVisible,
    bool? isNewPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ChangePasswordState(
      isCurrentPasswordVisible:
          isCurrentPasswordVisible ?? this.isCurrentPasswordVisible,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ChangePasswordNotifier extends Notifier<ChangePasswordState> {
  late final AccountSettingsRepository _repository;

  @override
  ChangePasswordState build() {
    _repository = ref.watch(accountSettingsRepositoryProvider);
    return const ChangePasswordState();
  }

  void toggleCurrentPasswordVisibility() {
    state = state.copyWith(
      isCurrentPasswordVisible: !state.isCurrentPasswordVisible,
    );
  }

  void toggleNewPasswordVisibility() {
    state = state.copyWith(
      isNewPasswordVisible: !state.isNewPasswordVisible,
    );
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      final msg = await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: msg ?? 'Password changed successfully',
      );
      return true;
    } catch (e) {
      final msg = ApiErrorHandler.getMessage(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
      return false;
    }
  }
}

final changePasswordProvider =
    NotifierProvider.autoDispose<ChangePasswordNotifier, ChangePasswordState>(
  ChangePasswordNotifier.new,
);
