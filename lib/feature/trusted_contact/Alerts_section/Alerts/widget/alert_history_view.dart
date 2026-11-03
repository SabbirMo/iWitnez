import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/widgets/shimmer_loading.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/provider/alerts_provider.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_history_card.dart';
import 'package:provider/provider.dart';

class AlertHistoryView extends StatelessWidget {
  const AlertHistoryView({super.key});

  void _showFilterModal(BuildContext context, AlertsProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF181A26) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        final filters = [
          {'label': 'All Alerts', 'value': 'all'},
          {'label': 'SOS Only', 'value': 'sos'},
          {'label': 'Video Only', 'value': 'video'},
          {'label': 'Audio Only', 'value': 'audio'},
        ];
        return SafeArea(
          child: Padding(
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
                      color: isDark
                          ? const Color(0xFF344054)
                          : const Color(0xFFEAECF0),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Filter History',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 12.h),
                ...filters.map((filter) {
                  final isSelected = provider.selectedFilter == filter['value'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      filter['label']!,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF7F56D9)
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF344054)),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF7F56D9),
                          )
                        : null,
                    onTap: () {
                      provider.setFilter(filter['value']!);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFilterButtonText(String filter) {
    switch (filter.toLowerCase()) {
      case 'sos':
        return 'SOS';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'all':
      default:
        return 'Filter';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = provider.historyAlerts;
    final isLoading = provider.isHistoryLoading;
    final error = provider.historyError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Subheader: "Alert History" Calendar Row & "Filter" Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Calendar icon + "Alert History"
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: isDark
                      ? const Color(0xFF9E77ED)
                      : const Color(0xFF7F56D9),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Alert History',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ],
            ),

            // "Filter" Pill Button
            InkWell(
              onTap: () => _showFilterModal(context, provider),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: provider.selectedFilter != 'all'
                      ? const Color(0xFF7F56D9)
                      : (isDark
                          ? const Color(0xFF261D42)
                          : const Color(0xFFF4F3FF)),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF4C2ECC)
                        : const Color(0xFFE9D7FE),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt_rounded,
                      color: provider.selectedFilter != 'all'
                          ? Colors.white
                          : (isDark
                              ? const Color(0xFFD6BBFB)
                              : const Color(0xFF7F56D9)),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _getFilterButtonText(provider.selectedFilter),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: provider.selectedFilter != 'all'
                            ? Colors.white
                            : (isDark
                                ? const Color(0xFFD6BBFB)
                                : const Color(0xFF7F56D9)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // 2. Alert History Cards List / Loading / Error / Empty States
        if (isLoading && history.isEmpty)
          const AlertsListShimmer(count: 3)
        else if (error != null && history.isEmpty)
          _buildErrorState(context, provider, error, isDark)
        else if (history.isEmpty)
          _buildEmptyState(context, provider, isDark)
        else
          Stack(
            children: [
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: history.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  return AlertHistoryCard(item: history[index]);
                },
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: (isDark ? Colors.black : Colors.white)
                        .withValues(alpha: 0.4),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7F56D9),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 104.h,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181A26) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF262938) : const Color(0xFFF2F4F7),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              children: [
                Container(
                  width: 86.w,
                  height: 98.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF262938)
                        : const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262938)
                              : const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 70.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262938)
                              : const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262938)
                              : const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 58.w,
                  height: 84.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF262938)
                        : const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AlertsProvider provider,
    String error,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFF2F4F7),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFF04438),
            size: 40.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'Failed to Load Alert History',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085),
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => provider.fetchAlertHistory(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7F56D9),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AlertsProvider provider,
    bool isDark,
  ) {
    final isFiltered = provider.selectedFilter != 'all';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFF2F4F7),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF261D42)
                  : const Color(0xFFF4F3FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              color: isDark
                  ? const Color(0xFFD6BBFB)
                  : const Color(0xFF7F56D9),
              size: 32.sp,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            isFiltered ? 'No Matching Alerts' : 'No Alert History Yet',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            isFiltered
                ? 'No alerts recorded under the "${_getFilterButtonText(provider.selectedFilter)}" filter.'
                : 'Emergency alerts and recordings will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085),
            ),
          ),
          if (isFiltered) ...[
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: () => provider.setFilter('all'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark
                    ? const Color(0xFF9E77ED)
                    : const Color(0xFF7F56D9),
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF9E77ED)
                      : const Color(0xFF7F56D9),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              child: const Text('Show All Alerts'),
            ),
          ],
        ],
      ),
    );
  }
}
