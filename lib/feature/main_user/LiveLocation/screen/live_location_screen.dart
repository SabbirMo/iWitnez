import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/provider/live_location_screen_provider.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/live_location_bottom_sheet.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/live_location_map_controls.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/live_location_map_view.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/widget/live_location_notice_card.dart';
import 'package:iwitnez/router/app_route_names.dart';

class LiveLocationScreen extends ConsumerStatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  ConsumerState<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends ConsumerState<LiveLocationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveLocationScreenProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: const Color(0xFF111827),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Live Location',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: BoxDecoration(
                    color: liveState.isSharing
                        ? const Color(0xFF10B981)
                        : const Color(0xFF9CA3AF),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  liveState.isSharing ? 'Sharing Live' : 'Sharing Paused',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: liveState.isSharing
                        ? const Color(0xFF10B981)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. Vector Map with user and contact pins
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0.38.sh,
            child: LiveLocationMapView(
              pulseAnimation: _pulseAnimation,
              onPersonPinTap: (person) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pinned location for ${person.name}'),
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              },
            ),
          ),

          // 2. Top Floating Notice Card ("Your location is being shared with 4 trusted contacts")
          Positioned(
            left: 16.w,
            right: 16.w,
            top: 12.h,
            child: LiveLocationNoticeCard(
              contactsCount: liveState.contacts
                  .where((c) =>
                      !c.name.toLowerCase().contains('(you)') &&
                      c.isSharingWith)
                  .length,
              onManageTap: () {
                context.push(AppRouteNames.manageSharingScreen);
              },
            ),
          ),

          // 3. Floating Map Controls (compass, layers, my location, zoom)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0.38.sh,
            child: const LiveLocationMapControls(),
          ),

          // 4. Draggable Bottom Sheet with Contacts, Sharing Settings, and Action Button
          LiveLocationBottomSheet(
            onPersonTap: (person) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Details for ${person.name} (${person.subtitle})'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
