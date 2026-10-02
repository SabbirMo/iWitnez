import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/provider/alerts_provider.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_history_card.dart';
import 'package:provider/provider.dart';

class AlertHistoryView extends StatelessWidget {
  const AlertHistoryView({super.key});

  void _showFilterModal(BuildContext context, AlertsProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        final filters = ['All', 'This Week', 'This Month', 'SOS Only'];
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
                      color: const Color(0xFFEAECF0),
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
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 12.h),
                ...filters.map((filter) {
                  final isSelected = provider.selectedFilter == filter;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      filter,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF7F56D9)
                            : const Color(0xFF344054),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF7F56D9),
                          )
                        : null,
                    onTap: () {
                      provider.setFilter(filter);
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertsProvider>();
    final history = provider.historyAlerts;

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
                  color: const Color(0xFF7F56D9),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Alert History',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),

            // "Filter" Pill Button
            InkWell(
              onTap: () => _showFilterModal(context, provider),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F3FF),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFE9D7FE),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt_rounded,
                      color: const Color(0xFF7F56D9),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Filter',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7F56D9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // 2. Alert History Cards List
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
      ],
    );
  }
}
