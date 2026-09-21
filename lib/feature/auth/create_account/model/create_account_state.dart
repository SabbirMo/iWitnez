import 'package:iwitnez/core/constants/user_role/user_role.dart';

class CreateAccountState {
  final bool password;
  final bool confirmPassword;
  final bool termsAndConditions;
  final UserRole role;

  const CreateAccountState({
    this.password = false,
    this.confirmPassword = false,
    this.termsAndConditions = false,
    this.role = UserRole.mainUser,
  });

  CreateAccountState copyWith({
    bool? password,
    bool? confirmPassword,
    bool? termsAndConditions,
    UserRole? role,
  }) {
    return CreateAccountState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      role: role ?? this.role,
    );
  }
}
