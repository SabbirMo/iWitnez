class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.otherParticipant,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastMessageAt,
  });

  final String id;
  final OtherParticipant otherParticipant;
  final LastMessage? lastMessage;
  final int unreadCount;
  final String? lastMessageAt;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      otherParticipant: OtherParticipant.fromJson(
        (json['other_participant'] as Map<String, dynamic>?) ?? {},
      ),
      lastMessage:
          json['last_message'] != null &&
              json['last_message'] is Map<String, dynamic>
          ? LastMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] is int
          ? json['unread_count'] as int
          : (int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0),
      lastMessageAt: json['last_message_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'other_participant': otherParticipant.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'last_message_at': lastMessageAt,
    };
  }

  ConversationModel copyWith({
    String? id,
    OtherParticipant? otherParticipant,
    LastMessage? lastMessage,
    int? unreadCount,
    String? lastMessageAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      otherParticipant: otherParticipant ?? this.otherParticipant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  /// UI Field Mappings
  /// Contact Avatar: item['other_participant']['avatar_url']
  String get avatarUrl => otherParticipant.avatarUrl;

  /// Contact Name: item['other_participant']['full_name']
  String get name => otherParticipant.fullName;

  /// Last Message Preview: returns formatted preview including icon for photos/location
  String get lastMessagePreview {
    final msg = lastMessage;
    if (msg == null) return '';

    final type = msg.messageType.toLowerCase();
    final text = msg.text.trim();

    if (type == 'image') {
      return text.isNotEmpty && text.toLowerCase() != 'photo'
          ? '📷 $text'
          : '📷 Photo';
    } else if (type == 'location' || type == 'livelocation') {
      return text.isNotEmpty && text.toLowerCase() != 'live location'
          ? '📍 $text'
          : '📍 Live Location';
    } else if (type == 'file' || type == 'document') {
      return text.isNotEmpty ? '📄 $text' : '📄 File';
    } else if (type == 'audio' || type == 'voice') {
      return text.isNotEmpty ? '🎤 $text' : '🎤 Voice message';
    }

    return text.isNotEmpty ? text : '';
  }

  /// Timestamp: item['last_message']['formatted_time']
  String get formattedTime => lastMessage?.formattedTime ?? '';

  /// Participant online status
  bool get isOnline => otherParticipant.isOnline;
}

class OtherParticipant {
  const OtherParticipant({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl = '',
    this.isOnline = false,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String avatarUrl;
  final bool isOnline;

  factory OtherParticipant.fromJson(Map<String, dynamic> json) {
    return OtherParticipant(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      avatarUrl: json['avatar_url']?.toString() ?? '',
      isOnline: json['is_online'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
    };
  }
}

class LastMessage {
  const LastMessage({
    required this.id,
    this.text = '',
    this.messageType = 'text',
    this.formattedTime = '',
    this.isOutgoing = false,
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String text;
  final String messageType;
  final String formattedTime;
  final bool isOutgoing;
  final bool isRead;
  final String? createdAt;

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    final rawType =
        json['message_type']?.toString().toLowerCase() ??
        json['type']?.toString().toLowerCase() ??
        (json['attachment'] != null ||
                json['image_url'] != null ||
                json['attachment_url'] != null
            ? 'image'
            : 'text');

    String text = json['text']?.toString() ?? '';
    if (text.isEmpty) {
      if (rawType == 'image') {
        text = 'Photo';
      } else if (rawType == 'location' || rawType == 'livelocation') {
        text = 'Live Location';
      }
    }

    return LastMessage(
      id: json['id']?.toString() ?? '',
      text: text,
      messageType: rawType,
      formattedTime: json['formatted_time']?.toString() ?? '',
      isOutgoing: json['is_outgoing'] == true,
      isRead: json['is_read'] == true,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'message_type': messageType,
      'formatted_time': formattedTime,
      'is_outgoing': isOutgoing,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}
