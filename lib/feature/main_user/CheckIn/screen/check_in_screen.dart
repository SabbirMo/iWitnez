import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/feature/main_user/CheckIn/provider/check_in_provider.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/check_in_complete_banner_card.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/check_in_completed_location_card.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/check_in_location_card.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/check_in_shared_with_card.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/check_in_time_card.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/im_safe_banner_card.dart';
import 'package:iwitnez/feature/main_user/ScheduledTimer/model/scheduled_check_in_model.dart';
import 'package:iwitnez/router/app_route_names.dart';

class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkInProvider);
    final notifier = ref.read(checkInProvider.notifier);
    final isCompleted = state.pageData.isCompleted;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
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
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Check-In',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: state.isLoadingPage &&
                state.pageData.yourLocation.address.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8B5CF6),
                ),
              )
            : RefreshIndicator(
                onRefresh: notifier.loadCheckInPage,
                color: const Color(0xFF8B5CF6),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Subtitle
                      Center(
                        child: isCompleted
                            ? Text(
                                "You've already checked in today.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              )
                            : Column(
                                children: [
                                  Text(
                                    'Let your trusted circles know',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    "you're safe with your current location.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      SizedBox(height: 16.h),

                      // 1. Top Banner Card (Complete vs Pending)
                      if (isCompleted)
                        const CheckInCompleteBannerCard()
                      else
                        const ImSafeBannerCard(),

                      SizedBox(height: 14.h),

                      // 2. Middle Cards (Order matches screenshots)
                      if (isCompleted) ...[
                        // Complete State: Check-In Time Card -> Your Location -> Shared with
                        CheckInTimeCard(
                          timeText: state.pageData.checkInTimeDisplay.isNotEmpty
                              ? state.pageData.checkInTimeDisplay
                              : 'Today',
                          isCompleted: true,
                          statusBadge: state.pageData.statusBadge.isNotEmpty
                              ? state.pageData.statusBadge
                              : 'Checked In',
                        ),
                        SizedBox(height: 14.h),

                        CheckInCompletedLocationCard(
                          address: state.pageData.yourLocation.address,
                          latitude: state.pageData.yourLocation.latitude,
                          longitude: state.pageData.yourLocation.longitude,
                        ),
                        SizedBox(height: 14.h),

                        CheckInSharedWithCard(
                          sharedWith: state.pageData.sharedWith,
                          isCompleted: true,
                        ),
                        SizedBox(height: 24.h),

                        // Action 1: 📍 Update Location Button (Outlined)
                        Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(
                              color: const Color(0xFF7C3AED),
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25.r),
                              onTap: state.isUpdatingLocation
                                  ? null
                                  : () => notifier.checkInNow(
                                        context,
                                        isUpdateLocation: true,
                                      ),
                              child: Center(
                                child: state.isUpdatingLocation
                                    ? SizedBox(
                                        width: 20.r,
                                        height: 20.r,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF7C3AED),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: const Color(0xFF7C3AED),
                                            size: 19.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Update Location',
                                            style: GoogleFonts.inter(
                                              fontSize: 14.5.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF7C3AED),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Action 2: 🏠 Back to Home Button (Gradient)
                        CustomButton(
                          text: 'Back to Home',
                          icon: Icons.home_outlined,
                          isLeadingIcon: true,
                          height: 50.h,
                          borderRadius: 25.r,
                          onTap: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                        ),
                      ] else ...[
                        // Pending State: Your Location (with map preview) -> Shared with -> Check-in Time -> Check In Now
                        CheckInLocationCard(
                          latitude: state.pageData.yourLocation.latitude,
                          longitude: state.pageData.yourLocation.longitude,
                          address: state.pageData.yourLocation.address,
                          accuracy: state.pageData.yourLocation.accuracyDisplay
                                  .isNotEmpty
                              ? state.pageData.yourLocation.accuracyDisplay
                              : (state.pageData.yourLocation.accuracy != null
                                  ? 'Accuracy: ±${state.pageData.yourLocation.accuracy!.toStringAsFixed(0)} m'
                                  : ''),
                          isUpdating: state.isUpdatingLocation,
                          onUpdateTap: () =>
                              notifier.updateCurrentLocation(context),
                        ),
                        SizedBox(height: 14.h),

                        CheckInSharedWithCard(
                          sharedWith: state.pageData.sharedWith,
                          isCompleted: false,
                        ),
                        SizedBox(height: 14.h),

                        CheckInTimeCard(
                          timeText: state.pageData.checkInTimeDisplay.isNotEmpty
                              ? state.pageData.checkInTimeDisplay
                              : 'Set a check-in timer',
                          isCompleted: false,
                          onTap: () async {
                            final result = await context
                                .push(AppRouteNames.scheduledTimerScreen);
                            if (result is ScheduledCheckInModel &&
                                result.scheduledTimeDisplay != null &&
                                result.scheduledTimeDisplay!.isNotEmpty) {
                              notifier.updateCheckInTimeDisplay(
                                result.scheduledTimeDisplay!,
                              );
                            }
                            await notifier.loadCheckInPage();
                          },
                        ),
                        SizedBox(height: 24.h),

                        CustomButton(
                          text: 'Check In Now',
                          icon: Icons.check_rounded,
                          isLeadingIcon: true,
                          isLoading: state.isCheckingIn,
                          height: 52.h,
                          borderRadius: 26.r,
                          onTap: state.isCheckingIn
                              ? null
                              : () => notifier.checkInNow(context),
                        ),
                        SizedBox(height: 12.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 13.sp,
                              color: const Color(0xFF6B7280),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Your location is only shared with trusted circles.',
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
