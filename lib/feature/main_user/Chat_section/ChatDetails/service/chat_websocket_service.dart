import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:iwitnez/core/network/base_url/api_base_url.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/chat_message_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Real-Time Chat WebSocket Manager (chat_websocket_service.dart)
class ChatWebSocketService {
  WebSocket? _socket;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  String? _conversationId;
  String? _token;
  bool _isDisposed = false;
  bool _isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;

  // Streams for UI to listen to
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _readController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionEstablishedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<ChatMessage> get onNewMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onTypingStatus => _typingController.stream;
  Stream<Map<String, dynamic>> get onMessagesRead => _readController.stream;
  Stream<Map<String, dynamic>> get onConnectionEstablished =>
      _connectionEstablishedController.stream;

  bool get isConnected => _isConnected;

  /// Connects to WebSocket
  Future<void> connect({
    required String conversationId,
    required String jwtToken,
    String? baseUrl,
  }) async {
    if (_isDisposed) return;
    if (_isConnecting) return;
    _isConnecting = true;

    _conversationId = conversationId;
    _token = jwtToken;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (conversationId.isEmpty || jwtToken.isEmpty) {
      debugPrint('[ChatWS] Cannot connect: conversationId or token is empty');
      _isConnecting = false;
      return;
    }

    try {
      final wsBase = baseUrl ?? ApiBaseUrl.wsBaseUrl;
      final wsUrl = '$wsBase/ws/chat/$conversationId/?token=$jwtToken';
      debugPrint('[ChatWS] Connecting to: $wsUrl');

      _disconnectChannel();

      final socket = await WebSocket.connect(
        wsUrl,
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'iWitnez-App',
        },
      ).timeout(const Duration(seconds: 8));

      if (_isDisposed) {
        socket.close();
        _isConnecting = false;
        return;
      }

      _socket = socket;
      _channel = IOWebSocketChannel(socket);

      _subscription = _channel?.stream.listen(
        _handleIncomingData,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: true,
      );

      _reconnectAttempts = 0;
      _isConnected = true;
      _startPingTimer();
    } catch (e) {
      debugPrint('[ChatWS] Connection error: $e');
      _isConnected = false;
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _handleIncomingData(dynamic data) {
    try {
      final String text = data.toString();
      debugPrint('[ChatWS] Received: $text');
      final dynamic decoded = jsonDecode(text);

      if (decoded is! Map<String, dynamic>) return;

      final type = decoded['type']?.toString() ?? '';

      switch (type) {
        case 'connection_established':
          debugPrint('[ChatWS] Connection established confirmed by server');
          if (!_connectionEstablishedController.isClosed) {
            _connectionEstablishedController.add(decoded);
          }
          sendMarkRead();
          break;

        case 'new_message':
          final messageData = decoded['data'];
          if (messageData is Map<String, dynamic> &&
              !_messageController.isClosed) {
            _messageController.add(ChatMessage.fromJson(messageData));
          }
          break;

        case 'typing_status':
          if (!_typingController.isClosed) {
            _typingController.add(decoded);
          }
          break;

        case 'messages_read':
          if (!_readController.isClosed) {
            _readController.add(decoded);
          }
          break;

        default:
          debugPrint('[ChatWS] Unhandled message type: $type');
      }
    } catch (e) {
      debugPrint('[ChatWS] Failed to parse incoming message: $e');
    }
  }

  void _handleError(dynamic error) {
    if (_isDisposed) return;
    debugPrint('[ChatWS] Stream error: $error');
    _isConnected = false;
    _disconnectChannel();
    _scheduleReconnect();
  }

  void _handleDone() {
    if (_isDisposed) return;
    debugPrint('[ChatWS] Stream closed');
    _isConnected = false;
    _disconnectChannel();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    _reconnectAttempts++;
    final delaySeconds = (_reconnectAttempts * 3).clamp(3, 15);
    debugPrint(
      '[ChatWS] Scheduling reconnect in ${delaySeconds}s (attempt $_reconnectAttempts)...',
    );

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isDisposed &&
          _conversationId != null &&
          _token != null &&
          !_isConnected) {
        debugPrint('[ChatWS] Attempting reconnection...');
        connect(conversationId: _conversationId!, jwtToken: _token!);
      }
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_isConnected && _channel != null) {
        try {
          _sendRaw({'type': 'ping'});
        } catch (_) {}
      }
    });
  }

  void _sendRaw(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      final jsonString = jsonEncode(data);
      debugPrint('[ChatWS] Sending: $jsonString');
      _channel?.sink.add(jsonString);
    } else {
      debugPrint('[ChatWS] Cannot send message: not connected');
    }
  }

  /// Sends a text message
  bool sendTextMessage(String text) {
    if (!_isConnected) return false;
    _sendRaw({'action': 'send_message', 'message_type': 'text', 'text': text});
    return true;
  }

  /// Sends a live location card bubble
  bool sendLocationBubble({
    required double latitude,
    required double longitude,
    String address = 'View on map',
  }) {
    if (!_isConnected) return false;
    _sendRaw({
      'action': 'send_message',
      'message_type': 'location',
      'text': 'Live Location',
      'latitude': latitude,
      'longitude': longitude,
      'location_address': address,
    });
    return true;
  }

  /// Sends typing indicator
  void sendTyping(bool isTyping) {
    if (!_isConnected) return;
    _sendRaw({'action': 'typing', 'is_typing': isTyping});
  }

  /// Marks messages as read
  void sendMarkRead() {
    if (!_isConnected) return;
    _sendRaw({'action': 'mark_read'});
  }

  void _disconnectChannel() {
    _pingTimer?.cancel();
    _pingTimer = null;

    try {
      _subscription?.cancel();
    } catch (_) {}
    _subscription = null;

    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;

    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
  }

  /// Disconnects socket cleanly
  void disconnect() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnected = false;
    _disconnectChannel();
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _readController.close();
    _connectionEstablishedController.close();
  }
}
