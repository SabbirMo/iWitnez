import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/widgets/shimmer_loading.dart';
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

class _AlertsScreenView extends StatefulWidget {
  const _AlertsScreenView();

  @override
  State<_AlertsScreenView> createState() => _AlertsScreenViewState();
}

class _AlertsScreenViewState extends State<_AlertsScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final prov = context.read<AlertsProvider>();
        if (prov.selectedTab == 0) {
          prov.fetchActiveAlert();
        } else {
          prov.fetchAlertHistory();
        }
      }
    });
  }

  Widget _buildActiveTab(AlertsProvider provider, bool isDark) {
    if (provider.isActiveAlertLoading && provider.activeAlert == null) {
      return const AlertsListShimmer(count: 1);
    }

    if (provider.activeAlertError != null && provider.activeAlert == null) {
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
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFF04438),
              size: 40.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              'Failed to Load Active Alert',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              provider.activeAlertError!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => provider.fetchActiveAlert(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7F56D9),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final alert = provider.activeAlert;

    // When there is NO active alert returned by the real API:
    if (alert == null || !alert.hasActiveAlert) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181A26) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? const Color(0xFF262938) : const Color(0xFFF2F4F7),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF132F20)
                    : const Color(0xFFECFDF3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: isDark
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFF039855),
                size: 36.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'No Active Emergency Alert',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'There is currently no emergency alert active.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085),
              ),
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: () => provider.fetchActiveAlert(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh Status'),
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
              ),
            ),
          ],
        ),
      );
    }

    // When active alert IS present in API: render ONLY real API data
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emergency Alert Banner
        EmergencyAlertBanner(alert: alert),
        const SizedBox(height: 14),

        // Acknowledge & Resolve Actions Bar
        if (alert.alertId != null && alert.alertId!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Row(
              children: [
                if (!alert.isAcknowledged) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final ok =
                            await provider.acknowledgeAlert(alert.alertId!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok
                                  ? 'Emergency alert acknowledged.'
                                  : 'Failed to acknowledge alert.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Acknowledge'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C48F5),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await provider.resolveAlert(alert.alertId!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? 'Emergency alert marked as resolved.'
                                : 'Failed to resolve alert.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Mark Resolved'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(
                        color: Color(0xFF10B981),
                        width: 1.5,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Emma's Live Location Card (Real API data only)
        if (alert.location != null) ...[
          AlertLiveLocationCard(
            location: alert.location!,
            userName: alert.userName,
          ),
          const SizedBox(height: 14),
        ],

        // Video Recording Player Card (Real API data only)
        if (alert.videoRecording != null) ...[
          AlertVideoRecordingCard(video: alert.videoRecording!),
          const SizedBox(height: 14),
        ],

        // Audio Recording Player Card (Real API data only)
        if (alert.audioRecording != null) ...[
          AlertAudioRecordingCard(audio: alert.audioRecording!),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomClearance =
        68.h + MediaQuery.of(context).padding.bottom + 10.h;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E15) : const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
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
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Stay informed, stay prepared',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Tabs Row: Active | History
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF262938) : const Color(0xFFEAECF0),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Active Tab
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        provider.selectTab(0);
                        provider.fetchActiveAlert();
                      },
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
                                  : (isDark
                                      ? const Color(0xFF98A2B3)
                                      : const Color(0xFF667085)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // History Tab
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        provider.selectTab(1);
                        provider.fetchAlertHistory();
                      },
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
                                  : (isDark
                                      ? const Color(0xFF98A2B3)
                                      : const Color(0xFF667085)),
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
              child: RefreshIndicator(
                color: const Color(0xFF7F56D9),
                onRefresh: () async {
                  if (provider.selectedTab == 0) {
                    await provider.fetchActiveAlert();
                  } else {
                    await provider.fetchAlertHistory();
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      EdgeInsets.fromLTRB(16.w, 14.h, 16.w, bottomClearance),
                  child: provider.selectedTab == 0
                      ? _buildActiveTab(provider, isDark)
                      : const AlertHistoryView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
