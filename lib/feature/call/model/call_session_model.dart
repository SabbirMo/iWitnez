enum CallType {
  voice,
  video,
}

enum CallDirection {
  outgoing,
  incoming,
}

enum CallStatus {
  dialing,
  ringing,
  connected,
  ended,
}

class CallArguments {
  const CallArguments({
    required this.contactName,
    required this.avatarUrl,
    required this.callType,
    this.direction = CallDirection.outgoing,
    this.receiverId,
    this.contactPhone,
    this.callId,
  });

  final String contactName;
  final String avatarUrl;
  final CallType callType;
  final CallDirection direction;
  final String? receiverId;
  final String? contactPhone;
  final String? callId;
}
