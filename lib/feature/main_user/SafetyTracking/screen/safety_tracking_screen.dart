import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/provider/safety_tracking_provider.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/widget/safe_places_card.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/widget/safety_alerts_card.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/widget/safety_history_date_card.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/widget/safety_history_map_view.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/widget/safety_history_timeline_card.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/widget/safety_tracking_map_view.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/widget/safety_tracking_tab_selector.dart';
import 'package:iwitnez/router/app_route_names.dart';

class SafetyTrackingScreen extends ConsumerWidget {
  const SafetyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetyTrackingProvider);
    final notifier = ref.read(safetyTrackingProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
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
        title: Text(
          'Safety Tracking',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Tab Selector Capsule: Live Tracking / History
            SafetyTrackingTabSelector(
              tabs: const ['Live Tracking', 'History'],
              selectedIndex: state.selectedTabIndex,
              onTabSelected: (index) => notifier.setTabIndex(index),
            ),

            // Tab Content
            Expanded(
              child: state.selectedTabIndex == 0
                  ? _buildLiveTrackingContent(context, ref, state, notifier)
                  : _buildHistoryContent(context, ref, state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTrackingContent(
    BuildContext context,
    WidgetRef ref,
    SafetyTrackingState state,
    SafetyTrackingNotifier notifier,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Vector Map View with user pin and controls
          SizedBox(height: 270.h, child: const SafetyTrackingMapView()),

          // 2. Cards Below Map
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
            child: Column(
              children: [
                // Safe Places Card
                SafePlacesCard(
                  places: state.safePlaces,
                  onManageTap: () {
                    _showManagePlacesSheet(context, ref);
                  },
                  onPlaceTap: (place) {
                    notifier.togglePlaceStatus(place.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${place.title} status changed to ${!place.isInside ? "Inside" : "Outside"}',
                        ),
                        duration: const Duration(milliseconds: 1400),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onAddSafePlaceTap: () {
                    context.push(AppRouteNames.addSafePlaceScreen);
                  },
                ),
                SizedBox(height: 14.h),

                // Alerts Card
                SafetyAlertsCard(
                  onTap: () {
                    context.push(AppRouteNames.safetySettingsScreen);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(
    BuildContext context,
    WidgetRef ref,
    SafetyTrackingState state,
    SafetyTrackingNotifier notifier,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. History Route Map with Start and End pins
          SizedBox(height: 250.h, child: const SafetyHistoryMapView()),

          // 2. Content below map
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title: "Today"
                Text(
                  'Today',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 12.h),

                // Timeline Card
                SafetyHistoryTimelineCard(items: state.timelineItems),
                SizedBox(height: 14.h),

                // Select Date Card
                SafetyHistoryDateCard(
                  selectedDate: state.selectedDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF6C48F5),
                              onPrimary: Colors.white,
                              onSurface: Color(0xFF111827),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      notifier.setDate(picked);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManagePlacesSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        final currentPlaces = ref.watch(safetyTrackingProvider).safePlaces;
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Manage Safe Places',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 12.h),
              for (final place in currentPlaces)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: place.displayBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      place.displayIcon,
                      color: place.displayIconColor,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    place.title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    place.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                    ),
                    onPressed: () {
                      ref
                          .read(safetyTrackingProvider.notifier)
                          .removeSafePlace(place.id);
                      Navigator.of(bottomSheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${place.title} removed'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
