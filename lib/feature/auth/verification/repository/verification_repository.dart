import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/auth/verification/model/verification_model.dart';

import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/utils/token_storage.dart';

class VerificationRepository {
  final ApiServices _apiServices;

  VerificationRepository(this._apiServices);

  Future<void> verifyEmail(VerificationModel request) async {
    final response = await _apiServices.post(
      ApiEndPoints.verifyEmail,
      data: request.toJson(),
      requireAuth: false,
    );

    try {
      final resData = response.data;
      if (resData is Map<String, dynamic>) {
        final data = resData['data'];
        final tokens = (data is Map<String, dynamic> ? data['tokens'] : null) ??
            (resData['tokens'] is Map<String, dynamic> ? resData['tokens'] : null);

        if (tokens is Map<String, dynamic>) {
          if (tokens['access'] != null) {
            await TokenStorage.saveAccessToken(tokens['access'].toString());
          }
          if (tokens['refresh'] != null) {
            await TokenStorage.saveRefreshToken(tokens['refresh'].toString());
          }
        } else if (data is Map<String, dynamic>) {
          if (data['access'] != null) {
            await TokenStorage.saveAccessToken(data['access'].toString());
          }
          if (data['refresh'] != null) {
            await TokenStorage.saveRefreshToken(data['refresh'].toString());
          }
        }

        String? role;
        if (data is Map<String, dynamic> &&
            data['user'] is Map<String, dynamic>) {
          role = data['user']['role'] as String?;
        } else if (resData['user'] is Map<String, dynamic>) {
          role = resData['user']['role'] as String?;
        }
        if (role != null && role.isNotEmpty) {
          await TokenStorage.saveUserRole(role);
        }
      }
    } catch (e) {
      debugPrint('[VerificationRepo] Could not extract token from response: $e');
    }
  }

  Future<void> verifyPasswordResetOtp(VerificationModel request) async {
    await _apiServices.post(
      ApiEndPoints.verifyPasswordOtp,
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
