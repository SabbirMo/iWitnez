import 'package:flutter/material.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';

class CircleDetail {
  final String label;
  final int count;
  final List<CircleMember> members;

  const CircleDetail({
    required this.label,
    required this.count,
    this.members = const [],
  });

  factory CircleDetail.fromJson(
    Map<String, dynamic>? json,
    String defaultLabel,
  ) {
    if (json == null) {
      return CircleDetail(label: defaultLabel, count: 0);
    }

    final parsedMembers = <CircleMember>[];
    if (json['members'] is List) {
      for (final item in (json['members'] as List)) {
        if (item is Map) {
          parsedMembers.add(
            CircleMember.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return CircleDetail(
      label: json['label'] as String? ?? defaultLabel,
      count: (json['count'] as num?)?.toInt() ?? parsedMembers.length,
      members: parsedMembers,
    );
  }
}

class TrustedCirclesResponseModel {
  final int totalMembers;
  final CircleDetail family;
  final CircleDetail friends;
  final CircleDetail partner;
  final CircleDetail work;

  const TrustedCirclesResponseModel({
    required this.totalMembers,
    required this.family,
    required this.friends,
    required this.partner,
    required this.work,
  });

  factory TrustedCirclesResponseModel.fromJson(Map<String, dynamic> json) {
    final circles = json['circles'] as Map<String, dynamic>? ?? {};

    return TrustedCirclesResponseModel(
      totalMembers: (json['total_members'] as num?)?.toInt() ?? 0,
      family: CircleDetail.fromJson(
        circles['family'] as Map<String, dynamic>?,
        'Family',
      ),
      friends: CircleDetail.fromJson(
        circles['friends'] as Map<String, dynamic>?,
        'Friends',
      ),
      partner: CircleDetail.fromJson(
        circles['partner'] as Map<String, dynamic>?,
        'Partner',
      ),
      work: CircleDetail.fromJson(
        circles['work'] as Map<String, dynamic>?,
        'Work',
      ),
    );
  }

  List<TrustedCircleSummary> toSummaries() {
    return [
      TrustedCircleSummary(
        kind: TrustedCircleKind.family,
        memberCount: family.count,
        avatars: family.members
            .map((m) => m.avatarUrl)
            .where((u) => u.isNotEmpty)
            .take(3)
            .toList(),
      ),
      TrustedCircleSummary(
        kind: TrustedCircleKind.friends,
        memberCount: friends.count,
        avatars: friends.members
            .map((m) => m.avatarUrl)
            .where((u) => u.isNotEmpty)
            .take(3)
            .toList(),
      ),
      TrustedCircleSummary(
        kind: TrustedCircleKind.partner,
        memberCount: partner.count,
        avatars: partner.members
            .map((m) => m.avatarUrl)
            .where((u) => u.isNotEmpty)
            .take(3)
            .toList(),
      ),
      TrustedCircleSummary(
        kind: TrustedCircleKind.work,
        memberCount: work.count,
        avatars: work.members
            .map((m) => m.avatarUrl)
            .where((u) => u.isNotEmpty)
            .take(3)
            .toList(),
      ),
    ];
  }

  List<TrustedCircleItem> toCircleItems() {
    return [
      TrustedCircleItem(
        id: 'family',
        title: family.label.isNotEmpty ? family.label : 'Family',
        memberCount: family.count,
        avatars: family.members
            .map((m) => m.avatarUrl)
            .where((u) => u.isNotEmpty)
            .take(3)
            .toList(),
        badgeBg: const Color(0xFFF3E8FF),
        badgeIcon: Icons.groups_rounded,
        badgeIconColor: const Color(0xFFA855F7),
        members: family.members,
      ),
      TrustedCircleItem(
        id: 'friends',
        title: friends.label.isNotEmpty ? friends.label : 'Friends',
        memberCount: friends.count,
        avatars: friends.members
            .map((m) => m.avatarUrl)
            .where((u) => u.isNotEmpty)
            .take(3)
            .toList(),
        badgeBg: const Color(0xFFDBEAFE),
        badgeIcon: Icons.people_alt_rounded,
        badgeIconColor: const Color(0xFF3B82F6),
        members: friends.members,
      ),
      TrustedCircleItem(
        id: 'partner',
        title: partner.label.isNotEmpty ? partner.label : 'Partner',
        memberCount: partner.count,
        avatars: partner.members
            .map((m) => m.avatarUrl)
            .where((u) => u.isNotEmpty)
            .take(3)
            .toList(),
        badgeBg: const Color(0xFFFCE7F3),
        badgeIcon: Icons.favorite_rounded,
        badgeIconColor: const Color(0xFFEC4899),
        members: partner.members,
      ),
      TrustedCircleItem(
        id: 'work',
        title: work.label.isNotEmpty ? work.label : 'Work',
        memberCount: work.count,
        avatars: work.members
            .map((m) => m.avatarUrl)
            .where((u) => u.isNotEmpty)
            .take(3)
            .toList(),
        badgeBg: const Color(0xFFDCFCE7),
        badgeIcon: Icons.business_center_rounded,
        badgeIconColor: const Color(0xFF10B981),
        members: work.members,
      ),
    ];
  }
}
