import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/live_location_model.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/model/manage_sharing_model.dart';

final liveLocationRepositoryProvider = Provider<LiveLocationRepository>((ref) {
  return LiveLocationRepository(ApiServices());
});

class LiveLocationRepository {
  final ApiServices _apiServices;

  LiveLocationRepository(this._apiServices);

  /// 1. Page Load API: GET /api/v1/location/live/
  Future<LiveLocationModel?> getLiveLocation() async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.liveLocation,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return LiveLocationModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 2. Update Sharing Duration: POST /api/v1/location/live/
  /// Body: {"duration_type": "until_off" | "1_hour" | "8_hours"}
  Future<LiveLocationModel?> updateSharingDuration(String durationType) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.liveLocation,
        data: {'duration_type': durationType},
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return LiveLocationModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 3. Fetch Contact Visibility Toggle List: GET /api/v1/location/manage-sharing/
  Future<List<ManageSharingContactModel>> getManageSharingContacts() async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.locationManageSharing,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => ManageSharingContactModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// 4. Toggle Individual Contact Visibility: POST /api/v1/location/manage-sharing/
  /// Body: {"contact_id": "...", "is_sharing_enabled": true/false}
  Future<bool> toggleContactSharing({
    required String contactId,
    required bool isSharingEnabled,
  }) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.locationManageSharing,
        data: {
          'contact_id': contactId,
          'is_sharing_enabled': isSharingEnabled,
        },
        requireAuth: true,
      );

      return response.data?['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// 5. Confirm Stop Sharing: DELETE /api/v1/location/live/
  Future<bool> stopSharingLocation() async {
    try {
      final response = await _apiServices.delete(
        ApiEndPoints.liveLocation,
        requireAuth: true,
      );

      return response.data?['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
