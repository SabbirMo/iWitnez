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

  IconData get icon {
    switch (type) {
      case NotificationType.safetyAlert: return Icons.security;
      case NotificationType.liveLocation: return Icons.location_on;
      case NotificationType.checkIn: return Icons.people;
      case NotificationType.missedCall: return Icons.phone_missed;
      case NotificationType.scheduledCheckIn: return Icons.calendar_today;
      case NotificationType.trustedCircle: return Icons.group_add;
      case NotificationType.systemUpdate: return Icons.notifications_active;
      case NotificationType.announcement: return Icons.campaign;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.safetyAlert: return Colors.deepPurple;
      case NotificationType.liveLocation: return Colors.green;
      case NotificationType.checkIn: return Colors.blue;
      case NotificationType.missedCall: return Colors.redAccent;
      case NotificationType.scheduledCheckIn: return Colors.lightBlue;
      case NotificationType.trustedCircle: return Colors.orange;
      case NotificationType.systemUpdate: return Colors.greenAccent;
      case NotificationType.announcement: return Colors.purpleAccent;
    }
  }
}