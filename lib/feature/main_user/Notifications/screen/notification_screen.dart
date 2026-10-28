import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/user_role/user_role.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../model/notification_model.dart';
import '../provider/notification_provider.dart';
import '../widget/notification_card.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationControllerProvider.notifier).fetchNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      ref
          .read(notificationControllerProvider.notifier)
          .fetchNotifications(isSilent: true);
    }
  }

  void _onNotificationTap(
    BuildContext context,
    NotificationModel notif,
  ) {
    if (notif.isUnread) {
      ref.read(notificationControllerProvider.notifier).markAsRead(notif.id);
    }

    final role = ref.read(userRoleProvider);
    final isTrusted = role == UserRole.trustedContact;

    final type = notif.notificationType.toLowerCase();
    final iconType = notif.iconType.toLowerCase();

    try {
      if (type.contains('sos') ||
          type.contains('safety_alert') ||
          iconType == 'sos') {
        if (isTrusted) {
          context.go(AppRouteNames.trustedAlerts);
        } else {
          context.push(AppRouteNames.safetyTrackingScreen);
        }
      } else if (type.contains('check_in') || iconType == 'check_in') {
        if (isTrusted) {
          context.push(AppRouteNames.trustedCheckInStatusScreen);
        } else {
          context.push(AppRouteNames.checkInScreen);
        }
      } else if (type.contains('live_location') ||
          iconType == 'live_location' ||
          iconType == 'safe_place') {
        if (isTrusted) {
          context.push(AppRouteNames.trustedLiveLocationScreen);
        } else {
          context.push(AppRouteNames.liveLocationScreen);
        }
      } else if (type.contains('missed_call') ||
          type.contains('call') ||
          iconType == 'call') {
        if (isTrusted) {
          context.go(AppRouteNames.trustedCalls);
        } else {
          context.go(AppRouteNames.mainUserCalls);
        }
      }
    } catch (e) {
      debugPrint('Notification navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationControllerProvider);
    final notifier = ref.read(notificationControllerProvider.notifier);

    final hasUnread = state.unreadCount > 0 ||
        state.notifications.any((notif) => notif.isUnread);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF101828),
            size: 20.sp,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            color: const Color(0xFF101828),
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: (!hasUnread || state.isMarkingAll)
                ? null
                : () async {
                    await notifier.markAllAsRead();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications marked as read'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
            child: state.isMarkingAll
                ? SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF6941C6)),
                    ),
                  )
                : Text(
                    'Mark all',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: hasUnread
                          ? const Color(0xFF6941C6)
                          : const Color(0xFF98A2B3),
                    ),
                  ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF6941C6),
        onRefresh: () => notifier.fetchNotifications(),
        child: state.isLoading && state.notifications.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6941C6)),
                ),
              )
            : state.notifications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      SizedBox(height: 140.h),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64.r,
                              height: 64.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF4EBFF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: const Color(0xFF6941C6),
                                size: 32.sp,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No notifications yet',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF101828),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "We'll notify you when something arrives.",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                    children: [
                      for (final entry in state.sections.entries)
                        if (entry.value.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.only(
                              top: 8.h,
                              bottom: 10.h,
                              left: 4.w,
                            ),
                            child: Text(
                              entry.key,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF101828),
                              ),
                            ),
                          ),
                          for (final notif in entry.value)
                            NotificationCard(
                              notification: notif,
                              onTap: () =>
                                  _onNotificationTap(context, notif),
                            ),
                          SizedBox(height: 8.h),
                        ],
                      SizedBox(height: 24.h),
                    ],
                  ),
      ),
    );
  }
}
