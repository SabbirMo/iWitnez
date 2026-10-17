import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/auth/fotgot_password/model/reset_password_request_model.dart';
import 'package:iwitnez/feature/auth/fotgot_password/repository/forgot_password_repository.dart';

class NewPasswordState {
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isLoading;
  final Object? error;

  const NewPasswordState({
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
    this.error,
  });

  NewPasswordState copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isLoading,
    Object? error,
  }) {
    return NewPasswordState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NewPasswordProvider extends Notifier<NewPasswordState> {
  @override
  NewPasswordState build() => const NewPasswordState();

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(forgotPasswordRepositoryProvider);
      await repository.resetPassword(
        ResetPasswordRequestModel(
          email: email,
          otp: otp,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ),
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    }
  }
}

final newPasswordProvider =
    NotifierProvider.autoDispose<NewPasswordProvider, NewPasswordState>(
      NewPasswordProvider.new,
    );
