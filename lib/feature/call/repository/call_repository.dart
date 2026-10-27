import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/call/model/call_initiate_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/contact_profile_model.dart';

class CallRepository {
  final ApiServices _apiServices;

  CallRepository([ApiServices? apiServices])
    : _apiServices = apiServices ?? ApiServices();

  /// 1. Initiate Audio or Video Call:
  /// POST /api/v1/calls/initiate/
  /// Payload: { "call_type": "audio"|"video", "receiver_id": "...", "contact_name": "...", "contact_phone": "..." }
  Future<CallInitiateModel?> initiateCall({
    required String callType,
    required String receiverId,
    required String contactName,
    String? contactPhone,
  }) async {
    try {
      final body = {
        'call_type': callType,
        'receiver_id': receiverId,
        'contact_name': contactName,
        if (contactPhone != null && contactPhone.isNotEmpty)
          'contact_phone': contactPhone,
      };

      debugPrint('[CallRepo] Initiating $callType call with body: $body');

      final response = await _apiServices.post(
        ApiEndPoints.callsInitiate,
        data: body,
        requireAuth: true,
      );

      final dynamic data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : null;

      if (data is Map<String, dynamic>) {
        return CallInitiateModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('[CallRepo] Error initiating call: $e');
      return null;
    }
  }

  /// 2. Respond to incoming call:
  /// `POST /api/v1/calls/<id>/respond/`
  /// Payload: { "action": "accept"|"decline" }
  Future<bool> respondCall(String callId, {required String action}) async {
    try {
      await _apiServices.post(
        ApiEndPoints.callRespond(callId),
        data: {'action': action},
        requireAuth: true,
      );
      return true;
    } catch (e) {
      debugPrint('[CallRepo] Error responding to call $callId: $e');
      return false;
    }
  }

  /// 3. End Call:
  /// `POST /api/v1/calls/<id>/end/`
  Future<bool> endCall(String callId) async {
    try {
      debugPrint('[CallRepo] Ending call $callId');
      await _apiServices.post(
        ApiEndPoints.callEnd(callId),
        data: {},
        requireAuth: true,
      );
      return true;
    } catch (e) {
      debugPrint('[CallRepo] Error ending call $callId: $e');
      return false;
    }
  }

  /// 4. Fetch Contact Profile Details:
  /// `GET /api/v1/contacts/<contact_id>/`
  Future<ContactProfileModel?> getContactProfile(String contactId) async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.contactDetails(contactId),
        requireAuth: true,
      );

      final dynamic data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : null;

      if (data is Map<String, dynamic>) {
        return ContactProfileModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('[CallRepo] Error fetching contact profile: $e');
      return null;
    }
  }

  /// 5. Change Member's Circle ("Family >" row):
  /// `POST /api/v1/contacts/<contact_id>/move/`
  /// Body: { "circle": "family"|"friends"|"partner"|"work"|"other" }
  Future<bool> moveCircle({
    required String contactId,
    required String circle,
  }) async {
    try {
      debugPrint('[CallRepo] Moving contact $contactId to circle $circle');
      final response = await _apiServices.post(
        ApiEndPoints.contactMove(contactId),
        data: {'circle': circle.toLowerCase()},
        requireAuth: true,
      );

      final success = response.data is Map
          ? (response.data['success'] == true)
          : response.statusCode == 200 || response.statusCode == 201;
      return success;
    } catch (e) {
      debugPrint('[CallRepo] Error moving contact circle: $e');
      return false;
    }
  }

  /// 6. Location Sharing Toggle:
  /// POST /api/v1/location/manage-sharing/
  /// Body: { "contact_id": "...", "is_sharing_enabled": true }
  Future<bool> manageLocationSharing({
    required String contactId,
    required bool isSharingEnabled,
  }) async {
    try {
      debugPrint(
        '[CallRepo] Managing location sharing for $contactId: $isSharingEnabled',
      );
      final response = await _apiServices.post(
        ApiEndPoints.locationManageSharing,
        data: {'contact_id': contactId, 'is_sharing_enabled': isSharingEnabled},
        requireAuth: true,
      );

      final success = response.data is Map
          ? (response.data['success'] == true)
          : response.statusCode == 200 || response.statusCode == 201;
      return success;
    } catch (e) {
      debugPrint('[CallRepo] Error managing location sharing: $e');
      return false;
    }
  }

  /// 7. Helper to resolve contact_id from contacts list by receiverId or name
  Future<String?> findContactId({String? receiverId, String? name}) async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.contacts,
        requireAuth: true,
      );
      List rawList = const [];
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final dynamic dataField = response.data['data'];
        if (dataField is List) {
          rawList = dataField;
        } else if (response.data['results'] is List) {
          rawList = response.data['results'] as List;
        }
      }

      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          final id = item['id']?.toString() ?? '';
          final linked = item['linked_user']?.toString() ?? '';
          final contactName = item['name']?.toString() ?? '';
          if (receiverId != null &&
              receiverId.isNotEmpty &&
              linked == receiverId) {
            return id;
          }
          if (name != null &&
              name.isNotEmpty &&
              contactName.toLowerCase() == name.toLowerCase()) {
            return id;
          }
        }
      }
    } catch (e) {
      debugPrint('[CallRepo] Error finding contactId: $e');
    }
    return null;
  }
}
