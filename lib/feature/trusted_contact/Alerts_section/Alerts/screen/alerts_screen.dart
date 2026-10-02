import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/provider/alerts_provider.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_audio_recording_card.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_history_view.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_live_location_card.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/alert_video_recording_card.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/widget/emergency_alert_banner.dart';
import 'package:provider/provider.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlertsProvider(),
      child: const _AlertsScreenView(),
    );
  }
}

class _AlertsScreenView extends StatelessWidget {
  const _AlertsScreenView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Header: Title & Subtitle
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alerts',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Stay informed, stay prepared',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Tabs Row: Active | History
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEAECF0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Active Tab
                  Expanded(
                    child: InkWell(
                      onTap: () => provider.selectTab(0),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: provider.selectedTab == 0
                                  ? const Color(0xFF7F56D9)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Active',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: provider.selectedTab == 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: provider.selectedTab == 0
                                  ? const Color(0xFF7F56D9)
                                  : const Color(0xFF667085),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // History Tab
                  Expanded(
                    child: InkWell(
                      onTap: () => provider.selectTab(1),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: provider.selectedTab == 1
                                  ? const Color(0xFF7F56D9)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'History',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: provider.selectedTab == 1
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: provider.selectedTab == 1
                                  ? const Color(0xFF7F56D9)
                                  : const Color(0xFF667085),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 80.h),
                child: provider.selectedTab == 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          // Emergency Alert Banner
                          EmergencyAlertBanner(),
                          SizedBox(height: 14),

                          // Emma's Live Location Card
                          AlertLiveLocationCard(),
                          SizedBox(height: 14),

                          // Video Recording Player Card
                          AlertVideoRecordingCard(),
                          SizedBox(height: 14),

                          // Audio Recording Player Card
                          AlertAudioRecordingCard(),
                        ],
                      )
                    : const AlertHistoryView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
