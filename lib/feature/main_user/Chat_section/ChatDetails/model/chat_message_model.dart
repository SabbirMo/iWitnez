enum MessageType { text, liveLocation }

enum MessageStatus { sent, delivered, read }

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.locationLabel,
  });

  final String text;
  final String time; // pre-formatted e.g. "9:12 AM"
  final bool isMe;
  final MessageType type;
  final MessageStatus status;
  final String? locationLabel; // e.g. "View on map" subtitle for liveLocation type
}