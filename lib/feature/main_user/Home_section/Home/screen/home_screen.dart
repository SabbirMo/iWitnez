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
    final state = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: SafeArea(
        bottom: false,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(17.w, 10.h, 17.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeAppHeader(
                      userName: state.greeting.userName,
                      subtitle: state.greeting.subtitle,
                      hasUnreadNotification:
                          state.greeting.hasUnreadNotification,
                      onNotificationTap: () =>
                          _controller.onNotificationTap(context, ref),
                    ),
                    SizedBox(height: 6.h),
                    if (state.isProtected) const ProtectedBanner(),
                    SizedBox(height: 16.h),
                    LiveLocationCard(
                      onViewFullMapTap: () =>
                          _controller.onViewFullMapTap(context),
                      onToggleSharing: () =>
                          _controller.onToggleSharing(context),
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
                        onTap: () => _controller.onSosTap(context),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context, HomeState state) {
    return Row(
      children: [
        for (int i = 0; i < state.quickActions.length; i++) ...[
          if (i != 0) SizedBox(width: 14.w),
          Expanded(
            child: _buildQuickActionCard(context, state.quickActions[i]),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, QuickActionItem item) {
    final onTap = () => _controller.onQuickActionTap(context, item.type);
    return switch (item.type) {
      QuickActionType.safety => QuickActionCard.safety(onTap: onTap),
      QuickActionType.checkIn => QuickActionCard.checkIn(onTap: onTap),
      QuickActionType.scheduledTimer => QuickActionCard.scheduledTimer(
        onTap: onTap,
      ),
    };
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
    final onTap = () => _controller.onTrustedCircleTap(context, summary.kind);
    return switch (summary.kind) {
      TrustedCircleKind.family => TrustedCircleCard.family(
        onTap: onTap,
        memberCount: summary.memberCount,
      ),
      TrustedCircleKind.friends => TrustedCircleCard.friends(
        onTap: onTap,
        memberCount: summary.memberCount,
      ),
      TrustedCircleKind.partner => TrustedCircleCard.partner(
        onTap: onTap,
        memberCount: summary.memberCount,
      ),
      TrustedCircleKind.work => TrustedCircleCard.work(
        onTap: onTap,
        memberCount: summary.memberCount,
      ),
    };
  }
}
