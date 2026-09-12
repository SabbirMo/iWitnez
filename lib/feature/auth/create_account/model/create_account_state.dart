class CreateAccountState {
  final bool password;
  final bool confirmPassword;
  final bool termsAndConditions;

  const CreateAccountState({
    this.password = false,
    this.confirmPassword = false,
    this.termsAndConditions = false,
  });

  CreateAccountState copyWith({
    bool? password,
    bool? confirmPassword,
    bool? termsAndConditions,
  }) {
    return CreateAccountState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
    );
  }
}
