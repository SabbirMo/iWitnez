enum VerificationType { createAccount, forgotPassword }

class VerificationAgrs {
  final String? email;
  final VerificationType type;

  VerificationAgrs({this.email, required this.type});
}
