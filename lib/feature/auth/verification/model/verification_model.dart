class VerificationModel {
  final String email;
  final String otp;

  VerificationModel({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}

class ResendOtpModel {
  final String email;
  final String purpose;

  ResendOtpModel({
    required this.email,
    this.purpose = 'email_verification',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'purpose': purpose,
    };
  }
}
