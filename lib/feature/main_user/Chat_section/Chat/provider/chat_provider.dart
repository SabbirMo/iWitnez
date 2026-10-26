import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/model/chat_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/repository/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({ChatRepository? repository})
      : _repository = repository ?? ChatRepository() {
    _initListeners();
  }

  final ChatRepository _repository;

  List<ConversationModel> _conversations = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  static final StreamController<Map<String, dynamic>> _messageEventStream =
      StreamController<Map<String, dynamic>>.broadcast();

  static final StreamController<void> _refreshEventStream =
      StreamController<void>.broadcast();

  StreamSubscription? _messageSub;
  StreamSubscription? _refreshSub;

  List<ConversationModel> get chats => _conversations;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  /// Broadcast event when a new message is sent or received from any chat screen
  static void notifyNewMessage({
    required String chatId,
    required String text,
    required String formattedTime,
    String messageType = 'text',
    bool isOutgoing = true,
  }) {
    _messageEventStream.add({
      'chatId': chatId,
      'text': text,
      'formattedTime': formattedTime,
      'messageType': messageType,
      'isOutgoing': isOutgoing,
    });
  }

  /// Request conversation list to reload silently in background
  static void refreshChatList() {
    _refreshEventStream.add(null);
  }

  void _initListeners() {
    _messageSub = _messageEventStream.stream.listen((event) {
      final chatId = event['chatId'] as String?;
      final text = event['text'] as String?;
      final formattedTime = event['formattedTime'] as String?;
      final messageType = event['messageType'] as String? ?? 'text';
      final isOutgoing = event['isOutgoing'] as bool? ?? true;

      if (chatId != null && text != null && formattedTime != null) {
        updateLastMessageLocally(
          chatId: chatId,
          text: text,
          formattedTime: formattedTime,
          messageType: messageType,
          isOutgoing: isOutgoing,
        );
      }
    });

    _refreshSub = _refreshEventStream.stream.listen((_) {
      fetchChats(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        showLoading: false,
      );
    });
  }

  /// Updates last message in memory immediately without waiting for server reload
  void updateLastMessageLocally({
    required String chatId,
    required String text,
    required String formattedTime,
    String messageType = 'text',
    bool isOutgoing = true,
  }) {
    final index = _conversations.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final existing = _conversations[index];

      final previewText = switch (messageType) {
        'location' => '📍 Live Location',
        'image' => '📷 Photo',
        _ => text,
      };

      final updatedLastMessage = LastMessage(
        id: existing.lastMessage?.id ?? '',
        text: previewText,
        messageType: messageType,
        formattedTime: formattedTime,
        isOutgoing: isOutgoing,
        isRead: isOutgoing,
        createdAt: DateTime.now().toIso8601String(),
      );

      final updatedConversation = existing.copyWith(
        lastMessage: updatedLastMessage,
        lastMessageAt: DateTime.now().toIso8601String(),
        unreadCount: isOutgoing ? 0 : (existing.unreadCount + 1),
      );

      // Reorder conversation to the top
      _conversations.removeAt(index);
      _conversations.insert(0, updatedConversation);
      notifyListeners();
    } else {
      // If conversation wasn't found in current list, fetch from server
      fetchChats(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        showLoading: false,
      );
    }
  }

  /// Fetches conversation list from GET /api/v1/chat/conversations/
  /// or with query GET /api/v1/chat/conversations/?search={query}
  Future<void> fetchChats({String? search, bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final results = await _repository.getConversations(search: search);
      _conversations = results;
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Debounced server-side search using GET /api/v1/chat/conversations/?search={query}
  void search(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      fetchChats(search: query.isEmpty ? null : query, showLoading: false);
    });
  }

  void markAsRead(ConversationModel entry) {
    final index = _conversations.indexWhere((c) => c.id == entry.id);
    if (index == -1) return;
    _conversations[index] = entry.copyWith(unreadCount: 0);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _messageSub?.cancel();
    _refreshSub?.cancel();
    super.dispose();
  }
}
