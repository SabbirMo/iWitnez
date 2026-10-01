import 'package:flutter/material.dart';

enum SafePlaceType {
  home,
  work,
  university,
  other,
}

extension SafePlaceTypeX on SafePlaceType {
  String get label => switch (this) {
    SafePlaceType.home => 'Home',
    SafePlaceType.work => 'Work',
    SafePlaceType.university => 'University',
    SafePlaceType.other => 'Safe Place',
  };

  IconData get iconData => switch (this) {
    SafePlaceType.home => Icons.home_rounded,
    SafePlaceType.work => Icons.business_center_rounded,
    SafePlaceType.university => Icons.school_rounded,
    SafePlaceType.other => Icons.place_rounded,
  };

  Color get iconColor => switch (this) {
    SafePlaceType.home => const Color(0xFF7C3AED),
    SafePlaceType.work => const Color(0xFF0284C7),
    SafePlaceType.university => const Color(0xFF059669),
    SafePlaceType.other => const Color(0xFFD97706),
  };

  Color get backgroundColor => switch (this) {
    SafePlaceType.home => const Color(0xFFF3E8FF),
    SafePlaceType.work => const Color(0xFFE0F2FE),
    SafePlaceType.university => const Color(0xFFDCFCE7),
    SafePlaceType.other => const Color(0xFFFEF3C7),
  };
}

class SafePlaceModel {
  final String id;
  final String title;
  final String address;
  final bool isInside;
  final SafePlaceType type;

  const SafePlaceModel({
    required this.id,
    required this.title,
    required this.address,
    required this.isInside,
    required this.type,
  });

  SafePlaceModel copyWith({
    String? id,
    String? title,
    String? address,
    bool? isInside,
    SafePlaceType? type,
  }) {
    return SafePlaceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      isInside: isInside ?? this.isInside,
      type: type ?? this.type,
    );
  }
}

enum HistoryPointType {
  start,
  waypoint,
  end,
}

class HistoryTimelineItem {
  final String id;
  final String time;
  final String? label; // e.g. "Start", "End"
  final String? duration; // e.g. "50 min", "2h 25m"
  final String address;
  final HistoryPointType pointType;

  const HistoryTimelineItem({
    required this.id,
    required this.time,
    this.label,
    this.duration,
    required this.address,
    required this.pointType,
  });
}

