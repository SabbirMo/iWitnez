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
    SafePlaceType.university => 'School',
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

  String get iconKey => switch (this) {
    SafePlaceType.home => 'home',
    SafePlaceType.work => 'work',
    SafePlaceType.university => 'school',
    SafePlaceType.favorite => 'heart',
    SafePlaceType.star => 'star',
    SafePlaceType.other => 'home',
  };

  static SafePlaceType fromString(String? val) {
    final v = val?.toLowerCase().trim() ?? '';
    if (v == 'home') return SafePlaceType.home;
    if (v == 'work' || v == 'office' || v == 'business') return SafePlaceType.work;
    if (v == 'school' || v == 'university' || v == 'college') {
      return SafePlaceType.university;
    }
    if (v == 'heart' || v == 'favorite') return SafePlaceType.favorite;
    if (v == 'star' || v == 'starred') return SafePlaceType.star;
    return SafePlaceType.other;
  }
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
  final double? latitude;
  final double? longitude;
  final String? iconString;
  final String? statusDisplay;

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
    this.latitude,
    this.longitude,
    this.iconString,
    this.statusDisplay,
  });

  IconData get displayIcon => customIcon ?? type.iconData;
  Color get displayIconColor => customIconColor ?? type.iconColor;
  Color get displayBackgroundColor => customBgColor ?? type.backgroundColor;
  String get displayStatus =>
      statusDisplay ?? (isInside ? 'Inside' : 'Outside');

  factory SafePlaceModel.fromJson(Map<String, dynamic> json) {
    final iconStr = json['icon'] as String? ?? '';
    final type = SafePlaceTypeX.fromString(iconStr);
    final title = json['name'] as String? ??
        json['title'] as String? ??
        type.label;
    final address = json['address'] as String? ?? '';
    final isInside = json['is_inside'] as bool? ?? false;
    final statusDisplay = json['status_display'] as String? ??
        (isInside ? 'Inside' : 'Outside');
    final radius = (json['radius_meters'] as num?)?.toInt() ??
        (json['radius'] as num?)?.toInt() ??
        150;
    final lat = double.tryParse(json['latitude']?.toString() ?? '');
    final lng = double.tryParse(json['longitude']?.toString() ?? '');

    return SafePlaceModel(
      id: json['id']?.toString() ?? '',
      title: title,
      address: address,
      isInside: isInside,
      type: type,
      radius: radius,
      latitude: lat,
      longitude: lng,
      iconString: iconStr,
      statusDisplay: statusDisplay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radius,
      'icon': iconString ?? type.iconKey,
      'is_inside': isInside,
      'status_display': statusDisplay ?? (isInside ? 'Inside' : 'Outside'),
      'alerts_enabled': true,
    };
  }

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
    double? latitude,
    double? longitude,
    String? iconString,
    String? statusDisplay,
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
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      iconString: iconString ?? this.iconString,
      statusDisplay: statusDisplay ?? this.statusDisplay,
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
