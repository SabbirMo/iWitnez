enum CallDirection { incoming, outgoing, missed }

enum CallType { voice, video }

class CallRecordItem {
  final String id;
  final String contactName;
  final String contactPhone;
  final String contactAvatarUrl;
  final String callType; // "video" or "audio"
  final String status; // "completed", "missed", "ringing", etc.
  final int durationSeconds;
  final String formattedDuration;
  final bool isOutgoing;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? agoraAppId;
  final String? agoraChannelName;
  final String? agoraRtcToken;

  const CallRecordItem({
    required this.id,
    required this.contactName,
    this.contactPhone = '',
    this.contactAvatarUrl = '',
    this.callType = 'audio',
    this.status = 'completed',
    this.durationSeconds = 0,
    this.formattedDuration = '00:00',
    this.isOutgoing = true,
    this.startedAt,
    this.endedAt,
    this.agoraAppId,
    this.agoraChannelName,
    this.agoraRtcToken,
  });

  bool get isMissed => status.toLowerCase() == 'missed';

  bool get isVideo => callType.toLowerCase() == 'video';

  CallDirection get direction {
    if (isMissed) return CallDirection.missed;
    return isOutgoing ? CallDirection.outgoing : CallDirection.incoming;
  }

  CallType get type => isVideo ? CallType.video : CallType.voice;

  String get name => contactName;

  String get avatarUrl => contactAvatarUrl;

  String? get duration {
    if (isMissed || formattedDuration.isEmpty || formattedDuration == '00:00') {
      return null;
    }
    return formattedDuration;
  }

  String get date => displayDate;

  String get time => displayTime;

  String get displayDate {
    if (startedAt == null) return 'Today';
    final now = DateTime.now();
    final local = startedAt!.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(local.year, local.month, local.day);
    final diff = today.difference(itemDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[local.weekday - 1];
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}';
  }

  String get displayTime {
    if (startedAt == null) return '';
    final local = startedAt!.toLocal();
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get callTypeDescription {
    if (isMissed) {
      return 'Missed ${isVideo ? 'video' : 'audio'} call';
    }
    return '${isVideo ? 'Video' : 'Audio'} call';
  }

  factory CallRecordItem.fromJson(Map<String, dynamic> json) {
    return CallRecordItem(
      id: json['id']?.toString() ?? '',
      contactName: json['contact_name']?.toString() ?? 'Unknown',
      contactPhone: json['contact_phone']?.toString() ?? '',
      contactAvatarUrl: json['contact_avatar_url']?.toString() ?? '',
      callType: json['call_type']?.toString().toLowerCase() ?? 'audio',
      status: json['status']?.toString().toLowerCase() ?? 'completed',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      formattedDuration: json['formatted_duration']?.toString() ?? '00:00',
      isOutgoing: json['is_outgoing'] == true,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      agoraAppId: json['agora_app_id']?.toString(),
      agoraChannelName: json['agora_channel_name']?.toString(),
      agoraRtcToken: json['agora_rtc_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_avatar_url': contactAvatarUrl,
      'call_type': callType,
      'status': status,
      'duration_seconds': durationSeconds,
      'formatted_duration': formattedDuration,
      'is_outgoing': isOutgoing,
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }
}

// Backwards compatibility alias for widgets that referenced CallLogEntry
typedef CallLogEntry = CallRecordItem;
