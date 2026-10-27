import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/model/calls_model.dart';

class CallsRepository {
  final ApiServices _apiServices;

  CallsRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// Fetch call logs with tab filtering ('all', 'missed', 'recent') and search
  /// GET /api/v1/calls/?tab={tab}&search={search}
  Future<List<CallRecordItem>> fetchCallHistory({
    String tab = 'all',
    String search = '',
  }) async {
    try {
      final queryParams = <String, dynamic>{'tab': tab};
      if (search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      debugPrint('[CallsRepo] Fetching calls with params: $queryParams');

      final res = await _apiServices.get(
        ApiEndPoints.calls,
        queryParameters: queryParams,
        requireAuth: true,
      );

      List rawList = const [];
      if (res.data is List) {
        rawList = res.data as List;
      } else if (res.data is Map) {
        final dataField = res.data['data'];
        if (dataField is List) {
          rawList = dataField;
        } else if (res.data['results'] is List) {
          rawList = res.data['results'] as List;
        }
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => CallRecordItem.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('[CallsRepo] Error fetching call history: $e');
      rethrow;
    }
  }

  /// Initiate an audio or video call
  /// POST /api/v1/calls/initiate/
  Future<String?> initiateCall({
    required String contactName,
    required String contactPhone,
    required String callType, // "audio" or "video"
    String? receiverId,
  }) async {
    try {
      final body = <String, dynamic>{
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'call_type': callType,
        if (receiverId != null && receiverId.isNotEmpty)
          'receiver_id': receiverId,
      };

      debugPrint('[CallsRepo] Initiating call with body: $body');

      final res = await _apiServices.post(
        ApiEndPoints.callsInitiate,
        data: body,
        requireAuth: true,
      );

      final dynamic data = res.data is Map
          ? (res.data['data'] ?? res.data)
          : null;

      if (data is Map<String, dynamic>) {
        return data['id']?.toString();
      }
      return null;
    } catch (e) {
      debugPrint('[CallsRepo] Error initiating call: $e');
      return null;
    }
  }

  /// End ongoing call with duration
  /// POST `/api/v1/calls/<callId>/end/`
  Future<bool> endCall(String callId, {int durationSeconds = 0}) async {
    try {
      debugPrint('[CallsRepo] Ending call $callId with duration: $durationSeconds');
      await _apiServices.post(
        ApiEndPoints.callEnd(callId),
        data: {
          'duration_seconds': durationSeconds,
        },
        requireAuth: true,
      );
      return true;
    } catch (e) {
      debugPrint('[CallsRepo] Error ending call $callId: $e');
      return false;
    }
  }

  /// Respond to incoming call
  /// POST `/api/v1/calls/<callId>/respond/`
  Future<bool> respondCall(String callId, {required bool accept}) async {
    try {
      await _apiServices.post(
        ApiEndPoints.callRespond(callId),
        data: {
          'action': accept ? 'accept' : 'decline',
        },
        requireAuth: true,
      );
      return true;
    } catch (e) {
      debugPrint('[CallsRepo] Error responding to call $callId: $e');
      return false;
    }
  }
}
