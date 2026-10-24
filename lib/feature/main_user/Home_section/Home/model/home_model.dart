import 'package:iwitnez/feature/main_user/Home_section/Home/model/live_location_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/user_profile_response_model.dart';

enum TrustedCircleKind { family, friends, partner, work }

enum QuickActionType { safety, checkIn, scheduledTimer }

class HomeGreeting {
  const HomeGreeting({
    required this.userName,
    required this.subtitle,
    this.avatarUrl,
    this.hasUnreadNotification = false,
  });

  final String userName;
  final String subtitle;
  final String? avatarUrl;
  final bool hasUnreadNotification;

  HomeGreeting copyWith({
    String? userName,
    String? subtitle,
    String? avatarUrl,
    bool? hasUnreadNotification,
  }) => HomeGreeting(
    userName: userName ?? this.userName,
    subtitle: subtitle ?? this.subtitle,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    hasUnreadNotification: hasUnreadNotification ?? this.hasUnreadNotification,
  );
}

class QuickActionItem {
  const QuickActionItem({required this.type});
  final QuickActionType type;
}

class TrustedCircleSummary {
  const TrustedCircleSummary({
    required this.kind,
    required this.memberCount,
    this.avatars = const [],
  });

  final TrustedCircleKind kind;
  final int memberCount;
  final List<String>? avatars;
}

/// Immutable snapshot of everything the Home screen needs to render.
class HomeState {
  const HomeState({
    required this.greeting,
    required this.isProtected,
    required this.isLoading,
    required this.quickActions,
    required this.trustedCircles,
    this.userProfile,
    this.liveLocation,
  });

  final HomeGreeting greeting;
  final bool isProtected;
  final bool isLoading;
  final List<QuickActionItem> quickActions;
  final List<TrustedCircleSummary> trustedCircles;
  final UserData? userProfile;
  final LiveLocationModel? liveLocation;

  factory HomeState.initial() => const HomeState(
    greeting: HomeGreeting(
      userName: 'Emma',
      subtitle: 'Stay Safe, Stay Connected',
      hasUnreadNotification: false,
    ),
    isProtected: true,
    isLoading: false,
    liveLocation: LiveLocationModel(isSharingLive: true, address: ''),
    quickActions: [
      QuickActionItem(type: QuickActionType.safety),
      QuickActionItem(type: QuickActionType.checkIn),
      QuickActionItem(type: QuickActionType.scheduledTimer),
    ],
    trustedCircles: [
      TrustedCircleSummary(kind: TrustedCircleKind.family, memberCount: 0),
      TrustedCircleSummary(kind: TrustedCircleKind.friends, memberCount: 0),
      TrustedCircleSummary(kind: TrustedCircleKind.partner, memberCount: 0),
      TrustedCircleSummary(kind: TrustedCircleKind.work, memberCount: 0),
    ],
  );

  HomeState copyWith({
    HomeGreeting? greeting,
    bool? isProtected,
    bool? isLoading,
    List<QuickActionItem>? quickActions,
    List<TrustedCircleSummary>? trustedCircles,
    UserData? userProfile,
    LiveLocationModel? liveLocation,
  }) {
    return HomeState(
      greeting: greeting ?? this.greeting,
      isProtected: isProtected ?? this.isProtected,
      isLoading: isLoading ?? this.isLoading,
      quickActions: quickActions ?? this.quickActions,
      trustedCircles: trustedCircles ?? this.trustedCircles,
      userProfile: userProfile ?? this.userProfile,
      liveLocation: liveLocation ?? this.liveLocation,
    );
  }
}
