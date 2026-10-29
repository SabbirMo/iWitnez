import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/location_history_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safety_tracking_model.dart';

final safetyTrackingRepositoryProvider =
    Provider<SafetyTrackingRepository>((ref) {
  return SafetyTrackingRepository(ApiServices());
});

class SafetyTrackingRepository {
  final ApiServices _apiServices;

  SafetyTrackingRepository(this._apiServices);

  /// 1. Fetch Safety Tracking Dashboard: GET /api/v1/location/safety-tracking/
  Future<SafetyTrackingData?> getSafetyTrackingDashboard() async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.safetyTracking,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return SafetyTrackingData.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 2. Toggle Location Sharing
  Future<bool> setLocationSharing(bool active) async {
    try {
      if (active) {
        final response = await _apiServices.post(
          ApiEndPoints.liveLocation,
          data: {'duration_type': 'until_off'},
          requireAuth: true,
        );
        return response.data?['success'] == true;
      } else {
        final response = await _apiServices.delete(
          ApiEndPoints.liveLocation,
          requireAuth: true,
        );
        return response.data?['success'] == true;
      }
    } catch (_) {
      return false;
    }
  }

  /// 3. Save Safe Place: POST /api/v1/location/safe-places/
  Future<SafePlaceModel?> addSafePlace({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String icon,
    bool alertsEnabled = true,
  }) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.safePlaces,
        data: {
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'radius_meters': radiusMeters,
          'icon': icon,
          'alerts_enabled': alertsEnabled,
        },
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return SafePlaceModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 4. Get Single Safe Place Details: GET /api/v1/location/safe-places/{id}/
  Future<SafePlaceModel?> getSafePlaceDetails(String id) async {
    try {
      final response = await _apiServices.get(
        '${ApiEndPoints.safePlaces}$id/',
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return SafePlaceModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 5. Edit Safe Place / Change Radius: PATCH /api/v1/location/safe-places/{id}/
  Future<SafePlaceModel?> updateSafePlace(
    String id, {
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    String? icon,
    bool? alertsEnabled,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (address != null) payload['address'] = address;
      if (latitude != null) payload['latitude'] = latitude;
      if (longitude != null) payload['longitude'] = longitude;
      if (radiusMeters != null) payload['radius_meters'] = radiusMeters;
      if (icon != null) payload['icon'] = icon;
      if (alertsEnabled != null) payload['alerts_enabled'] = alertsEnabled;

      final response = await _apiServices.patch(
        '${ApiEndPoints.safePlaces}$id/',
        data: payload,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return SafePlaceModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 6. Remove Safe Place: DELETE /api/v1/location/safe-places/{id}/
  Future<bool> deleteSafePlace(String id) async {
    try {
      final response = await _apiServices.delete(
        '${ApiEndPoints.safePlaces}$id/',
        requireAuth: true,
      );
      return response.data?['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// 7. Location History: GET /api/v1/location/history/?date=YYYY-MM-DD
  Future<LocationHistoryData?> getLocationHistory([String? date]) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      final response = await _apiServices.get(
        ApiEndPoints.locationHistory,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        requireAuth: true,
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return LocationHistoryData.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
