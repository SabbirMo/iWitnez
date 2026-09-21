import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/model/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatEntry> _chats = _dummyChats;
  bool _isLoading = false;
  String _searchQuery = '';

  List<ChatEntry> get chats => _searchQuery.isEmpty
      ? _chats
      : _chats
          .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  bool get isLoading => _isLoading;

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchChats() async {
    _isLoading = true;
    notifyListeners();

    // TODO: replace with real API/local-db call
    await Future.delayed(const Duration(milliseconds: 400));
    _chats = _dummyChats;

    _isLoading = false;
    notifyListeners();
  }

  void markAsRead(ChatEntry entry) {
    final index = _chats.indexOf(entry);
    if (index == -1) return;
    _chats[index] = ChatEntry(
      name: entry.name,
      avatarUrl: entry.avatarUrl,
      lastMessage: entry.lastMessage,
      time: entry.time,
      unreadCount: 0,
    );
    notifyListeners();
  }

  static final List<ChatEntry> _dummyChats = [
    const ChatEntry(
      name: 'Sarah Khan',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      lastMessage: 'See you soon!',
      time: '9:18 AM',
      unreadCount: 2,
    ),
    const ChatEntry(
      name: 'Ali Raza',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      lastMessage: "I'm on my way.",
      time: '8:45 AM',
    ),
    const ChatEntry(
      name: 'Mom',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      lastMessage: 'Be careful, take care ❤️',
      time: 'Yesterday',
      unreadCount: 1,
    ),
    const ChatEntry(
      name: 'Brother',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      lastMessage: 'Take care ❤️',
      time: 'Yesterday',
    ),
    const ChatEntry(
      name: 'Anika',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      lastMessage: 'Thanks!',
      time: 'Mon',
    ),
    const ChatEntry(
      name: 'Dad',
      avatarUrl: 'https://i.pravatar.cc/150?img=53',
      lastMessage: 'Call me when free.',
      time: 'Mon',
    ),
    const ChatEntry(
      name: 'Hira',
      avatarUrl: 'https://i.pravatar.cc/150?img=45',
      lastMessage: 'Okay, got it.',
      time: 'Sun',
    ),
    const ChatEntry(
      name: 'Rohan',
      avatarUrl: 'https://i.pravatar.cc/150?img=68',
      lastMessage: "Let's catch up later.",
      time: 'Sun',
    ),
  ];
}