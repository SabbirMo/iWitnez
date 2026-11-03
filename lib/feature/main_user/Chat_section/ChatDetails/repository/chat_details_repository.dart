import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/model/chat_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/chat_message_model.dart';

class ChatDetailsRepository {
  final ApiServices _apiServices;

  ChatDetailsRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// 1. Fetch Message History: `GET /api/v1/chat/conversations/<conversation_id>/messages/`
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await _apiServices.get(
        ApiEndPoints.chatMessages(conversationId),
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

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting messages: $e');
      rethrow;
    }
  }

  /// 2. Mark Conversation Messages as Read: `POST /api/v1/chat/conversations/<conversation_id>/read/`
  Future<bool> markAsRead(String conversationId) async {
    try {
      await _apiServices.post(
        ApiEndPoints.chatMarkRead(conversationId),
        data: {},
        requireAuth: true,
      );
      return true;
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
      return false;
    }
  }

  /// 3. Send Text Message: `POST /api/v1/chat/conversations/<conversation_id>/messages/`
  Future<ChatMessage?> sendTextMessage(
    String conversationId, {
    required String text,
  }) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.chatMessages(conversationId),
        data: {
          'message_type': 'text',
          'text': text,
        },
        requireAuth: true,
      );

      final dynamic data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : null;

      if (data is Map<String, dynamic>) {
        return ChatMessage.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error sending text message: $e');
      return null;
    }
  }

  /// 3. Send Live Location Pin: `POST /api/v1/chat/conversations/<conversation_id>/messages/`
  Future<ChatMessage?> sendLocationMessage(
    String conversationId, {
    required String text,
    required double latitude,
    required double longitude,
    required String locationAddress,
  }) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.chatMessages(conversationId),
        data: {
          'message_type': 'location',
          'text': text,
          'latitude': latitude,
          'longitude': longitude,
          'location_address': locationAddress,
        },
        requireAuth: true,
      );

      final dynamic data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : null;

      if (data is Map<String, dynamic>) {
        return ChatMessage.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error sending location message: $e');
      return null;
    }
  }

  /// 4. Upload Image/Media Attachment: `POST /api/v1/chat/conversations/<conversation_id>/attachments/`
  Future<ChatMessage?> uploadMediaMessage(
    String conversationId, {
    required String filePath,
    String text = '',
    String messageType = 'image',
  }) async {
    try {
      final fileName = filePath.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        if (text.isNotEmpty) 'text': text,
        'message_type': messageType,
      });

      debugPrint('[ChatDetailsRepo] Uploading media to ${ApiEndPoints.chatAttachments(conversationId)}');
      final response = await _apiServices.post(
        ApiEndPoints.chatAttachments(conversationId),
        data: formData,
        requireAuth: true,
      );

      final dynamic data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : null;

      if (data is Map<String, dynamic>) {
        return ChatMessage.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('[ChatDetailsRepo] Error uploading media message: $e');
      return null;
    }
  }

  /// 5. Starting a New Direct Chat from Contact Profile: `POST /api/v1/chat/conversations/direct/<target_user_id>/`
  Future<ConversationModel?> startDirectChat(String targetUserId) async {
    try {
      final response = await _apiServices.post(
        ApiEndPoints.chatDirect(targetUserId),
        data: {},
        requireAuth: true,
      );

      final dynamic data = response.data is Map
          ? (response.data['data'] ?? response.data)
          : null;

      if (data is Map<String, dynamic>) {
        return ConversationModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error starting direct chat: $e');
      return null;
    }
  }
}

final chatDetailsRepositoryProvider = Provider<ChatDetailsRepository>((ref) {
  return ChatDetailsRepository(ApiServices());
});
