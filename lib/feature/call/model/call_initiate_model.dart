class CallInitiateModel {
  final String id;
  final String callType; // "audio" | "video"
  final String receiverId;
  final String contactName;
  final String? contactPhone;
  final String status;
  final String? agoraChannelName;
  final String? agoraRtcToken;

  const CallInitiateModel({
    required this.id,
    required this.callType,
    required this.receiverId,
    required this.contactName,
    this.contactPhone,
    this.status = 'initiating',
    this.agoraChannelName,
    this.agoraRtcToken,
  });

  factory CallInitiateModel.fromJson(Map<String, dynamic> json) {
    return CallInitiateModel(
      id: json['id']?.toString() ?? '',
      callType: json['call_type']?.toString() ?? 'audio',
      receiverId: json['receiver_id']?.toString() ?? '',
      contactName: json['contact_name']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString(),
      status: json['status']?.toString() ?? 'initiating',
      agoraChannelName: json['agora_channel_name']?.toString(),
      agoraRtcToken: json['agora_rtc_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'call_type': callType,
      'receiver_id': receiverId,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'status': status,
      if (agoraChannelName != null) 'agora_channel_name': agoraChannelName,
      if (agoraRtcToken != null) 'agora_rtc_token': agoraRtcToken,
    };
  }
}
