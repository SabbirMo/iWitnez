import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/widgets/shimmer_loading.dart';
import '../provider/check_in_status_provider.dart';
import '../widget/check_in_location_card.dart';
import '../widget/check_in_missed_card.dart';
import '../widget/check_in_not_setup_card.dart';
import '../widget/check_in_profile_card.dart';
import '../widget/check_in_success_card.dart';

class TrustedCheckInStatusScreen extends ConsumerWidget {
  const TrustedCheckInStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusState = ref.watch(checkInStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D0E15)
          : const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D0E15) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: isDark ? Colors.white : const Color(0xFF111827),
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
          'Check In Status',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            // 1. Initial Loading State
            if (statusState.isLoading && statusState.data == null) {
              return const CheckInStatusShimmer();
            }

            // 2. Error State
            if (statusState.error != null && statusState.data == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 54.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        statusState.error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(checkInStatusProvider.notifier)
                              .fetchCheckInStatus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C48F5),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 10.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.inter(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = statusState.data;
            if (data == null) {
              return const SizedBox.shrink();
            }

            return RefreshIndicator(
              color: const Color(0xFF6C48F5),
              onRefresh: () async {
                await ref.read(checkInStatusProvider.notifier).refresh();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Profile Card
                    CheckInProfileCard(data: data),
                    SizedBox(height: 16.h),

                    // 2. State-Based Content
                    if (data.isNotSetUp) ...[
                      // Screen 128: Check-In Not Set Up
                      CheckInNotSetupCard(
                        wardName: data.wardName,
                        title: data.cardTitle,
                        subtitle: data.cardSubtitle,
                      ),
                    ] else if (data.isMissed) ...[
                      // Screen 129: Emma hasn't Checked In
                      if (data.note.isNotEmpty) ...[
                        _buildNoteSection(context, data.wardName, data.note),
                        SizedBox(height: 16.h),
                      ],
                      if (data.location.isAvailable) ...[
                        CheckInLocationCard(
                          isLive: false,
                          address: data.location.address,
                          statusText: 'Last Known',
                          updateTimeText: data.location.updatedAgo,
                          latitude: data.location.latitude != 0.0
                              ? data.location.latitude
                              : null,
                          longitude: data.location.longitude != 0.0
                              ? data.location.longitude
                              : null,
                        ),
                        SizedBox(height: 16.h),
                      ],
                      CheckInMissedCard(
                        wardName: data.wardName,
                        title: data.cardTitle,
                        subtitle: data.cardSubtitle,
                        lastCheckInTime: data.checkedInAtDisplay,
                      ),
                    ] else ...[
                      // Screen 127: Emma is Checked In (Default / checked_in)
                      if (data.note.isNotEmpty) ...[
                        _buildNoteSection(context, data.wardName, data.note),
                        SizedBox(height: 16.h),
                      ],
                      if (data.location.isAvailable ||
                          data.location.address.isNotEmpty) ...[
                        CheckInLocationCard(
                          isLive: true,
                          address: data.location.address,
                          statusText: 'Live',
                          updateTimeText: data.location.updatedAgo,
                          latitude: data.location.latitude != 0.0
                              ? data.location.latitude
                              : null,
                          longitude: data.location.longitude != 0.0
                              ? data.location.longitude
                              : null,
                        ),
                        SizedBox(height: 16.h),
                      ],
                      CheckInSuccessCard(
                        wardName: data.wardName,
                        title: data.cardTitle,
                        subtitle: data.cardSubtitle,
                        checkInTime: data.checkedInAtDisplay,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoteSection(BuildContext context, String wardName, String note) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note From $wardName',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132B1D) : const Color(0xFFEDF8F1),
            borderRadius: BorderRadius.circular(12.r),
            border: isDark ? Border.all(color: const Color(0xFF1E462E)) : null,
          ),
          child: Text(
            note,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}
