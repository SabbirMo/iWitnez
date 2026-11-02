import 'package:iwitnez/core/network/base_url/api_base_url.dart';

class AlertHistoryModel {
  final String id;
  final String title;
  final String timestampDisplay;
  final String address;
  final bool hasVideo;
  final bool hasAudio;
  final String? videoUrl;
  final String? audioUrl;
  final String durationDisplay;
  final int? durationSeconds;
  final String? thumbnailUrl;
  final double? latitude;
  final double? longitude;

  const AlertHistoryModel({
    required this.id,
    required this.title,
    required this.timestampDisplay,
    required this.address,
    required this.hasVideo,
    required this.hasAudio,
    this.videoUrl,
    this.audioUrl,
    required this.durationDisplay,
    this.durationSeconds,
    this.thumbnailUrl,
    this.latitude,
    this.longitude,
  });

  static String? _normalizeUrl(dynamic raw) {
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

  factory AlertHistoryModel.fromJson(Map<String, dynamic> json) {
    int? durSec;
    if (json['duration_seconds'] is num) {
      durSec = (json['duration_seconds'] as num).toInt();
    } else if (json['duration'] is num) {
      durSec = (json['duration'] as num).toInt();
    } else if (json['duration_seconds'] != null) {
      durSec = int.tryParse(json['duration_seconds'].toString());
    } else if (json['duration'] != null) {
      durSec = int.tryParse(json['duration'].toString());
    }

    String durDisplay = json['duration_display']?.toString() ?? '';
    if (durSec != null && durSec > 0) {
      final m = (durSec ~/ 60).toString().padLeft(2, '0');
      final s = (durSec % 60).toString().padLeft(2, '0');
      durDisplay = '$m:$s';
    } else if (durDisplay.isEmpty) {
      durDisplay = '00:00';
    }

    return AlertHistoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'SOS Alert',
      timestampDisplay: json['timestamp_display']?.toString() ??
          json['date']?.toString() ??
          '',
      address: json['address']?.toString() ?? '',
      hasVideo: json['has_video'] == true || json['hasVideo'] == true,
      hasAudio: json['has_audio'] == true || json['hasAudio'] == true,
      videoUrl: _normalizeUrl(json['video_url'] ?? json['videoUrl']),
      audioUrl: _normalizeUrl(json['audio_url'] ?? json['audioUrl']),
      durationDisplay: durDisplay,
      durationSeconds: durSec,
      thumbnailUrl: _normalizeUrl(json['thumbnail_url'] ?? json['thumbnail']),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : (json['latitude'] != null
              ? double.tryParse(json['latitude'].toString())
              : null),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : (json['longitude'] != null
              ? double.tryParse(json['longitude'].toString())
              : null),
    );
  }

  AlertHistoryModel copyWith({
    String? id,
    String? title,
    String? timestampDisplay,
    String? address,
    bool? hasVideo,
    bool? hasAudio,
    String? videoUrl,
    String? audioUrl,
    String? durationDisplay,
    int? durationSeconds,
    String? thumbnailUrl,
    double? latitude,
    double? longitude,
  }) {
    return AlertHistoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      timestampDisplay: timestampDisplay ?? this.timestampDisplay,
      address: address ?? this.address,
      hasVideo: hasVideo ?? this.hasVideo,
      hasAudio: hasAudio ?? this.hasAudio,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      durationDisplay: durationDisplay ?? this.durationDisplay,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'timestamp_display': timestampDisplay,
      'address': address,
      'has_video': hasVideo,
      'has_audio': hasAudio,
      if (videoUrl != null) 'video_url': videoUrl,
      if (audioUrl != null) 'audio_url': audioUrl,
      'duration_display': durationDisplay,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

class AlertHistoryResponse {
  final bool success;
  final String message;
  final List<AlertHistoryModel> data;
  final dynamic errors;

  const AlertHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
    this.errors,
  });

  factory AlertHistoryResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    return AlertHistoryResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: list is List
          ? list.map((item) {
              if (item is Map) {
                return AlertHistoryModel.fromJson(
                  Map<String, dynamic>.from(item),
                );
              }
              return null;
            }).whereType<AlertHistoryModel>().toList()
          : [],
      errors: json['errors'],
    );
  }
}

