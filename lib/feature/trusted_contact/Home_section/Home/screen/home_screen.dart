import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/controller/home_controller.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/provider/home_provider.dart';
import 'package:iwitnez/feature/trusted_contact/Home_section/Home/widget/home_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const TrustedHomeController _controller = TrustedHomeController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trustedHomeProvider);
    final bottomClearance =
        68.h + MediaQuery.of(context).padding.bottom + 10.h;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, bottomClearance),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header: User avatar, greeting, notification bell
              TrustedHomeHeader(
                userName: state.userName,
                subtitle: state.userSubtitle,
                avatarUrl: state.userAvatarUrl,
                hasNotification: state.hasNotification,
                onNotificationTap: () =>
                    _controller.onNotificationTap(context, ref),
              ),
              SizedBox(height: 16.h),

              // 2. Someone You Care About Is safe with Us gradient banner
              const TrustedCareBanner(),
              SizedBox(height: 16.h),

              // 3. Emma's Live Location map card with radar & pin
              TrustedLiveLocationCard(
                wardName: state.wardName,
                wardStatus: state.wardStatus,
                address: state.wardAddress,
                wardAvatarUrl: state.wardAvatarUrl,
                onViewFullMapTap: () => _controller.onViewFullMapTap(context),
              ),
              SizedBox(height: 20.h),

              // 4. Quick Actions: Check In Status & Journey / ETA
              TrustedQuickActions(
                onCheckInStatusTap: () =>
                    _controller.onCheckInStatusTap(context),
                onJourneyEtaTap: () => _controller.onJourneyEtaTap(context),
              ),
              SizedBox(height: 24.h),

              // 5. Recent Activity: Emma checked in, Emma left Home, etc.
              TrustedRecentActivitySection(
                activities: state.activities,
                onViewAllTap: () => _controller.onViewAllActivityTap(context),
                onItemTap: (item) =>
                    _controller.onActivityItemTap(context, item),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
