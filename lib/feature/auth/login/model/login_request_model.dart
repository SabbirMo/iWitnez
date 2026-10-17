class LoginRequestModel {
  final String email;
  final String password;
  final String? role;

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.role,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (role != null && role!.isNotEmpty) {
      data['role'] = role;
    }
    return data;
  }
}
