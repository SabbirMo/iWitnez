class CallInitiateModel {
  final String id;
  final String callType; // "audio" | "video"
  final String? receiverId;
  final String contactName;
  final String? contactPhone;
  final String? contactAvatarUrl;
  final String status;
  final int durationSeconds;
  final String formattedDuration;
  final bool isOutgoing;
  final String? agoraAppId;
  final String? agoraChannelName;
  final String? agoraRtcToken;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const CallInitiateModel({
    required this.id,
    required this.callType,
    this.receiverId,
    required this.contactName,
    this.contactPhone,
    this.contactAvatarUrl,
    this.status = 'initiating',
    this.durationSeconds = 0,
    this.formattedDuration = '00:00',
    this.isOutgoing = true,
    this.agoraAppId,
    this.agoraChannelName,
    this.agoraRtcToken,
    this.startedAt,
    this.endedAt,
  });

  bool get isVideo => callType.toLowerCase() == 'video';

  factory CallInitiateModel.fromJson(Map<String, dynamic> json) {
    return CallInitiateModel(
      id: json['id']?.toString() ?? '',
      callType: json['call_type']?.toString().toLowerCase() ?? 'audio',
      receiverId: json['receiver_id']?.toString(),
      contactName: json['contact_name']?.toString() ?? 'Unknown',
      contactPhone: json['contact_phone']?.toString(),
      contactAvatarUrl: json['contact_avatar_url']?.toString(),
      status: json['status']?.toString().toLowerCase() ?? 'initiating',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      formattedDuration: json['formatted_duration']?.toString() ?? '00:00',
      isOutgoing: json['is_outgoing'] == true,
      agoraAppId: json['agora_app_id']?.toString(),
      agoraChannelName: json['agora_channel_name']?.toString(),
      agoraRtcToken: json['agora_rtc_token']?.toString(),
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'call_type': callType,
      'receiver_id': receiverId,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_avatar_url': contactAvatarUrl,
      'status': status,
      'duration_seconds': durationSeconds,
      'formatted_duration': formattedDuration,
      'is_outgoing': isOutgoing,
      if (agoraAppId != null) 'agora_app_id': agoraAppId,
      if (agoraChannelName != null) 'agora_channel_name': agoraChannelName,
      if (agoraRtcToken != null) 'agora_rtc_token': agoraRtcToken,
      if (startedAt != null) 'started_at': startedAt?.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt?.toIso8601String(),
    };
  }
}
