import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import '../model/check_in_page_model.dart';

class CheckInResult {
  final String message;
  final CheckInPageData? pageData;

  const CheckInResult({
    required this.message,
    this.pageData,
  });
}

class CheckInRepository {
  final ApiServices _apiServices;

  CheckInRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/emergency/check-ins/page/
  Future<CheckInPageData> getCheckInPage() async {
    final response = await _apiServices.get(
      ApiEndPoints.checkInPage,
      requireAuth: true,
    );

    final resData = response.data;
    if (resData is Map<String, dynamic> &&
        resData['data'] is Map<String, dynamic>) {
      return CheckInPageData.fromJson(
        resData['data'] as Map<String, dynamic>,
      );
    }
    return const CheckInPageData();
  }

  /// POST /api/v1/location/ping/
  /// Body: { "latitude": double, "longitude": double, "accuracy": double }
  Future<CheckInLocationData?> pingLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    final response = await _apiServices.post(
      ApiEndPoints.pingLocation,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
      },
      requireAuth: true,
    );

    final resData = response.data;
    if (resData is Map<String, dynamic> &&
        resData['data'] is Map<String, dynamic>) {
      final data = resData['data'] as Map<String, dynamic>;
      final rawLat = data['latitude'];
      final rawLng = data['longitude'];
      final rawAcc = data['accuracy'];

      final lat = rawLat is num
          ? rawLat.toDouble()
          : double.tryParse(rawLat?.toString() ?? '') ?? latitude;
      final lng = rawLng is num
          ? rawLng.toDouble()
          : double.tryParse(rawLng?.toString() ?? '') ?? longitude;
      final acc = rawAcc is num
          ? rawAcc.toDouble()
          : double.tryParse(rawAcc?.toString() ?? '') ?? accuracy;
      final addr = data['address'] as String? ?? '';

      return CheckInLocationData(
        latitude: lat,
        longitude: lng,
        address: addr,
        accuracy: acc,
        accuracyDisplay: 'Accuracy: ±${acc.toStringAsFixed(0)} m',
      );
    }
    return null;
  }

  /// POST /api/v1/emergency/check-ins/check-in-now/
  /// Body:
  /// {
  ///   "latitude": 23.780820,
  ///   "longitude": 90.407546,
  ///   "accuracy": 10.0,
  ///   "address": ""
  /// }
  Future<CheckInResult> checkInNow({
    required double latitude,
    required double longitude,
    required double accuracy,
    String address = '',
    String notes = "I'm Safe",
  }) async {
    final response = await _apiServices.post(
      ApiEndPoints.checkInNow,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'address': address,
        'notes': notes,
      },
      requireAuth: true,
    );

    final resData = response.data;
    String message = 'Check-in completed successfully. Stay Safe!';
    CheckInPageData? pageData;

    if (resData is Map<String, dynamic>) {
      final msg = resData['message'] as String?;
      if (msg != null && msg.isNotEmpty) {
        message = msg;
      }
      final data = resData['data'];
      if (data is Map<String, dynamic>) {
        final parsed = CheckInPageData.fromJson(data);
        pageData = parsed.copyWith(
          isCheckedInToday: true,
          screenState: 'completed',
          statusBadge: parsed.statusBadge.isNotEmpty ? parsed.statusBadge : 'Checked In',
        );
      }
    }

    return CheckInResult(message: message, pageData: pageData);
  }
}

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return CheckInRepository();
});
