import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/router/app_route_names.dart';

class TrustedNotificationItem {
  final String title;
  final String description;
  final String time;
  final bool isUnread;
  final bool isHighlightCard;
  final Widget leading;
  final VoidCallback? onTap;

  const TrustedNotificationItem({
    required this.title,
    required this.description,
    required this.time,
    this.isUnread = true,
    this.isHighlightCard = false,
    required this.leading,
    this.onTap,
  });
}

class TrustedNotificationScreen extends StatelessWidget {
  const TrustedNotificationScreen({super.key});

  void _navigateToAlerts(BuildContext context) {
    try {
      context.go(AppRouteNames.trustedAlerts);
    } catch (e) {
      debugPrint('Navigation to alerts error: $e');
    }
  }

  void _navigateToCheckIn(BuildContext context) {
    try {
      context.push(AppRouteNames.checkInScreen);
    } catch (_) {
      context.go(AppRouteNames.checkInScreen);
    }
  }

  void _navigateToLiveLocation(BuildContext context) {
    try {
      context.push(AppRouteNames.trustedLiveLocationScreen);
    } catch (_) {
      context.go(AppRouteNames.trustedLiveLocationScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = [
      // 1. SOS Alert (Highlight Card)
      TrustedNotificationItem(
        title: 'SOS Alert',
        description: 'Emma has triggered SOS.\nLive video is available.',
        time: 'Just now',
        isUnread: true,
        isHighlightCard: true,
        leading: Container(
          width: 44.r,
          height: 44.r,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE4E2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            'sos',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF04438),
              letterSpacing: 0.5,
            ),
          ),
        ),
        onTap: () => _navigateToAlerts(context),
      ),

      // 2. Emma checked in
      TrustedNotificationItem(
        title: 'Emma checked in',
        description: 'Today, 10:30 AM',
        time: '2m ago',
        isUnread: true,
        leading: Container(
          width: 44.r,
          height: 44.r,
          decoration: const BoxDecoration(
            color: Color(0xFFE6F9F0),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.check_circle_outline_rounded,
            color: const Color(0xFF12B76A),
            size: 22.sp,
          ),
        ),
        onTap: () => _navigateToCheckIn(context),
      ),

      // 3. Emma left Home
      TrustedNotificationItem(
        title: 'Emma left Home',
        description: 'Today, 08:15 AM',
        time: '2h ago',
        isUnread: true,
        leading: Container(
          width: 44.r,
          height: 44.r,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE4E2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.notifications_none_rounded,
            color: const Color(0xFFF04438),
            size: 22.sp,
          ),
        ),
        onTap: () => _navigateToLiveLocation(context),
      ),

      // 4. Live video started
      TrustedNotificationItem(
        title: 'Live video started',
        description: "Emma's live video is now\nstreaming.",
        time: '2h ago',
        isUnread: true,
        leading: Container(
          width: 44.r,
          height: 44.r,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF8FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.videocam_outlined,
            color: const Color(0xFF2E90FA),
            size: 22.sp,
          ),
        ),
        onTap: () => _navigateToAlerts(context),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),

            // "Today" Section Header
            Text(
              'Today',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF101828),
              ),
            ),
            SizedBox(height: 12.h),

            // Notification List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (context, index) {
                // If the previous or current item is highlight card, give space, otherwise divider
                if (index == 0) {
                  return SizedBox(height: 12.h);
                }
                return Divider(
                  height: 1,
                  thickness: 0.6,
                  color: const Color(0xFFF2F4F7),
                );
              },
              itemBuilder: (context, index) {
                final item = notifications[index];

                if (item.isHighlightCard) {
                  return InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFFEE4E2).withValues(alpha: 0.6),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          item.leading,
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF101828),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  item.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF667085),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.time,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF667085),
                                ),
                              ),
                              if (item.isUnread) ...[
                                SizedBox(height: 10.h),
                                Container(
                                  width: 7.r,
                                  height: 7.r,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6941C6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Standard Notification Tile
                return InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        item.leading,
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF101828),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.description,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF667085),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.time,
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF667085),
                              ),
                            ),
                            if (item.isUnread) ...[
                              SizedBox(height: 8.h),
                              Container(
                                width: 7.r,
                                height: 7.r,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6941C6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
