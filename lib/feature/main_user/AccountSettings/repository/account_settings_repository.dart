import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/core/utils/token_storage.dart';

class AccountSettingsRepository {
  final ApiServices _apiServices;

  AccountSettingsRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// POST /api/v1/auth/password/change/
  /// Body:
  /// {
  ///   "old_password": "...",
  ///   "new_password": "...",
  ///   "confirm_password": "..."
  /// }
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiServices.post(
      ApiEndPoints.changePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      requireAuth: true,
    );

    final resData = response.data;
    if (resData is Map<String, dynamic>) {
      // If server returned new tokens, store them
      final data = resData['data'];
      final tokens = (data is Map<String, dynamic> ? data['tokens'] : null) ??
          resData['tokens'];
      if (tokens is Map<String, dynamic>) {
        if (tokens['access'] is String) {
          await TokenStorage.saveAccessToken(tokens['access']);
        }
        if (tokens['refresh'] is String) {
          await TokenStorage.saveRefreshToken(tokens['refresh']);
        }
      }

      final msg = resData['message'] as String?;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
    }
    return 'Password changed successfully';
  }

  /// POST /api/v1/auth/account/2fa/toggle/
  /// Body:
  /// {
  ///   "enabled": true
  /// }
  Future<bool> toggleTwoFactor({required bool enabled}) async {
    final response = await _apiServices.post(
      ApiEndPoints.toggleTwoFactor,
      data: {
        'enabled': enabled,
      },
      requireAuth: true,
    );

    final resData = response.data;
    if (resData is Map<String, dynamic>) {
      final data = resData['data'];
      if (data is Map<String, dynamic>) {
        if (data.containsKey('two_factor_enabled')) {
          return data['two_factor_enabled'] == true;
        }
        if (data.containsKey('enabled')) {
          return data['enabled'] == true;
        }
      }
      if (resData.containsKey('two_factor_enabled')) {
        return resData['two_factor_enabled'] == true;
      }
      if (resData.containsKey('enabled')) {
        return resData['enabled'] == true;
      }
    }
    return enabled;
  }
}

final accountSettingsRepositoryProvider =
    Provider<AccountSettingsRepository>((ref) {
  return AccountSettingsRepository();
});

