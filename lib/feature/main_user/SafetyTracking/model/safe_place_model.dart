import 'package:flutter/material.dart';

enum SafePlaceType {
  home,
  work,
  university,
  favorite,
  star,
  other,
}

extension SafePlaceTypeX on SafePlaceType {
  String get label => switch (this) {
    SafePlaceType.home => 'Home',
    SafePlaceType.work => 'Work',
    SafePlaceType.university => 'University',
    SafePlaceType.favorite => 'Favorite',
    SafePlaceType.star => 'Starred',
    SafePlaceType.other => 'Safe Place',
  };

  IconData get iconData => switch (this) {
    SafePlaceType.home => Icons.home_rounded,
    SafePlaceType.work => Icons.business_center_rounded,
    SafePlaceType.university => Icons.school_rounded,
    SafePlaceType.favorite => Icons.favorite_rounded,
    SafePlaceType.star => Icons.star_rounded,
    SafePlaceType.other => Icons.place_rounded,
  };

  Color get iconColor => switch (this) {
    SafePlaceType.home => const Color(0xFF7C3AED),
    SafePlaceType.work => const Color(0xFF0284C7),
    SafePlaceType.university => const Color(0xFF059669),
    SafePlaceType.favorite => const Color(0xFFEC4899),
    SafePlaceType.star => const Color(0xFFF59E0B),
    SafePlaceType.other => const Color(0xFFD97706),
  };

  Color get backgroundColor => switch (this) {
    SafePlaceType.home => const Color(0xFFF3E8FF),
    SafePlaceType.work => const Color(0xFFE0F2FE),
    SafePlaceType.university => const Color(0xFFDCFCE7),
    SafePlaceType.favorite => const Color(0xFFFCE7F3),
    SafePlaceType.star => const Color(0xFFFEF3C7),
    SafePlaceType.other => const Color(0xFFFEF3C7),
  };
}

class SafePlaceModel {
  final String id;
  final String title;
  final String address;
  final bool isInside;
  final SafePlaceType type;
  final IconData? customIcon;
  final Color? customIconColor;
  final Color? customBgColor;
  final int? radius;

  const SafePlaceModel({
    required this.id,
    required this.title,
    required this.address,
    required this.isInside,
    required this.type,
    this.customIcon,
    this.customIconColor,
    this.customBgColor,
    this.radius,
  });

  IconData get displayIcon => customIcon ?? type.iconData;
  Color get displayIconColor => customIconColor ?? type.iconColor;
  Color get displayBackgroundColor => customBgColor ?? type.backgroundColor;

  SafePlaceModel copyWith({
    String? id,
    String? title,
    String? address,
    bool? isInside,
    SafePlaceType? type,
    IconData? customIcon,
    Color? customIconColor,
    Color? customBgColor,
    int? radius,
  }) {
    return SafePlaceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      isInside: isInside ?? this.isInside,
      type: type ?? this.type,
      customIcon: customIcon ?? this.customIcon,
      customIconColor: customIconColor ?? this.customIconColor,
      customBgColor: customBgColor ?? this.customBgColor,
      radius: radius ?? this.radius,
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

