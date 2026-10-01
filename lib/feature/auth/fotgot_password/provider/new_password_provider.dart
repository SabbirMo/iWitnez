import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewPasswordState {
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isLoading;

  const NewPasswordState({
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.isLoading = false,
  });

  NewPasswordState copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isLoading,
  }) {
    return NewPasswordState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
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
}

final newPasswordProvider =
    NotifierProvider.autoDispose<NewPasswordProvider, NewPasswordState>(
      NewPasswordProvider.new,
    );
