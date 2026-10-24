import 'package:flutter/material.dart';

enum NotificationType {
  safetyAlert,
  liveLocation,
  checkIn,
  missedCall,
  scheduledCheckIn,
  trustedCircle,
  systemUpdate,
  announcement,
}

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final NotificationType type;
  final bool isUnread;
  final String group;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    this.isUnread = false,
    required this.group,
  });

  factory NotificationModel.fromJson(
    Map<String, dynamic> json, {
    String group = 'Today',
  }) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Notification',
      subtitle:
          json['message'] as String? ?? json['subtitle'] as String? ?? '',
      time: json['time'] as String? ?? json['created_at'] as String? ?? '',
      type: _parseNotificationType(json['type'] as String?),
      isUnread: json['is_read'] == false || json['is_unread'] == true,
      group: group,
    );
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'safety_alert':
      case 'sos':
        return NotificationType.safetyAlert;
      case 'live_location':
        return NotificationType.liveLocation;
      case 'check_in':
        return NotificationType.checkIn;
      case 'missed_call':
        return NotificationType.missedCall;
      case 'scheduled_check_in':
        return NotificationType.scheduledCheckIn;
      case 'trusted_circle':
        return NotificationType.trustedCircle;
      case 'system_update':
        return NotificationType.systemUpdate;
      case 'announcement':
        return NotificationType.announcement;
      default:
        return NotificationType.systemUpdate;
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.safetyAlert:
        return Icons.security;
      case NotificationType.liveLocation:
        return Icons.location_on;
      case NotificationType.checkIn:
        return Icons.people;
      case NotificationType.missedCall:
        return Icons.phone_missed;
      case NotificationType.scheduledCheckIn:
        return Icons.calendar_today;
      case NotificationType.trustedCircle:
        return Icons.group_add;
      case NotificationType.systemUpdate:
        return Icons.notifications_active;
      case NotificationType.announcement:
        return Icons.campaign;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.safetyAlert:
        return Colors.deepPurple;
      case NotificationType.liveLocation:
        return Colors.green;
      case NotificationType.checkIn:
        return Colors.blue;
      case NotificationType.missedCall:
        return Colors.redAccent;
      case NotificationType.scheduledCheckIn:
        return Colors.lightBlue;
      case NotificationType.trustedCircle:
        return Colors.orange;
      case NotificationType.systemUpdate:
        return Colors.greenAccent;
      case NotificationType.announcement:
        return Colors.purpleAccent;
    }
  }
}