class CreateAccountState {
  final bool password;
  final bool confirmPassword;
  final bool isLoading;
  final bool termsAndConditions;
  final String? errorMessage;
  final String? successMessage;

  const CreateAccountState({
    this.password = false,
    this.confirmPassword = false,
    this.isLoading = false,
    this.termsAndConditions = false,
    this.errorMessage,
    this.successMessage,
  });

  CreateAccountState copyWith({
    bool? password,
    bool? confirmPassword,
    bool? isLoading,
    bool? termsAndConditions,
    String? errorMessage,
    String? successMessage,
  }) {
    return CreateAccountState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
