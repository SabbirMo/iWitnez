enum MessageType { text, liveLocation, image }

enum MessageStatus { sent, delivered, read }

class ChatMessage {
  const ChatMessage({
    this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.locationLabel,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.mediaPath,
    this.senderId,
    this.senderName,
    this.senderAvatarUrl,
    this.conversationId,
  });

  final String? id;
  final String text;
  final String time; // pre-formatted e.g. "9:12 AM"
  final bool isMe;
  final MessageType type;
  final MessageStatus status;
  final String? locationLabel; // e.g. "1200 Park Ave, New York, NY" or "View on map"
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final String? mediaPath; // file path or network url
  final String? senderId;
  final String? senderName;
  final String? senderAvatarUrl;
  final String? conversationId;

  ChatMessage copyWith({
    String? id,
    String? text,
    String? time,
    bool? isMe,
    MessageType? type,
    MessageStatus? status,
    String? locationLabel,
    double? latitude,
    double? longitude,
    String? locationAddress,
    String? mediaPath,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? conversationId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      type: type ?? this.type,
      status: status ?? this.status,
      locationLabel: locationLabel ?? this.locationLabel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      mediaPath: mediaPath ?? this.mediaPath,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawType = json['message_type']?.toString().toLowerCase() ??
        json['type']?.toString().toLowerCase() ??
        'text';
    MessageType type = MessageType.text;
    if (rawType == 'location' || rawType == 'livelocation') {
      type = MessageType.liveLocation;
    } else if (rawType == 'image') {
      type = MessageType.image;
    }

    final isRead = json['is_read'] == true ||
        json['status']?.toString().toLowerCase() == 'read';
    final isMe = json['is_outgoing'] == true || json['is_me'] == true;

    final locationAddress = json['location_address']?.toString() ??
        json['locationLabel']?.toString() ??
        (type == MessageType.liveLocation ? 'View on map' : null);

    final double? lat = json['latitude'] != null
        ? (json['latitude'] is num
            ? (json['latitude'] as num).toDouble()
            : double.tryParse(json['latitude'].toString()))
        : null;

    final double? lng = json['longitude'] != null
        ? (json['longitude'] is num
            ? (json['longitude'] as num).toDouble()
            : double.tryParse(json['longitude'].toString()))
        : null;

    String formattedTime = json['formatted_time']?.toString() ??
        json['time']?.toString() ??
        '';

    if (formattedTime.isEmpty && json['created_at'] != null) {
      try {
        final dt = DateTime.parse(json['created_at'].toString()).toLocal();
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        formattedTime = '$hour:$minute $period';
      } catch (_) {}
    }

    return ChatMessage(
      id: json['id']?.toString(),
      text: json['text']?.toString() ?? '',
      time: formattedTime,
      isMe: isMe,
      type: type,
      status: isRead ? MessageStatus.read : MessageStatus.sent,
      locationLabel: locationAddress,
      latitude: lat,
      longitude: lng,
      locationAddress: locationAddress,
      mediaPath: json['media_url']?.toString() ??
          json['media_path']?.toString() ??
          json['mediaPath']?.toString(),
      senderId: json['sender_id']?.toString(),
      senderName: json['sender_name']?.toString(),
      senderAvatarUrl: json['sender_avatar_url']?.toString(),
      conversationId: json['conversation_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'text': text,
      'message_type': type == MessageType.liveLocation
          ? 'location'
          : (type == MessageType.image ? 'image' : 'text'),
      'formatted_time': time,
      'is_outgoing': isMe,
      'is_read': status == MessageStatus.read,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationAddress != null) 'location_address': locationAddress,
      if (mediaPath != null) 'media_url': mediaPath,
      if (senderId != null) 'sender_id': senderId,
      if (senderName != null) 'sender_name': senderName,
      if (senderAvatarUrl != null) 'sender_avatar_url': senderAvatarUrl,
      if (conversationId != null) 'conversation_id': conversationId,
    };
  }
}