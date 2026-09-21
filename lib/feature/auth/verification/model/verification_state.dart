import 'verification_type.dart';

class VerificationState {
  final String otp;
  final String email;
  final VerificationType type;
  final int codeLength;
  final int secondsRemaining;
  final bool canResend;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const VerificationState({
    this.otp = '',
    this.email = 'Examole@Email.Com',
    this.type = VerificationType.createAccount,
    this.codeLength = 4,
    this.secondsRemaining = 45,
    this.canResend = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  String get formattedTimer {
    final int minutes = secondsRemaining ~/ 60;
    final int seconds = secondsRemaining % 60;
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  VerificationState copyWith({
    String? otp,
    String? email,
    VerificationType? type,
    int? codeLength,
    int? secondsRemaining,
    bool? canResend,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VerificationState(
      otp: otp ?? this.otp,
      email: email ?? this.email,
      type: type ?? this.type,
      codeLength: codeLength ?? this.codeLength,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      canResend: canResend ?? this.canResend,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
