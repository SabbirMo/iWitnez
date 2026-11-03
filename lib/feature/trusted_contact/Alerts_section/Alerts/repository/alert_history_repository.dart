import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/active_alert_model.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/alert_history_model.dart';

export 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/active_alert_model.dart';
export 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/model/alert_history_model.dart';

class AlertHistoryRepository {
  final ApiServices _apiServices;

  AlertHistoryRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/emergency/alerts/active/
  Future<ActiveAlertResponse> getActiveAlert() async {
    debugPrint('[AlertsRepository] GET ${ApiEndPoints.alertActive}');

    final response = await _apiServices.get(
      ApiEndPoints.alertActive,
      requireAuth: true,
    );

    debugPrint(
      '[AlertsRepository] Active alert status: ${response.statusCode}, Data: ${response.data}',
    );

    if (response.data is Map) {
      return ActiveAlertResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    return const ActiveAlertResponse(
      success: false,
      message: 'Invalid response format from server',
    );
  }

  /// GET /api/v1/emergency/alerts/history/?filter={filter}
  ///
  /// Query Params: ?filter=all (all, sos, video, audio)
  Future<AlertHistoryResponse> getAlertHistory({String filter = 'all'}) async {
    final cleanFilter = filter.toLowerCase().trim();
    final query = {
      'filter': cleanFilter.isEmpty ? 'all' : cleanFilter,
    };

    debugPrint(
      '[AlertHistoryRepository] GET ${ApiEndPoints.alertHistory} params: $query',
    );

    final response = await _apiServices.get(
      ApiEndPoints.alertHistory,
      queryParameters: query,
      requireAuth: true,
    );

    debugPrint(
      '[AlertHistoryRepository] History status: ${response.statusCode}, Data: ${response.data}',
    );

    if (response.data is Map) {
      return AlertHistoryResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    return const AlertHistoryResponse(
      success: false,
      message: 'Invalid response format from server',
      data: [],
    );
  }

  /// POST /api/v1/emergency/alerts/{alert_id}/acknowledge/
  Future<bool> acknowledgeAlert(String alertId) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.alertAcknowledge(alertId),
        data: {},
        requireAuth: true,
      );
      final dynamic resData = response.data;
      if (resData is Map) {
        return resData['success'] == true;
      }
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[AlertHistoryRepo] Error acknowledging alert $alertId: $e');
      return false;
    }
  }

  /// POST /api/v1/emergency/alerts/{alert_id}/resolve/
  Future<bool> resolveAlert(String alertId) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.alertResolve(alertId),
        data: {},
        requireAuth: true,
      );
      final dynamic resData = response.data;
      if (resData is Map) {
        return resData['success'] == true;
      }
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[AlertHistoryRepo] Error resolving alert $alertId: $e');
      return false;
    }
  }
}
