import 'package:flutter/material.dart';

enum TrustedActivityType {
  checkIn,
  leftSafePlace,
  other,
}

class TrustedActivityItem {
  const TrustedActivityItem({
    required this.id,
    required this.title,
    required this.time,
    required this.badgeText,
    required this.type,
    this.badgeIcon,
    this.badgeColor = 'green',
    this.activityType = 'check_in',
  });

  final String id;
  final String title;
  final String time;
  final String badgeText;
  final TrustedActivityType type;
  final IconData? badgeIcon;
  final String badgeColor;
  final String activityType;

  bool get isCheckIn =>
      type == TrustedActivityType.checkIn || activityType == 'check_in';
}

class MonitoredUserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final bool isOnline;
  final String movementStatus;
  final int batteryLevel;
  final String updatedAgo;

  const MonitoredUserModel({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.avatarUrl = '',
    this.isOnline = true,
    this.movementStatus = '',
    this.batteryLevel = 0,
    this.updatedAgo = '',
  });

  factory MonitoredUserModel.fromJson(Map<String, dynamic> json) {
    return MonitoredUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? true,
      movementStatus: json['movement_status'] as String? ?? '',
      batteryLevel: (json['battery_level'] as num?)?.toInt() ?? 0,
      updatedAgo: json['updated_ago'] as String? ?? '',
    );
  }
}

class SafetyBannerModel {
  final String title;
  final String description;
  final String badge;

  const SafetyBannerModel({
    this.title = '',
    this.description = '',
    this.badge = '',
  });

  factory SafetyBannerModel.fromJson(Map<String, dynamic> json) {
    return SafetyBannerModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
    );
  }
}

class LiveLocationModel {
  final String address;
  final double latitude;
  final double longitude;
  final String statusBadge;
  final String updatedAgo;

  const LiveLocationModel({
    this.address = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.statusBadge = '',
    this.updatedAgo = '',
  });

  factory LiveLocationModel.fromJson(Map<String, dynamic> json) {
    return LiveLocationModel(
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      statusBadge: json['status_badge'] as String? ?? '',
      updatedAgo: json['updated_ago'] as String? ?? '',
    );
  }
}

class QuickActionModel {
  final String id;
  final String title;
  final String icon;

  const QuickActionModel({
    this.id = '',
    this.title = '',
    this.icon = '',
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }
}

class RecentActivityModel {
  final String id;
  final String activityType;
  final String title;
  final String timeDisplay;
  final String badge;
  final String badgeColor;

  const RecentActivityModel({
    this.id = '',
    this.activityType = '',
    this.title = '',
    this.timeDisplay = '',
    this.badge = '',
    this.badgeColor = '',
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'] as String? ?? '',
      activityType: json['activity_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      timeDisplay: json['time_display'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      badgeColor: json['badge_color'] as String? ?? '',
    );
  }

  TrustedActivityItem toActivityItem() {
    final isCheckIn = activityType == 'check_in';
    final isSafePlace =
        activityType == 'safe_place' || badge.toLowerCase() == 'home';
    return TrustedActivityItem(
      id: id,
      title: title,
      time: timeDisplay,
      badgeText: badge,
      badgeColor: badgeColor,
      activityType: activityType,
      type: isCheckIn
          ? TrustedActivityType.checkIn
          : TrustedActivityType.leftSafePlace,
      badgeIcon: isSafePlace ? Icons.home_rounded : null,
    );
  }
}

class TrustedDashboardData {
  final String greeting;
  final String subtitle;
  final int unreadNotificationsCount;
  final MonitoredUserModel? monitoredUser;
  final SafetyBannerModel? safetyBanner;
  final LiveLocationModel? liveLocation;
  final List<QuickActionModel> quickActions;
  final List<RecentActivityModel> recentActivity;

  const TrustedDashboardData({
    this.greeting = '',
    this.subtitle = '',
    this.unreadNotificationsCount = 0,
    this.monitoredUser,
    this.safetyBanner,
    this.liveLocation,
    this.quickActions = const [],
    this.recentActivity = const [],
  });

  factory TrustedDashboardData.fromJson(Map<String, dynamic> json) {
    return TrustedDashboardData(
      greeting: json['greeting'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      unreadNotificationsCount:
          (json['unread_notifications_count'] as num?)?.toInt() ?? 0,
      monitoredUser: json['monitored_user'] is Map<String, dynamic>
          ? MonitoredUserModel.fromJson(
              json['monitored_user'] as Map<String, dynamic>,
            )
          : null,
      safetyBanner: json['safety_banner'] is Map<String, dynamic>
          ? SafetyBannerModel.fromJson(
              json['safety_banner'] as Map<String, dynamic>,
            )
          : null,
      liveLocation: json['live_location'] is Map<String, dynamic>
          ? LiveLocationModel.fromJson(
              json['live_location'] as Map<String, dynamic>,
            )
          : null,
      quickActions: (json['quick_actions'] as List<dynamic>?)
              ?.map((e) => QuickActionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentActivity: (json['recent_activity'] as List<dynamic>?)
              ?.map((e) =>
                  RecentActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class TrustedDashboardResponseModel {
  final bool success;
  final String message;
  final TrustedDashboardData? data;
  final dynamic errors;

  const TrustedDashboardResponseModel({
    this.success = false,
    this.message = '',
    this.data,
    this.errors,
  });

  factory TrustedDashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return TrustedDashboardResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? TrustedDashboardData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'],
    );
  }
}

class TrustedContactHomeState {
  const TrustedContactHomeState({
    required this.greeting,
    required this.userName,
    required this.userSubtitle,
    required this.userAvatarUrl,
    required this.unreadNotificationsCount,
    required this.hasNotification,
    required this.wardName,
    required this.wardStatus,
    required this.wardAddress,
    required this.wardAvatarUrl,
    required this.activities,
    this.monitoredUser,
    this.safetyBanner,
    this.liveLocation,
    this.quickActions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final String greeting;
  final String userName;
  final String userSubtitle;
  final String userAvatarUrl;
  final int unreadNotificationsCount;
  final bool hasNotification;
  final String wardName;
  final String wardStatus;
  final String wardAddress;
  final String wardAvatarUrl;
  final List<TrustedActivityItem> activities;
  final MonitoredUserModel? monitoredUser;
  final SafetyBannerModel? safetyBanner;
  final LiveLocationModel? liveLocation;
  final List<QuickActionModel> quickActions;
  final bool isLoading;
  final String? errorMessage;

  factory TrustedContactHomeState.initial() => const TrustedContactHomeState(
        greeting: '',
        userName: '',
        userSubtitle: '',
        userAvatarUrl: '',
        unreadNotificationsCount: 0,
        hasNotification: false,
        wardName: '',
        wardStatus: '',
        wardAddress: '',
        wardAvatarUrl: '',
        activities: [],
        isLoading: true,
      );

  factory TrustedContactHomeState.fromDashboardData(
    TrustedDashboardData data, {
    String? userAvatarUrl,
  }) {
    final mUser = data.monitoredUser;
    final loc = data.liveLocation;

    final wardFullName = mUser?.name.trim() ?? '';
    final wardFirstName =
        wardFullName.isNotEmpty ? wardFullName.split(' ').first : '';

    String extractedUserName = '';
    if (data.greeting.startsWith('Hi ')) {
      extractedUserName = data.greeting.replaceFirst('Hi ', '').trim();
    } else {
      extractedUserName = data.greeting;
    }

    final items = data.recentActivity.map((a) => a.toActivityItem()).toList();

    return TrustedContactHomeState(
      greeting: data.greeting,
      userName: extractedUserName,
      userSubtitle: data.subtitle,
      userAvatarUrl: userAvatarUrl ?? '',
      unreadNotificationsCount: data.unreadNotificationsCount,
      hasNotification: data.unreadNotificationsCount > 0,
      wardName: wardFirstName,
      wardStatus: mUser?.movementStatus.isNotEmpty == true
          ? mUser!.movementStatus
          : (loc?.statusBadge ?? ''),
      wardAddress: loc?.address ?? '',
      wardAvatarUrl: mUser?.avatarUrl ?? '',
      activities: items,
      monitoredUser: mUser,
      safetyBanner: data.safetyBanner,
      liveLocation: loc,
      quickActions: data.quickActions,
      isLoading: false,
    );
  }

  TrustedContactHomeState copyWith({
    String? greeting,
    String? userName,
    String? userSubtitle,
    String? userAvatarUrl,
    int? unreadNotificationsCount,
    bool? hasNotification,
    String? wardName,
    String? wardStatus,
    String? wardAddress,
    String? wardAvatarUrl,
    List<TrustedActivityItem>? activities,
    MonitoredUserModel? monitoredUser,
    SafetyBannerModel? safetyBanner,
    LiveLocationModel? liveLocation,
    List<QuickActionModel>? quickActions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TrustedContactHomeState(
      greeting: greeting ?? this.greeting,
      userName: userName ?? this.userName,
      userSubtitle: userSubtitle ?? this.userSubtitle,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      unreadNotificationsCount:
          unreadNotificationsCount ?? this.unreadNotificationsCount,
      hasNotification: hasNotification ?? this.hasNotification,
      wardName: wardName ?? this.wardName,
      wardStatus: wardStatus ?? this.wardStatus,
      wardAddress: wardAddress ?? this.wardAddress,
      wardAvatarUrl: wardAvatarUrl ?? this.wardAvatarUrl,
      activities: activities ?? this.activities,
      monitoredUser: monitoredUser ?? this.monitoredUser,
      safetyBanner: safetyBanner ?? this.safetyBanner,
      liveLocation: liveLocation ?? this.liveLocation,
      quickActions: quickActions ?? this.quickActions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
