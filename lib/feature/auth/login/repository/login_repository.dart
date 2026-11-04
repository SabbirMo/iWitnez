import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/core/services/fcm_service.dart';
import 'package:iwitnez/core/utils/token_storage.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';
import 'package:iwitnez/feature/auth/login/model/login_request_model.dart';

class LoginRepository {
  final ApiServices _apiServices;

  LoginRepository(this._apiServices);

  Future<String?> login(LoginRequestModel request) async {
    final response = await _apiServices.post(
      ApiEndPoints.login,
      data: request.toJson(),
      requireAuth: false,
    );

    final resData = response.data?['data'];
    final tokens = resData?['tokens'];

    if (tokens != null) {
      await TokenStorage.saveAccessToken(tokens['access'] ?? '');
      await TokenStorage.saveRefreshToken(tokens['refresh'] ?? '');
    }

    final role = resData?['user']?['role'] as String?;
    if (role != null && role.isNotEmpty) {
      await TokenStorage.saveUserRole(role);
    }

    ProfileRepository().clearCache();

    return role;
  }

  Future<void> logout() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    try {
      // De-register push notification token from backend
      try {
        await FcmService.instance.unregisterDeviceToken();
      } catch (_) {}

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiServices.post(
          ApiEndPoints.logout,
          data: {'refresh': refreshToken},
          requireAuth: true,
        );
      }
    } catch (e) {
      // Even if API fails (e.g. offline), local tokens must still be cleared
    } finally {
      await TokenStorage.clearTokens();
      ProfileRepository().clearCache();
    }
  }
}

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  return LoginRepository(ApiServices());
});
