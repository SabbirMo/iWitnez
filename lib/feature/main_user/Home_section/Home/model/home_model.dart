enum TrustedCircleKind { family, friends, partner, work }
enum QuickActionType { safety, checkIn, scheduledTimer }

class HomeGreeting {
  const HomeGreeting({
    required this.userName,
    required this.subtitle,
    this.hasUnreadNotification = false,
  });

  final String userName;
  final String subtitle;
  final bool hasUnreadNotification;

  HomeGreeting copyWith({bool? hasUnreadNotification}) => HomeGreeting(
        userName: userName,
        subtitle: subtitle,
        hasUnreadNotification:
            hasUnreadNotification ?? this.hasUnreadNotification,
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
  });

  final TrustedCircleKind kind;
  final int memberCount;
}

/// Immutable snapshot of everything the Home screen needs to render.
class HomeState {
  const HomeState({
    required this.greeting,
    required this.isProtected,
    required this.isLoading,
    required this.quickActions,
    required this.trustedCircles,
  });

  final HomeGreeting greeting;
  final bool isProtected;
  final bool isLoading;
  final List<QuickActionItem> quickActions;
  final List<TrustedCircleSummary> trustedCircles;

  factory HomeState.initial() => const HomeState(
        greeting: HomeGreeting(
          userName: 'Emma',
          subtitle: 'Stay safe, stay connected',
          hasUnreadNotification: true,
        ),
        isProtected: true,
        isLoading: false,
        quickActions: [
          QuickActionItem(type: QuickActionType.safety),
          QuickActionItem(type: QuickActionType.checkIn),
          QuickActionItem(type: QuickActionType.scheduledTimer),
        ],
        trustedCircles: [
          TrustedCircleSummary(kind: TrustedCircleKind.family, memberCount: 3),
          TrustedCircleSummary(kind: TrustedCircleKind.friends, memberCount: 2),
          TrustedCircleSummary(kind: TrustedCircleKind.partner, memberCount: 1),
          TrustedCircleSummary(kind: TrustedCircleKind.work, memberCount: 3),
        ],
      );

  HomeState copyWith({
    HomeGreeting? greeting,
    bool? isProtected,
    bool? isLoading,
    List<QuickActionItem>? quickActions,
    List<TrustedCircleSummary>? trustedCircles,
  }) {
    return HomeState(
      greeting: greeting ?? this.greeting,
      isProtected: isProtected ?? this.isProtected,
      isLoading: isLoading ?? this.isLoading,
      quickActions: quickActions ?? this.quickActions,
      trustedCircles: trustedCircles ?? this.trustedCircles,
    );
  }
}