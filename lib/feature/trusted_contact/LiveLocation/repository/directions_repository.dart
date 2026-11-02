import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/directions_model.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/service/google_directions_service.dart';

final directionsRepositoryProvider = Provider<DirectionsRepository>((ref) {
  return DirectionsRepository();
});

class DirectionsRepository {
  final ApiServices _apiServices;
  final GoogleDirectionsService _googleDirectionsService;

  DirectionsRepository({
    ApiServices? apiServices,
    GoogleDirectionsService? googleDirectionsService,
  })  : _apiServices = apiServices ?? ApiServices(),
        _googleDirectionsService =
            googleDirectionsService ?? GoogleDirectionsService();

  bool _isDummyResponse(DirectionsData data, DirectionsRequest req) {
    if (req.originLatitude != 0.0 && req.originLongitude != 0.0) {
      final dist = PolylineDecoder.calculateDistanceKm(
        req.originLatitude,
        req.originLongitude,
        data.originLatitude,
        data.originLongitude,
      );
      if (dist > 100.0) return true;
    }
    if (data.destinationAddress.toLowerCase().contains('wall street') &&
        !req.destinationAddress.toLowerCase().contains('wall street')) {
      return true;
    }
    return false;
  }

  /// POST /api/v1/location/directions/
  /// Falls back to Google Maps Directions API if backend returns mock data or fails
  Future<DirectionsResponseModel> getDirections(
    DirectionsRequest request,
  ) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.locationDirections,
        data: request.toJson(),
        requireAuth: true,
      );

      if (response.data is Map<String, dynamic>) {
        final parsed = DirectionsResponseModel.fromJson(
          response.data as Map<String, dynamic>,
          request: request,
        );

        if (parsed.success &&
            parsed.data != null &&
            parsed.data!.routes.isNotEmpty &&
            !_isDummyResponse(parsed.data!, request)) {
          return parsed;
        }
      }
    } catch (e) {
      debugPrint('Backend directions failed: $e, using Google Directions API');
    }

    // Call Google Maps Directions API directly with real coordinates and mode
    try {
      return await _googleDirectionsService.getDirections(request);
    } catch (e) {
      debugPrint('Google Directions API error: $e');
      return const DirectionsResponseModel(
        success: false,
        message: 'Failed to calculate directions. Please try again.',
      );
    }
  }
}
