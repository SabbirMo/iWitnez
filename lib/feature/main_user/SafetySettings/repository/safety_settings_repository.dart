import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/SafetySettings/model/safety_settings_model.dart';

class SafetySettingsRepository {
  final ApiServices _apiServices;

  SafetySettingsRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/auth/safety-settings/
  Future<SafetySettingsModel?> getSafetySettings() async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.safetySettings,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return SafetySettingsModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('[SafetySettingsRepository] getSafetySettings error: $e');
      return null;
    }
  }

  /// PATCH /api/v1/auth/safety-settings/
  /// Body: send only the toggle(s) that changed
  Future<SafetySettingsModel?> updateSafetySettings(
    Map<String, dynamic> changedField,
  ) async {
    try {
      final response = await _apiServices.patch(
        ApiEndPoints.safetySettings,
        data: changedField,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return SafetySettingsModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('[SafetySettingsRepository] updateSafetySettings error: $e');
      rethrow;
    }
  }
}

final safetySettingsRepositoryProvider =
    Provider<SafetySettingsRepository>((ref) {
  return SafetySettingsRepository();
});

