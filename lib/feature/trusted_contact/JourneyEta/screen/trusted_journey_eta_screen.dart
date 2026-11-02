import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/journey_eta_provider.dart';
import '../widget/journey_date_card.dart';
import '../widget/journey_map_view.dart';
import '../widget/journey_timeline_card.dart';

class TrustedJourneyEtaScreen extends ConsumerWidget {
  const TrustedJourneyEtaScreen({super.key});

  String _formatDisplayDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journeyEtaProvider);
    final notifier = ref.read(journeyEtaProvider.notifier);
    final journeyData = state.data;
    final isToday = journeyData?.isToday ?? false;

    final String sectionTitle = state.selectedDate != null
        ? _formatDisplayDate(state.selectedDate!)
        : (journeyData != null && journeyData.dateDisplay.isNotEmpty
            ? journeyData.dateDisplay
            : (isToday ? 'Today' : ''));

    ref.listen<JourneyEtaState>(journeyEtaProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

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
          'Journey & ETA',
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
        child: Builder(
          builder: (context) {
            // 1. Initial Loading
            if (state.isLoading && journeyData == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C48F5),
                ),
              );
            }

            // 2. Error State
            if (state.error != null && journeyData == null) {
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
                        state.error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: const Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      ElevatedButton(
                        onPressed: () => notifier.fetchJourney(),
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

            return RefreshIndicator(
              color: const Color(0xFF6C48F5),
              onRefresh: () async {
                await notifier.refresh();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. History Route Map with Start and End pins
                    SizedBox(
                      height: 250.h,
                      child: const JourneyMapView(),
                    ),

                    // 2. Content below map
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.w,
                        14.h,
                        16.w,
                        40.h + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sectionTitle.isNotEmpty) ...[
                            Text(
                              sectionTitle,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 12.h),
                          ],

                          // Timeline Card
                          JourneyTimelineCard(
                            items: journeyData?.timeline ?? const [],
                            isToday: isToday,
                            dateDisplay: sectionTitle,
                            isLoading: state.isLoading,
                          ),
                          SizedBox(height: 14.h),

                          // Select Date Card (scrolls with the page)
                          JourneyDateCard(
                            selectedDate: state.selectedDate,
                            dateDisplay: sectionTitle,
                            onTap: () async {
                              final initialDate =
                                  state.selectedDate ?? DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
