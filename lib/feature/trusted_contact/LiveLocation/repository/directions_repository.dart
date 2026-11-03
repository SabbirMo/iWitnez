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
  }) : _apiServices = apiServices ?? ApiServices(),
       _googleDirectionsService =
           googleDirectionsService ?? GoogleDirectionsService();

  /// POST /api/v1/location/directions/
  /// Uses backend real OSRM road routing, falling back to Google Directions API on error
  Future<DirectionsResponseModel> getDirections(
    DirectionsRequest request,
  ) async {
    try {
      debugPrint(
        '[DirectionsRepo] POST ${ApiEndPoints.locationDirections} body: ${request.toJson()}',
      );
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
            parsed.data!.routes.isNotEmpty) {
          debugPrint(
            '[DirectionsRepo] Real route received from backend with ${parsed.data!.routes.length} routes.',
          );
          return parsed;
        }
      }
    } catch (e) {
      debugPrint(
        'Backend directions failed: $e, using Google Directions API fallback',
      );
    }

    // Call Google Maps Directions API fallback directly
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
