import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/model/chat_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/repository/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({ChatRepository? repository})
    : _repository = repository ?? ChatRepository();

  final ChatRepository _repository;

  List<ConversationModel> _conversations = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  List<ConversationModel> get chats => _conversations;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

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
    super.dispose();
  }
}
