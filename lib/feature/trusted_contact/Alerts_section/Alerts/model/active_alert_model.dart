import 'package:iwitnez/core/network/base_url/api_base_url.dart';

class ActiveAlertModel {
  final bool hasActiveAlert;
  final String? alertId;
  final String userName;
  final String priority;
  final String title;
  final String subtitle;
  final AlertLocationModel? location;
  final AlertVideoRecordingModel? videoRecording;
  final AlertAudioRecordingModel? audioRecording;
  final bool isAcknowledged;
  final bool isResolved;

  const ActiveAlertModel({
    required this.hasActiveAlert,
    this.alertId,
    required this.userName,
    required this.priority,
    required this.title,
    required this.subtitle,
    this.location,
    this.videoRecording,
    this.audioRecording,
    this.isAcknowledged = false,
    this.isResolved = false,
  });

  static String? normalizeUrl(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty) return null;
    if (str.startsWith('http://') || str.startsWith('https://')) {
      if (str.startsWith('http://') &&
          (str.contains('ngrok') ||
              ApiBaseUrl.baseUrl.startsWith('https://'))) {
        return str.replaceFirst('http://', 'https://');
      }
      return str;
    }
    final base = ApiBaseUrl.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = str.startsWith('/') ? str : '/$str';
    return '$base$path';
  }

  factory ActiveAlertModel.fromJson(Map<String, dynamic> json) {
    return ActiveAlertModel(
      hasActiveAlert: json['has_active_alert'] == true,
      alertId: json['alert_id']?.toString(),
      userName: json['user_name']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      location: json['location'] is Map
          ? AlertLocationModel.fromJson(
              Map<String, dynamic>.from(json['location'] as Map),
            )
          : null,
      videoRecording: json['video_recording'] is Map
          ? AlertVideoRecordingModel.fromJson(
              Map<String, dynamic>.from(json['video_recording'] as Map),
              parentThumbnail: json['thumbnail_url'] ?? json['thumbnail'],
            )
          : null,
      audioRecording: json['audio_recording'] is Map
          ? AlertAudioRecordingModel.fromJson(
              Map<String, dynamic>.from(json['audio_recording'] as Map),
            )
          : null,
      isAcknowledged: json['is_acknowledged'] == true ||
          json['status']?.toString().toLowerCase() == 'acknowledged',
      isResolved: json['is_resolved'] == true ||
          json['status']?.toString().toLowerCase() == 'resolved',
    );
  }
}

class AlertLocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final bool isSosActivated;

  const AlertLocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isSosActivated,
  });

  factory AlertLocationModel.fromJson(Map<String, dynamic> json) {
    return AlertLocationModel(
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : (double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : (double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0),
      address: json['address']?.toString() ?? '',
      isSosActivated: json['is_sos_activated'] == true,
    );
  }
}

class AlertVideoRecordingModel {
  final String title;
  final String recordedBy;
  final String fileUrl;
  final String? thumbnailUrl;
  final String durationDisplay;
  final int durationSeconds;
  final String sentByDisplay;
  final String sentAtDisplay;
  final bool canDownload;
  final bool canShare;

  const AlertVideoRecordingModel({
    required this.title,
    required this.recordedBy,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.durationDisplay,
    required this.durationSeconds,
    required this.sentByDisplay,
    required this.sentAtDisplay,
    required this.canDownload,
    required this.canShare,
  });

  factory AlertVideoRecordingModel.fromJson(
    Map<String, dynamic> json, {
    dynamic parentThumbnail,
  }) {
    return AlertVideoRecordingModel(
      title: json['title']?.toString() ?? '',
      recordedBy: json['recorded_by']?.toString() ?? '',
      fileUrl: ActiveAlertModel.normalizeUrl(json['file_url']) ?? '',
      thumbnailUrl: ActiveAlertModel.normalizeUrl(
        json['thumbnail_url'] ?? json['thumbnail'] ?? parentThumbnail,
      ),
      durationDisplay: json['duration_display']?.toString() ?? '',
      durationSeconds: json['duration_seconds'] is num
          ? (json['duration_seconds'] as num).toInt()
          : (int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0),
      sentByDisplay: json['sent_by_display']?.toString() ?? '',
      sentAtDisplay: json['sent_at_display']?.toString() ?? '',
      canDownload: json['can_download'] == true,
      canShare: json['can_share'] == true,
    );
  }
}

class AlertAudioRecordingModel {
  final String title;
  final String recordedBy;
  final String fileUrl;
  final String durationDisplay;
  final int durationSeconds;
  final List<double> waveformPeaks;
  final String sentByDisplay;
  final String sentAtDisplay;
  final bool canDownload;
  final bool canShare;

  const AlertAudioRecordingModel({
    required this.title,
    required this.recordedBy,
    required this.fileUrl,
    required this.durationDisplay,
    required this.durationSeconds,
    required this.waveformPeaks,
    required this.sentByDisplay,
    required this.sentAtDisplay,
    required this.canDownload,
    required this.canShare,
  });

  factory AlertAudioRecordingModel.fromJson(Map<String, dynamic> json) {
    final peaksRaw = json['waveform_peaks'];
    final List<double> peaks = [];
    if (peaksRaw is List) {
      for (final p in peaksRaw) {
        if (p is num) {
          peaks.add(p.toDouble());
        } else if (p != null) {
          final parsed = double.tryParse(p.toString());
          if (parsed != null) peaks.add(parsed);
        }
      }
    }

    return AlertAudioRecordingModel(
      title: json['title']?.toString() ?? '',
      recordedBy: json['recorded_by']?.toString() ?? '',
      fileUrl: ActiveAlertModel.normalizeUrl(json['file_url']) ?? '',
      durationDisplay: json['duration_display']?.toString() ?? '',
      durationSeconds: json['duration_seconds'] is num
          ? (json['duration_seconds'] as num).toInt()
          : (int.tryParse(json['duration_seconds']?.toString() ?? '') ?? 0),
      waveformPeaks: peaks,
      sentByDisplay: json['sent_by_display']?.toString() ?? '',
      sentAtDisplay: json['sent_at_display']?.toString() ?? '',
      canDownload: json['can_download'] == true,
      canShare: json['can_share'] == true,
    );
  }
}

class ActiveAlertResponse {
  final bool success;
  final String message;
  final ActiveAlertModel? data;
  final dynamic errors;

  const ActiveAlertResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ActiveAlertResponse.fromJson(Map<String, dynamic> json) {
    return ActiveAlertResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? ActiveAlertModel.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
      errors: json['errors'],
    );
  }
}
