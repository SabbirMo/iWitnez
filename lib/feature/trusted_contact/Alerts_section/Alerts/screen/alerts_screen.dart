import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Emergency', 'Safety', 'Updates'];

  final List<Map<String, dynamic>> _mockAlerts = [
    {
      'title': 'SOS Signal Received',
      'subtitle': 'John triggered an emergency SOS signal near 5th Avenue.',
      'time': '2m ago',
      'type': 'Emergency',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFFF3B30),
      'isUnread': true,
    },
    {
      'title': 'Safe Place Arrival',
      'subtitle': 'John arrived safely at Home.',
      'time': '1h ago',
      'type': 'Safety',
      'icon': Icons.shield_outlined,
      'color': const Color(0xFF10B981),
      'isUnread': false,
    },
    {
      'title': 'Low Battery Alert',
      'subtitle': "John's phone battery dropped below 15%.",
      'time': '3h ago',
      'type': 'Updates',
      'icon': Icons.battery_alert_rounded,
      'color': const Color(0xFFF59E0B),
      'isUnread': false,
    },
    {
      'title': 'Live Location Sharing Started',
      'subtitle': 'John started sharing live location with you.',
      'time': 'Yesterday',
      'type': 'Safety',
      'icon': Icons.location_on_outlined,
      'color': const Color(0xFF9124FF),
      'isUnread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredAlerts = _selectedFilter == 0
        ? _mockAlerts
        : _mockAlerts
              .where((item) => item['type'] == _filters[_selectedFilter])
              .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.alerts,
                    style: CustomTextStyle.bold30(
                      AppColors.textDark,
                    ).copyWith(fontSize: 24.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppString.trustedContact,
                    style: CustomTextStyle.regular14(AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Filter Chips
            SizedBox(
              height: 38.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF9124FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF9124FF)
                              : const Color(0xFFE5E7EB),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF9124FF,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          _filters[index],
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF4B5563),
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            // Alerts List
            Expanded(
              child: filteredAlerts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No alerts in this category',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6B7280),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 80.h),
                      itemCount: filteredAlerts.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = filteredAlerts[index];
                        final Color color = item['color'] as Color;
                        final bool isUnread = item['isUnread'] as bool;

                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isUnread
                                  ? color.withValues(alpha: 0.3)
                                  : const Color(0xFFF3F4F6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: color,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['title'] as String,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.sp,
                                              color: const Color(0xFF111827),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item['time'] as String,
                                          style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      item['subtitle'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF4B5563),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUnread) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  margin: EdgeInsets.only(top: 4.h),
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
