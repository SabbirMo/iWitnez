import 'package:flutter/foundation.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/chat_message_model.dart';

class ChatDetailsProvider extends ChangeNotifier {
  List<ChatMessage> _messages = _dummyMessages;
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> fetchMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();

    // TODO: replace with real API/local-db call using chatId
    await Future.delayed(const Duration(milliseconds: 300));
    _messages = _dummyMessages;

    _isLoading = false;
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _messages = [
      ..._messages,
      ChatMessage(
        text: text.trim(),
        time: _nowFormatted(),
        isMe: true,
        status: MessageStatus.sent,
      ),
    ];
    notifyListeners();
  }

  void shareLiveLocation() {
    _messages = [
      ..._messages,
      ChatMessage(
        text: 'Live Location',
        time: _nowFormatted(),
        isMe: true,
        type: MessageType.liveLocation,
        locationLabel: 'View on map',
        status: MessageStatus.sent,
      ),
    ];
    notifyListeners();
  }

  String _nowFormatted() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static final List<ChatMessage> _dummyMessages = [
    const ChatMessage(text: 'Hi! How are you?', time: '9:12 AM', isMe: false),
    const ChatMessage(text: 'Where are you now?', time: '9:12 AM', isMe: false),
    const ChatMessage(
      text: "Hi! I'm good 😊",
      time: '9:13 AM',
      isMe: true,
      status: MessageStatus.read,
    ),
    const ChatMessage(
      text: "I'm at the cafe.",
      time: '9:13 AM',
      isMe: true,
      status: MessageStatus.read,
    ),
    const ChatMessage(
      text: 'Live Location',
      time: '9:14 AM',
      isMe: true,
      type: MessageType.liveLocation,
      locationLabel: 'View on map',
      status: MessageStatus.read,
    ),
    const ChatMessage(
      text: 'Great! Take care ❤️',
      time: '9:15 AM',
      isMe: false,
    ),
  ];
}