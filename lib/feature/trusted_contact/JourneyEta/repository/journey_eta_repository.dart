import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/trusted_contact/JourneyEta/model/journey_eta_model.dart';

export 'package:iwitnez/feature/trusted_contact/JourneyEta/model/journey_eta_model.dart';

class JourneyEtaRepository {
  final ApiServices _apiServices;

  JourneyEtaRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/contacts/monitored/journey/
  ///
  /// Optional Query Params: `?date=YYYY-MM-DD` (e.g. 2024-05-15)
  Future<MonitoredJourneyResponse> getMonitoredJourney({
    String? date,
  }) async {
    Map<String, dynamic>? queryParams;
    if (date != null && date.trim().isNotEmpty) {
      queryParams = {'date': date.trim()};
    }

    debugPrint(
      '[JourneyEtaRepository] GET ${ApiEndPoints.monitoredJourney} params: $queryParams',
    );

    final response = await _apiServices.get(
      ApiEndPoints.monitoredJourney,
      queryParameters: queryParams,
      requireAuth: true,
    );

    debugPrint(
      '[JourneyEtaRepository] Status: ${response.statusCode}, Data: ${response.data}',
    );

    if (response.data is Map) {
      return MonitoredJourneyResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    return const MonitoredJourneyResponse(
      success: false,
      message: 'Invalid response format from server',
    );
  }
}

