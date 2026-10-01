import 'package:flutter/material.dart';

enum TrustedActivityType {
  checkIn,
  leftSafePlace,
}

class TrustedActivityItem {
  const TrustedActivityItem({
    required this.id,
    required this.title,
    required this.time,
    required this.badgeText,
    required this.type,
    this.badgeIcon,
  });

  final String id;
  final String title;
  final String time;
  final String badgeText;
  final TrustedActivityType type;
  final IconData? badgeIcon;
}

enum TrustedQuickActionType {
  checkInStatus,
  journeyEta,
}

class TrustedContactHomeState {
  const TrustedContactHomeState({
    required this.userName,
    required this.userSubtitle,
    required this.userAvatarUrl,
    required this.hasNotification,
    required this.wardName,
    required this.wardStatus,
    required this.wardAddress,
    required this.wardAvatarUrl,
    required this.activities,
    this.isLoading = false,
  });

  final String userName;
  final String userSubtitle;
  final String userAvatarUrl;
  final bool hasNotification;
  final String wardName;
  final String wardStatus;
  final String wardAddress;
  final String wardAvatarUrl;
  final List<TrustedActivityItem> activities;
  final bool isLoading;

  factory TrustedContactHomeState.initial() => const TrustedContactHomeState(
        userName: 'Sanjida',
        userSubtitle: 'Sty Safe, Stay Connected',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        hasNotification: true,
        wardName: 'Emma',
        wardStatus: 'Online • moving',
        wardAddress: '1200 Park Ave,\nNew York, NY 10028, USA',
        wardAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        activities: [
          TrustedActivityItem(
            id: '1',
            title: 'Emma checked in',
            time: 'Today, 10:30 AM',
            badgeText: "I'm Safe",
            type: TrustedActivityType.checkIn,
          ),
          TrustedActivityItem(
            id: '2',
            title: 'Emma left Home',
            time: 'Today, 08:15 AM',
            badgeText: 'Home',
            type: TrustedActivityType.leftSafePlace,
            badgeIcon: Icons.home_rounded,
          ),
          TrustedActivityItem(
            id: '3',
            title: 'Emma left Home',
            time: 'Today, 08:15 AM',
            badgeText: 'Home',
            type: TrustedActivityType.leftSafePlace,
            badgeIcon: Icons.home_rounded,
          ),
        ],
        isLoading: false,
      );

  TrustedContactHomeState copyWith({
    String? userName,
    String? userSubtitle,
    String? userAvatarUrl,
    bool? hasNotification,
    String? wardName,
    String? wardStatus,
    String? wardAddress,
    String? wardAvatarUrl,
    List<TrustedActivityItem>? activities,
    bool? isLoading,
  }) {
    return TrustedContactHomeState(
      userName: userName ?? this.userName,
      userSubtitle: userSubtitle ?? this.userSubtitle,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      hasNotification: hasNotification ?? this.hasNotification,
      wardName: wardName ?? this.wardName,
      wardStatus: wardStatus ?? this.wardStatus,
      wardAddress: wardAddress ?? this.wardAddress,
      wardAvatarUrl: wardAvatarUrl ?? this.wardAvatarUrl,
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
