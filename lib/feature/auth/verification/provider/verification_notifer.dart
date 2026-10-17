import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/auth/verification/model/verification_model.dart';
import 'package:iwitnez/feature/auth/verification/repository/verification_repository.dart';

class VerificationNotifer extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<bool> verifyEmail({required String email, required String otp}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(verificationRepository);
      final model = VerificationModel(email: email, otp: otp);

      //call repository
      await repository.verifyEmail(model);
    });
    return !state.hasError;
  }

  Future<bool> resendOtp({
    required String email,
    String purpose = 'email_verification',
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(verificationRepository);
      final model = ResendOtpModel(email: email, purpose: purpose);

      await repository.resendOtp(model);
    });
    return !state.hasError;
  }
}

final verificationNotiferProvider =
    AsyncNotifierProvider<VerificationNotifer, void>(VerificationNotifer.new);
