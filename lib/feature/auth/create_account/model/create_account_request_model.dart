import 'package:dio/dio.dart';

class CreateAccountRequestModel {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool terms;
  final String role;

  const CreateAccountRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.terms,
    required this.role,
  });

  // For Request send to the server as FormData if needed
  FormData toFormData() {
    return FormData.fromMap({
      "full_name": name,
      "email": email,
      "password": password,
      "confirm_password": confirmPassword,
      "terms_accepted": terms,
      "role": role,
    });
  }
}
