import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/trusted_contact/LiveLocation/model/monitored_live_location_model.dart';

final monitoredLiveLocationRepositoryProvider =
    Provider<MonitoredLiveLocationRepository>((ref) {
  return MonitoredLiveLocationRepository();
});

class MonitoredLiveLocationRepository {
  final ApiServices _apiServices;

  MonitoredLiveLocationRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/contacts/monitored/live-location/
  Future<MonitoredLiveLocationResponse> getLiveLocation() async {
    final response = await _apiServices.get(
      ApiEndPoints.monitoredLiveLocation,
      requireAuth: true,
    );

    if (response.data is Map<String, dynamic>) {
      return MonitoredLiveLocationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }

    return const MonitoredLiveLocationResponse(
      success: false,
      message: 'Invalid response from server',
    );
  }
}

