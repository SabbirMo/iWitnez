import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/add_trusted_contact/model/trusted_contact_model.dart';

class TrustedContactRepository {
  final ApiServices _apiServices;

  TrustedContactRepository([ApiServices? apiServices])
    : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/contacts/
  Future<List<TrustedContactModel>> fetchContacts() async {
    try {
      debugPrint('[TrustedContactRepo] GET ${ApiEndPoints.contacts}');
      final response = await _apiServices.get(
        ApiEndPoints.contacts,
        requireAuth: true,
      );

      List rawList = const [];
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final dataField = response.data['data'];
        if (dataField is List) {
          rawList = dataField;
        } else if (response.data['results'] is List) {
          rawList = response.data['results'] as List;
        }
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => TrustedContactModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[TrustedContactRepo] Error fetching contacts: $e');
      rethrow;
    }
  }

  /// POST /api/v1/contacts/
  Future<TrustedContactModel> addContact(
    TrustedContactModel contact, {
    String? avatarFilePath,
  }) async {
    try {
      dynamic payload;
      final bool hasAvatarFile =
          avatarFilePath != null &&
          avatarFilePath.isNotEmpty &&
          !avatarFilePath.startsWith('http') &&
          File(avatarFilePath).existsSync();

      if (hasAvatarFile) {
        final fileName = avatarFilePath.split(Platform.pathSeparator).last;
        payload = FormData.fromMap({
          'name': contact.fullName,
          'phone_number': contact.phoneNumber,
          'email': contact.email,
          'relationship': contact.relationship.toLowerCase().trim(),
          'circle': contact.circle.toLowerCase().trim(),
          'emergency_alerts_enabled': contact.emergencyAlerts,
          'avatar': await MultipartFile.fromFile(
            avatarFilePath,
            filename: fileName,
          ),
        });
      } else {
        payload = {
          'name': contact.fullName,
          'phone_number': contact.phoneNumber,
          'email': contact.email,
          'relationship': contact.relationship.toLowerCase().trim(),
          'circle': contact.circle.toLowerCase().trim(),
          'emergency_alerts_enabled': contact.emergencyAlerts,
          if (contact.avatarUrl != null &&
              contact.avatarUrl!.startsWith('http'))
            'avatar_url': contact.avatarUrl,
        };
      }

      debugPrint(
        '[TrustedContactRepo] POST ${ApiEndPoints.contacts} payload: $payload',
      );
      final response = await _apiServices.post(
        ApiEndPoints.contacts,
        data: payload,
        requireAuth: true,
      );

      final resData = response.data;
      if (resData is Map<String, dynamic>) {
        final dataField = resData['data'];
        if (dataField is Map<String, dynamic>) {
          return TrustedContactModel.fromJson(dataField);
        }
        return TrustedContactModel.fromJson(resData);
      }
      return contact;
    } catch (e) {
      debugPrint('[TrustedContactRepo] Error adding contact: $e');
      rethrow;
    }
  }

  /// PATCH /api/v1/contacts/{contact_id}/
  Future<TrustedContactModel> updateContact(
    String contactId,
    Map<String, dynamic> data, {
    String? avatarFilePath,
  }) async {
    try {
      final endpoint = '${ApiEndPoints.contacts}$contactId/';
      dynamic payload;
      final bool hasAvatarFile =
          avatarFilePath != null &&
          avatarFilePath.isNotEmpty &&
          !avatarFilePath.startsWith('http') &&
          File(avatarFilePath).existsSync();

      if (hasAvatarFile) {
        final fileName = avatarFilePath.split(Platform.pathSeparator).last;
        final mapData = Map<String, dynamic>.from(data);
        mapData['avatar'] = await MultipartFile.fromFile(
          avatarFilePath,
          filename: fileName,
        );
        payload = FormData.fromMap(mapData);
      } else {
        payload = data;
      }

      debugPrint('[TrustedContactRepo] PATCH $endpoint payload: $payload');
      final response = await _apiServices.patch(
        endpoint,
        data: payload,
        requireAuth: true,
      );

      final resData = response.data;
      if (resData is Map<String, dynamic>) {
        final dataField = resData['data'];
        if (dataField is Map<String, dynamic>) {
          return TrustedContactModel.fromJson(dataField);
        }
        return TrustedContactModel.fromJson(resData);
      }
      return TrustedContactModel.fromJson(data);
    } catch (e) {
      debugPrint('[TrustedContactRepo] Error updating contact $contactId: $e');
      rethrow;
    }
  }

  /// DELETE /api/v1/contacts/{contact_id}/
  Future<void> deleteContact(String contactId) async {
    try {
      final endpoint = '${ApiEndPoints.contacts}$contactId/';
      debugPrint('[TrustedContactRepo] DELETE $endpoint');
      await _apiServices.delete(endpoint, requireAuth: true);
    } catch (e) {
      debugPrint('[TrustedContactRepo] Error deleting contact $contactId: $e');
      rethrow;
    }
  }
}

final trustedContactRepositoryProvider = Provider<TrustedContactRepository>((
  ref,
) {
  return TrustedContactRepository();
});
