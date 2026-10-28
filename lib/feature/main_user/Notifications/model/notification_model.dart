import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String notificationType;
  final String typeDisplay;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final bool isRead;
  final String relativeTime;
  final String iconType;
  final String iconColor;
  final String createdAt;
  final String group;

  NotificationModel({
    required this.id,
    this.notificationType = '',
    this.typeDisplay = '',
    required this.title,
    required this.message,
    this.data = const {},
    this.isRead = false,
    required this.relativeTime,
    this.iconType = '',
    this.iconColor = '',
    this.createdAt = '',
    required this.group,
  });

  bool get isUnread => !isRead;
  String get time => relativeTime.isNotEmpty ? relativeTime : createdAt;

  NotificationModel copyWith({
    String? id,
    String? notificationType,
    String? typeDisplay,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    String? relativeTime,
    String? iconType,
    String? iconColor,
    String? createdAt,
    String? group,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      typeDisplay: typeDisplay ?? this.typeDisplay,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      relativeTime: relativeTime ?? this.relativeTime,
      iconType: iconType ?? this.iconType,
      iconColor: iconColor ?? this.iconColor,
      createdAt: createdAt ?? this.createdAt,
      group: group ?? this.group,
    );
  }

  factory NotificationModel.fromJson(
    Map<String, dynamic> json, {
    String group = 'Today',
  }) {
    final rawIsRead = json['is_read'];
    final rawUnread = json['unread'];
    final bool parsedIsRead = rawIsRead is bool
        ? rawIsRead
        : (rawUnread is bool ? !rawUnread : false);

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      notificationType:
          json['notification_type'] as String? ?? json['type'] as String? ?? '',
      typeDisplay: json['type_display'] as String? ?? '',
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? json['subtitle'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : {},
      isRead: parsedIsRead,
      relativeTime:
          json['relative_time'] as String? ?? json['time'] as String? ?? '',
      iconType: json['icon_type'] as String? ?? '',
      iconColor: json['icon_color'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      group: group,
    );
  }

  IconData get icon {
    final it = iconType.toLowerCase();
    final nt = notificationType.toLowerCase();

    if (it == 'sos' || nt.contains('safety_alert') || nt.contains('sos')) {
      return Icons.shield_outlined;
    } else if (it == 'check_in' || nt.contains('check_in')) {
      return Icons.check_circle_outline_rounded;
    } else if (it == 'safe_place') {
      return Icons.favorite_border_rounded;
    } else if (it == 'live_location' || nt.contains('live_location')) {
      return Icons.location_on_outlined;
    } else if (it == 'call' ||
        nt.contains('missed_call') ||
        nt.contains('call')) {
      return Icons.phone_missed_rounded;
    }
    return Icons.notifications_none_rounded;
  }

  Color get color {
    final ic = iconColor.toLowerCase();
    final it = iconType.toLowerCase();
    final nt = notificationType.toLowerCase();

    if (ic == 'red' ||
        it == 'sos' ||
        nt.contains('safety_alert') ||
        nt.contains('sos')) {
      return const Color(0xFFF04438);
    } else if (ic == 'green' || it == 'check_in' || nt.contains('check_in')) {
      return const Color(0xFF12B76A);
    } else if (ic == 'pink' || it == 'safe_place') {
      return const Color(0xFFEE46BC);
    } else if (ic == 'blue' ||
        it == 'live_location' ||
        nt.contains('live_location')) {
      return const Color(0xFF2E90FA);
    }
    return const Color(0xFF7F56D9);
  }

  Color get backgroundColor {
    final ic = iconColor.toLowerCase();
    final it = iconType.toLowerCase();
    final nt = notificationType.toLowerCase();

    if (ic == 'red' ||
        it == 'sos' ||
        nt.contains('safety_alert') ||
        nt.contains('sos')) {
      return const Color(0xFFFEE4E2);
    } else if (ic == 'green' || it == 'check_in' || nt.contains('check_in')) {
      return const Color(0xFFE6F9F0);
    } else if (ic == 'pink' || it == 'safe_place') {
      return const Color(0xFFFDE8F1);
    } else if (ic == 'blue' ||
        it == 'live_location' ||
        nt.contains('live_location')) {
      return const Color(0xFFEFF8FF);
    }
    return const Color(0xFFF4EBFF);
  }
}
