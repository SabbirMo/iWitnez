import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/controller/home_controller.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/model/home_model.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/main_user/Home_section/Home/widget/home_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static final HomeController _controller = HomeController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHome = ref.watch(homeProvider);
    final state = asyncHome.value ?? HomeState.initial();
    final bottomClearance =
        68.h + MediaQuery.of(context).padding.bottom + 10.h;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(homeProvider.notifier).fetchHomeData(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding:
                      EdgeInsets.fromLTRB(17.w, 10.h, 17.w, bottomClearance),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeAppHeader(
                        userName: state.greeting.userName,
                        subtitle: state.greeting.subtitle,
                        avatarUrl: state.greeting.avatarUrl,
                        userFullName: state.userProfile?.fullName,
                        hasUnreadNotification:
                            state.greeting.hasUnreadNotification,
                        onNotificationTap: () =>
                            _controller.onNotificationTap(context, ref),
                      ),
                      if (state.isProtected) const ProtectedBanner(),
                      SizedBox(height: 16.h),
                      LiveLocationCard(
                        isSharing: state.liveLocation?.isSharingLive ?? false,
                        address: state.liveLocation?.address ??
                            '1200 Park Ave, New York, NY 10028, USA',
                        latitude: state.liveLocation?.latitude,
                        longitude: state.liveLocation?.longitude,
                        peopleSharing:
                            state.liveLocation?.peopleSharing ?? const [],
                        onViewFullMapTap: () =>
                            _controller.onViewFullMapTap(context),
                        onToggleSharing: () {
                          ref.read(homeProvider.notifier).toggleSharing();
                          _controller.onToggleSharing(context);
                        },
                      ),
                      SizedBox(height: 20.h),
                      const SectionHeader(title: 'Quick Actions'),
                      SizedBox(height: 14.h),
                      _buildQuickActionsRow(context, state),
                      SizedBox(height: 30.h),
                      SectionHeader(
                        title: 'Trusted Circles',
                        actionLabel: 'View all',
                        onActionTap: () =>
                            _controller.onViewAllTrustedCirclesTap(context),
                      ),
                      SizedBox(height: 16.h),
                      _buildTrustedCirclesRow(context, state),
                      SizedBox(height: 18.h),
                      Center(
                        child: AnimatedSosButton(
                          onTap: () => _controller.onSosTap(
                            context,
                            latitude: state.liveLocation?.latitude,
                            longitude: state.liveLocation?.longitude,
                            address: state.liveLocation?.address,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context, HomeState state) {
    return Row(
      children: [
        for (int i = 0; i < state.quickActions.length; i++) ...[
          if (i > 0) SizedBox(width: 14.w),
          Expanded(
            child: QuickActionCard(
              type: state.quickActions[i].type,
              onTap: () => _controller.onQuickActionTap(
                context,
                state.quickActions[i].type,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrustedCirclesRow(BuildContext context, HomeState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int i = 0; i < state.trustedCircles.length; i++) ...[
            if (i != 0) SizedBox(width: 14.w),
            _buildTrustedCircleCard(context, state.trustedCircles[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildTrustedCircleCard(
    BuildContext context,
    TrustedCircleSummary summary,
  ) {
    void onTap() => _controller.onTrustedCircleTap(context, summary.kind);
    return switch (summary.kind) {
      TrustedCircleKind.family => TrustedCircleCard.family(
        onTap: onTap,
        memberCount: summary.memberCount,
        avatars: summary.avatars ?? const [],
      ),
      TrustedCircleKind.friends => TrustedCircleCard.friends(
        onTap: onTap,
        memberCount: summary.memberCount,
        avatars: summary.avatars ?? const [],
      ),
      TrustedCircleKind.partner => TrustedCircleCard.partner(
        onTap: onTap,
        memberCount: summary.memberCount,
        avatars: summary.avatars ?? const [],
      ),
      TrustedCircleKind.work => TrustedCircleCard.work(
        onTap: onTap,
        memberCount: summary.memberCount,
        avatars: summary.avatars ?? const [],
      ),
      TrustedCircleKind.other => TrustedCircleCard.other(
        onTap: onTap,
        memberCount: summary.memberCount,
        avatars: summary.avatars ?? const [],
      ),
    };
  }
}
