import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/trusted_contact/CheckInStatus/model/check_in_status_model.dart';

export 'package:iwitnez/feature/trusted_contact/CheckInStatus/model/check_in_status_model.dart';

class CheckInStatusRepository {
  final ApiServices _apiServices;

  CheckInStatusRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/contacts/monitored/check-in-status/
  Future<MonitoredCheckInStatusResponse> getCheckInStatus() async {
    debugPrint(
      '[CheckInStatusRepository] GET ${ApiEndPoints.monitoredCheckInStatus}',
    );

    final response = await _apiServices.get(
      ApiEndPoints.monitoredCheckInStatus,
      requireAuth: true,
    );

    debugPrint(
      '[CheckInStatusRepository] Status: ${response.statusCode}, Data: ${response.data}',
    );

    if (response.data is Map) {
      return MonitoredCheckInStatusResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    return const MonitoredCheckInStatusResponse(
      success: false,
      message: 'Invalid response format from server',
    );
  }
}
