import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/shareing/model/device_settings_model.dart';

class DeviceSettingsRepository {
  final ApiServices _apiServices;

  DeviceSettingsRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// PATCH /api/v1/auth/device-settings/
  Future<DeviceSettingsResponse> updateDeviceSettings(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('[DeviceSettingsRepo] PATCH ${ApiEndPoints.deviceSettings} payload: $data');
      final response = await _apiServices.patch(
        ApiEndPoints.deviceSettings,
        data: data,
        requireAuth: true,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return DeviceSettingsResponse.fromJson(responseData);
      }
      return DeviceSettingsResponse(
        success: true,
        message: 'Device permissions and settings updated successfully.',
      );
    } catch (e) {
      debugPrint('[DeviceSettingsRepo] Error updating device settings: $e');
      rethrow;
    }
  }
}

final deviceSettingsRepositoryProvider =
    Provider<DeviceSettingsRepository>((ref) {
  return DeviceSettingsRepository();
});
