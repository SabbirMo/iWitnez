import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/auth/fotgot_password/model/forgot_password_request_model.dart';

import 'package:iwitnez/feature/auth/fotgot_password/model/reset_password_request_model.dart';

class ForgotPasswordRepository {
  final ApiServices _apiServices;

  ForgotPasswordRepository(this._apiServices);

  Future<void> forgotPassword(ForgotPasswordRequestModel request) async {
    await _apiServices.post(
      ApiEndPoints.forgotPassword,
      data: request.toJson(),
      requireAuth: false,
    );
  }

  Future<void> resetPassword(ResetPasswordRequestModel request) async {
    await _apiServices.post(
      ApiEndPoints.resetPassword,
      data: request.toJson(),
      requireAuth: false,
    );
  }
}

final forgotPasswordRepositoryProvider =
    Provider<ForgotPasswordRepository>((ref) {
      return ForgotPasswordRepository(ApiServices());
    });
