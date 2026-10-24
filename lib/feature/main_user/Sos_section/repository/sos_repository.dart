import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';

class SosRepository {
  final ApiServices _apiServices;

  SosRepository(this._apiServices);

  /// Initiates emergency session and returns the alert UUID.
  Future<String?> startSos({
    required double latitude,
    required double longitude,
    required String address,
    int countdownSeconds = 10,
  }) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.sosStart,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'countdown_seconds': countdownSeconds,
        },
        requireAuth: true,
      );

      final data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : null;
      return data?['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Dispatches immediate alerts to all trusted contacts.
  Future<bool> activateSos(String alertId) async {
    try {
      await _apiServices.post(
        ApiEndPoints.sosActivate(alertId),
        data: {},
        requireAuth: true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cancels emergency alert during countdown.
  Future<bool> cancelSos(
    String alertId, {
    String reason = 'False alarm / Accidental tap',
  }) async {
    try {
      await _apiServices.post(
        ApiEndPoints.sosCancel(alertId),
        data: {
          'reason': reason,
        },
        requireAuth: true,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  return SosRepository(ApiServices());
});
