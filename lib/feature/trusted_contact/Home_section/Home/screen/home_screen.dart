import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
        child: RefreshIndicator(
          color: const Color(0xFF8B2CF5),
          onRefresh: () => ref
              .read(trustedHomeProvider.notifier)
              .fetchDashboard(forceRefresh: true),
          child: state.isLoading && state.monitoredUser == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B2CF5),
                  ),
                )
              : state.errorMessage != null && state.monitoredUser == null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48.sp,
                              color: const Color(0xFF98A2B3),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: const Color(0xFF667085),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(trustedHomeProvider.notifier)
                                  .fetchDashboard(forceRefresh: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B2CF5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100.r),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.inter(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                          16.w, 10.h, 16.w, bottomClearance),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Top Header: User avatar, greeting, notification bell
                          TrustedHomeHeader(
                            greeting: state.greeting,
                            userName: state.userName,
                            subtitle: state.userSubtitle,
                            avatarUrl: state.userAvatarUrl,
                            hasNotification: state.hasNotification,
                            unreadNotificationsCount:
                                state.unreadNotificationsCount,
                            onNotificationTap: () =>
                                _controller.onNotificationTap(context, ref),
                          ),
                          SizedBox(height: 16.h),

                          // 2. Someone You Care About Is safe with Us gradient banner
                          if (state.safetyBanner != null) ...[
                            TrustedCareBanner(
                              title: state.safetyBanner!.title,
                              description: state.safetyBanner!.description,
                            ),
                            SizedBox(height: 16.h),
                          ],

                          // 3. Live Location map card with radar & pin
                          TrustedLiveLocationCard(
                            wardName: state.wardName,
                            wardStatus: state.wardStatus,
                            address: state.wardAddress,
                            wardAvatarUrl: state.wardAvatarUrl,
                            isOnline: state.monitoredUser?.isOnline ?? true,
                            onViewFullMapTap: () =>
                                _controller.onViewFullMapTap(context),
                          ),
                          SizedBox(height: 20.h),

                          // 4. Quick Actions: Check In Status & Journey / ETA
                          if (state.quickActions.isNotEmpty) ...[
                            TrustedQuickActions(
                              actions: state.quickActions,
                              onCheckInStatusTap: () =>
                                  _controller.onCheckInStatusTap(context),
                              onJourneyEtaTap: () =>
                                  _controller.onJourneyEtaTap(context),
                            ),
                            SizedBox(height: 24.h),
                          ],

                          // 5. Recent Activity: Emma checked in, Emma left Home, etc.
                          TrustedRecentActivitySection(
                            activities: state.activities,
                            onViewAllTap: () =>
                                _controller.onViewAllActivityTap(context),
                            onItemTap: (item) =>
                                _controller.onActivityItemTap(context, item),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
