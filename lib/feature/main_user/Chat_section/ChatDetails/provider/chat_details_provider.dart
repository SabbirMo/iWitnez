import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/core/services/location_service.dart';
import 'package:iwitnez/core/utils/token_storage.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/provider/chat_provider.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/chat_message_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/repository/chat_details_repository.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/service/chat_websocket_service.dart';

class ChatDetailsState {
  const ChatDetailsState({
    this.messages = const [],
    this.isOtherUserTyping = false,
    this.typingUserName,
  });

  final List<ChatMessage> messages;
  final bool isOtherUserTyping;
  final String? typingUserName;

  ChatDetailsState copyWith({
    List<ChatMessage>? messages,
    bool? isOtherUserTyping,
    String? typingUserName,
  }) {
    return ChatDetailsState(
      messages: messages ?? this.messages,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping,
      typingUserName: typingUserName ?? this.typingUserName,
    );
  }
}

class ChatDetailsNotifier extends AsyncNotifier<ChatDetailsState> {
  ChatDetailsNotifier(this.chatId);

  final String chatId;
  late final ChatDetailsRepository _repository;
  late final ChatWebSocketService _wsService;

  Timer? _otherTypingResetTimer;
  bool _isSendingTyping = false;
  Timer? _myTypingDebounceTimer;
  bool _isDisposed = false;
  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _readSub;
  StreamSubscription? _connSub;

  @override
  FutureOr<ChatDetailsState> build() async {
    _isDisposed = false;
    _repository = ref.read(chatDetailsRepositoryProvider);
    _wsService = ChatWebSocketService();

    // Auto-cleanup WebSocket and timers when leaving this conversation screen
    ref.onDispose(() {
      _isDisposed = true;
      _otherTypingResetTimer?.cancel();
      _myTypingDebounceTimer?.cancel();
      _msgSub?.cancel();
      _typingSub?.cancel();
      _readSub?.cancel();
      _connSub?.cancel();
      _wsService.dispose();
    });

    // 1. Fire initial read receipt via REST
    _repository.markAsRead(chatId);

    // 2. Fetch initial message history from REST API first
    List<ChatMessage> initialMessages = const [];
    try {
      initialMessages = await _repository.getMessages(chatId);
    } catch (e) {
      debugPrint('[ChatDetailsNotifier] Error fetching messages: $e');
    }

    // 3. Connect WebSocket ONLY AFTER initial state is ready
    if (!_isDisposed) {
      unawaited(_initWebSocket());
    }

    return ChatDetailsState(messages: initialMessages);
  }

  Future<void> _initWebSocket() async {
    if (_isDisposed) return;
    final token = await TokenStorage.getAccessToken();
    if (_isDisposed) return;
    if (token == null || token.isEmpty) {
      debugPrint('[ChatDetailsNotifier] No access token found for WebSocket');
      return;
    }

    _msgSub = _wsService.onNewMessage.listen((incoming) {
      if (_isDisposed) return;
      _handleIncomingMessage(incoming);
    });

    _typingSub = _wsService.onTypingStatus.listen((json) {
      if (_isDisposed) return;
      final senderName = json['sender_name']?.toString() ?? '';
      final isTyping = json['is_typing'] == true;
      _handleTypingStatus(senderName: senderName, isTyping: isTyping);
    });

    _readSub = _wsService.onMessagesRead.listen((_) {
      if (_isDisposed) return;
      _handleMessagesRead();
    });

    _connSub = _wsService.onConnectionEstablished.listen((_) {
      if (_isDisposed) return;
      debugPrint('[ChatDetailsNotifier] WS connection confirmed for $chatId');
    });

    await _wsService.connect(conversationId: chatId, jwtToken: token);
  }

  void _handleIncomingMessage(ChatMessage incoming) {
    if (_isDisposed) return;
    final current = state.value;
    if (current == null) return;

    // Stop showing typing indicator if message arrived
    _otherTypingResetTimer?.cancel();

    List<ChatMessage> updatedMessages = [...current.messages];

    // Check if message with same ID already exists
    if (incoming.id != null && incoming.id!.isNotEmpty) {
      final existingIndex = updatedMessages.indexWhere(
        (m) => m.id == incoming.id,
      );
      if (existingIndex != -1) {
        updatedMessages[existingIndex] = incoming;
        _notifyChatListUpdated(incoming);
        state = AsyncData(
          current.copyWith(messages: updatedMessages, isOtherUserTyping: false),
        );
        return;
      }
    }

    // Check if this incoming message matches our pending optimistic outgoing message
    if (incoming.isMe) {
      final pendingIndex = updatedMessages.lastIndexWhere(
        (m) =>
            m.isMe &&
            (m.id == null || m.id!.isEmpty) &&
            m.text == incoming.text &&
            m.type == incoming.type,
      );

      if (pendingIndex != -1) {
        updatedMessages[pendingIndex] = incoming;
        _notifyChatListUpdated(incoming);
        state = AsyncData(
          current.copyWith(messages: updatedMessages, isOtherUserTyping: false),
        );
        return;
      }
    }

    // Otherwise append new message
    updatedMessages.add(incoming);
    _notifyChatListUpdated(incoming);

    if (!incoming.isMe) {
      markAsRead();
    }

    state = AsyncData(
      current.copyWith(messages: updatedMessages, isOtherUserTyping: false),
    );
  }

  void _notifyChatListUpdated(ChatMessage message) {
    ChatProvider.notifyNewMessage(
      chatId: chatId,
      text: message.text,
      formattedTime: message.time.isNotEmpty ? message.time : _nowFormatted(),
      messageType: message.type == MessageType.liveLocation
          ? 'location'
          : (message.type == MessageType.image ? 'image' : 'text'),
      isOutgoing: message.isMe,
    );
  }

  void _handleTypingStatus({
    required String senderName,
    required bool isTyping,
  }) {
    if (_isDisposed) return;
    final current = state.value;
    if (current == null) return;

    _otherTypingResetTimer?.cancel();

    state = AsyncData(
      current.copyWith(
        isOtherUserTyping: isTyping,
        typingUserName: senderName.isNotEmpty ? senderName : null,
      ),
    );

    if (isTyping) {
      _otherTypingResetTimer = Timer(const Duration(milliseconds: 3500), () {
        if (_isDisposed) return;
        final val = state.value;
        if (val != null) {
          state = AsyncData(val.copyWith(isOtherUserTyping: false));
        }
      });
    }
  }

  void _handleMessagesRead() {
    if (_isDisposed) return;
    final current = state.value;
    if (current == null) return;

    bool hasChanges = false;
    final updatedList = current.messages.map((message) {
      if (message.isMe && message.status != MessageStatus.read) {
        hasChanges = true;
        return message.copyWith(status: MessageStatus.read);
      }
      return message;
    }).toList();

    if (hasChanges && !_isDisposed) {
      state = AsyncData(current.copyWith(messages: updatedList));
    }
  }

  /// Action 1: Send Text Message
  /// Optimistic UI update + WebSocket dispatch + REST fallback
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    sendTyping(false);

    final current = state.value ?? const ChatDetailsState();
    final time = _nowFormatted();
    final optimistic = ChatMessage(
      text: trimmed,
      time: time,
      isMe: true,
      status: MessageStatus.sent,
    );

    final updated = [...current.messages, optimistic];
    state = AsyncData(current.copyWith(messages: updated));

    _notifyChatListUpdated(optimistic);

    // Send over WebSocket
    final wsSent = _wsService.sendTextMessage(trimmed);
    if (!wsSent) {
      // Fallback to REST API
      final sent = await _repository.sendTextMessage(chatId, text: trimmed);
      if (sent != null) {
        final cur = state.value;
        if (cur != null) {
          final msgs = [...cur.messages];
          final idx = msgs.lastIndexOf(optimistic);
          if (idx != -1) {
            msgs[idx] = sent;
            _notifyChatListUpdated(sent);
            state = AsyncData(cur.copyWith(messages: msgs));
          }
        }
      }
    }
  }

  /// Action 2: Send Live Location Bubble (Map Pin Card)
  /// Optimistic UI update + WebSocket dispatch + REST fallback
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

    final time = _nowFormatted();
    final optimistic = ChatMessage(
      text: 'Live Location',
      time: time,
      isMe: true,
      type: MessageType.liveLocation,
      locationLabel: locAddress,
      latitude: lat != 0 ? lat : null,
      longitude: lng != 0 ? lng : null,
      locationAddress: locAddress,
      status: MessageStatus.sent,
    );

    final current = state.value ?? const ChatDetailsState();
    state = AsyncData(
      current.copyWith(messages: [...current.messages, optimistic]),
    );

    _notifyChatListUpdated(optimistic);

    final wsSent = _wsService.sendLocationBubble(
      latitude: lat,
      longitude: lng,
      address: locAddress,
    );

    if (!wsSent) {
      final sent = await _repository.sendLocationMessage(
        chatId,
        text: 'Live Location',
        latitude: lat,
        longitude: lng,
        locationAddress: locAddress,
      );
      if (sent != null) {
        final cur = state.value;
        if (cur != null) {
          final msgs = [...cur.messages];
          final idx = msgs.lastIndexOf(optimistic);
          if (idx != -1) {
            msgs[idx] = sent;
            _notifyChatListUpdated(sent);
            state = AsyncData(cur.copyWith(messages: msgs));
          }
        }
      }
    }
  }

  /// Action 3: Send Typing Status
  void sendTyping(bool isTyping) {
    if (isTyping) {
      if (!_isSendingTyping) {
        _isSendingTyping = true;
        _wsService.sendTyping(true);
      }
      _myTypingDebounceTimer?.cancel();
      _myTypingDebounceTimer = Timer(const Duration(seconds: 2), () {
        _isSendingTyping = false;
        _wsService.sendTyping(false);
      });
    } else {
      _myTypingDebounceTimer?.cancel();
      if (_isSendingTyping) {
        _isSendingTyping = false;
        _wsService.sendTyping(false);
      }
    }
  }

  /// Action 4: Mark Messages as Read
  void markAsRead() {
    _wsService.sendMarkRead();
    _repository.markAsRead(chatId);
  }

  void sendImage(String filePath) {
    final current = state.value ?? const ChatDetailsState();
    final time = _nowFormatted();
    final newMsg = ChatMessage(
      text: 'Photo',
      time: time,
      isMe: true,
      type: MessageType.image,
      mediaPath: filePath,
      status: MessageStatus.sent,
    );

    state = AsyncData(
      current.copyWith(messages: [...current.messages, newMsg]),
    );
    _notifyChatListUpdated(newMsg);
  }

  String _nowFormatted() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

final chatDetailsProvider = AsyncNotifierProvider.autoDispose
    .family<ChatDetailsNotifier, ChatDetailsState, String>(
      ChatDetailsNotifier.new,
    );
