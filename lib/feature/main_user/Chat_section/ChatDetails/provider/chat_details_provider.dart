import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/services/location_service.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/chat_message_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/repository/chat_details_repository.dart';

class ChatDetailsProvider extends ChangeNotifier {
  ChatDetailsProvider({ChatDetailsRepository? repository})
      : _repository = repository ?? ChatDetailsRepository();

  final ChatDetailsRepository _repository;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentChatId;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get currentChatId => _currentChatId;

  /// 1. Fetch Message History: `GET /api/v1/chat/conversations/<conversation_id>/messages/`
  /// 2. Mark Conversation Messages as Read: `POST /api/v1/chat/conversations/<conversation_id>/read/`
  Future<void> fetchMessages(String chatId) async {
    _currentChatId = chatId;
    _isLoading = true;
    notifyListeners();

    // Fire read receipt so unread count clears for this conversation
    _repository.markAsRead(chatId);

    try {
      final fetched = await _repository.getMessages(chatId);
      _messages = fetched;
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 3. Send Text Message: `POST /api/v1/chat/conversations/<conversation_id>/messages/`
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final optimistic = ChatMessage(
      text: trimmed,
      time: _nowFormatted(),
      isMe: true,
      status: MessageStatus.sent,
    );

    _messages = [..._messages, optimistic];
    notifyListeners();

    if (_currentChatId != null && _currentChatId!.isNotEmpty) {
      final sent = await _repository.sendTextMessage(
        _currentChatId!,
        text: trimmed,
      );
      if (sent != null) {
        final index = _messages.lastIndexOf(optimistic);
        if (index != -1) {
          _messages[index] = sent;
          notifyListeners();
        }
      }
    }
  }

  /// 3. Share Live Location Pin in Chat: `POST /api/v1/chat/conversations/<conversation_id>/messages/`
  Future<void> shareLiveLocation({
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    double lat = latitude ?? 0;
    double lng = longitude ?? 0;
    String locAddress = address ?? 'Here is my location';

    if (latitude == null || longitude == null) {
      final locResult = await const LocationService().getCurrentLocation();
      if (locResult.isSuccess && locResult.position != null) {
        lat = locResult.position!.latitude;
        lng = locResult.position!.longitude;
        locAddress =
            address ??
            'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
      }
    }

    final optimistic = ChatMessage(
      text: 'Here is my location',
      time: _nowFormatted(),
      isMe: true,
      type: MessageType.liveLocation,
      locationLabel: locAddress,
      latitude: lat != 0 ? lat : null,
      longitude: lng != 0 ? lng : null,
      locationAddress: locAddress,
      status: MessageStatus.sent,
    );

    _messages = [..._messages, optimistic];
    notifyListeners();

    if (_currentChatId != null && _currentChatId!.isNotEmpty) {
      final sent = await _repository.sendLocationMessage(
        _currentChatId!,
        text: 'Here is my location',
        latitude: lat,
        longitude: lng,
        locationAddress: locAddress,
      );
      if (sent != null) {
        final index = _messages.lastIndexOf(optimistic);
        if (index != -1) {
          _messages[index] = sent;
          notifyListeners();
        }
      }
    }
  }

  void sendImage(String filePath) {
    _messages = [
      ..._messages,
      ChatMessage(
        text: 'Photo',
        time: _nowFormatted(),
        isMe: true,
        type: MessageType.image,
        mediaPath: filePath,
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
}