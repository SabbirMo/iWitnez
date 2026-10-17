import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/auth/verification/model/verification_model.dart';

class VerificationRepository {
  final ApiServices _apiServices;

  VerificationRepository(this._apiServices);

  Future<void> verifyEmail(VerificationModel request) async {
    await _apiServices.post(
      ApiEndPoints.verifyEmail,
      data: request.toJson(),
      requireAuth: false,
    );
  }

  Future<void> resendOtp(ResendOtpModel request) async {
    await _apiServices.post(
      ApiEndPoints.resendOtp,
      data: request.toJson(),
      requireAuth: false,
    );
  }
}

final verificationRepository = Provider<VerificationRepository>((ref) {
  return VerificationRepository(ApiServices());
});
