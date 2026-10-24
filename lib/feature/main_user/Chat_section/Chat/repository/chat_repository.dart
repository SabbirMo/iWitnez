import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/network/api_endpoint/api_end_point.dart';
import 'package:iwitnez/core/network/service/api_services.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/model/chat_model.dart';

class ChatRepository {
  final ApiServices _apiServices;

  ChatRepository([ApiServices? apiServices])
      : _apiServices = apiServices ?? ApiServices();

  /// GET /api/v1/chat/conversations/
  /// Search Support: GET /api/v1/chat/conversations/?search={query}
  Future<List<ConversationModel>> getConversations({String? search}) async {
    final Map<String, dynamic> queryParameters = {};
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    final response = await _apiServices.get(
      ApiEndPoints.chatConversations,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
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
        .map((json) => ConversationModel.fromJson(json))
        .toList();
  }

  /// `POST /api/v1/chat/conversations/direct/<target_user_id>/`
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
    } catch (_) {
      return null;
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ApiServices());
});
