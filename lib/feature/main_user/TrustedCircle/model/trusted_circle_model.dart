import 'package:flutter/material.dart';

class CircleMember {
  final String id;
  final String name;
  final String phone;
  final String avatarUrl;
  final String email;
  final String relationship;
  final bool emergencyAlerts;

  const CircleMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatarUrl,
    this.email = '',
    this.relationship = 'Contact',
    this.emergencyAlerts = true,
  });

  factory CircleMember.fromJson(Map<String, dynamic> json) {
    final rawAvatar = (json['avatar_url'] ?? json['avatar'])?.toString() ?? '';
    final avatar = rawAvatar.startsWith('http://')
        ? rawAvatar.replaceFirst('http://', 'https://')
        : rawAvatar;
    final rel =
        (json['relationship_display'] ?? json['relationship'])?.toString();
    return CircleMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: (json['phone_number'] ?? json['phone'])?.toString() ?? '',
      avatarUrl: avatar,
      email: json['email']?.toString() ?? '',
      relationship: (rel != null && rel.isNotEmpty) ? rel : 'Contact',
      emergencyAlerts: json['emergency_alerts_enabled'] == true ||
          json['emergency_alerts'] == true,
    );
  }

  CircleMember copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatarUrl,
    String? email,
    String? relationship,
    bool? emergencyAlerts,
  }) {
    return CircleMember(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
    );
  }
}

class TrustedCircleItem {
  final String id;
  final String title;
  final int memberCount;
  final List<String> avatars;
  final Color badgeBg;
  final IconData badgeIcon;
  final Color badgeIconColor;
  final List<CircleMember> members;

  const TrustedCircleItem({
    this.id = '',
    required this.title,
    required this.memberCount,
    this.avatars = const [],
    required this.badgeBg,
    required this.badgeIcon,
    required this.badgeIconColor,
    this.members = const [],
  });

  TrustedCircleItem copyWith({
    String? id,
    String? title,
    int? memberCount,
    List<String>? avatars,
    Color? badgeBg,
    IconData? badgeIcon,
    Color? badgeIconColor,
    List<CircleMember>? members,
  }) {
    return TrustedCircleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      memberCount: memberCount ?? this.memberCount,
      avatars: avatars ?? this.avatars,
      badgeBg: badgeBg ?? this.badgeBg,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      badgeIconColor: badgeIconColor ?? this.badgeIconColor,
      members: members ?? this.members,
    );
  }
}
