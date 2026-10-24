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
      lastMessage: json['last_message'] != null &&
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

  /// Last Message Preview: item['last_message'] != null ? item['last_message']['text'] : ""
  String get lastMessagePreview => lastMessage?.text ?? '';

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
    return LastMessage(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? 'text',
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