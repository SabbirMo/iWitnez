import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/providers/live_location_tracking_provider.dart';

class BackgroundLocationTrackingScreen extends ConsumerWidget {
  const BackgroundLocationTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(liveLocationTrackingProvider);
    final notifier = ref.read(liveLocationTrackingProvider.notifier);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E15) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D0E15) : const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'Background Live Tracking',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Status Indicator Card
              _buildStatusCard(context, state, isDark),
              SizedBox(height: 16.h),

              // 2. Error Message Banner (if any)
              if (state.error != null) ...[
                _buildErrorBanner(state.error!, isDark),
                SizedBox(height: 16.h),
              ],

              // 3. GPS Warning Card (if GPS is disabled)
              if (state.isGpsDisabled) ...[
                _buildGpsDisabledCard(notifier, isDark),
                SizedBox(height: 16.h),
              ],

              // 4. Live Speed Display Card
              _buildSpeedCard(state, isDark),
              SizedBox(height: 16.h),

              // 5. Live Coordinates Grid
              _buildCoordinatesGrid(state, isDark),
              SizedBox(height: 16.h),

              // 6. Battery Optimization Exemption Card
              _buildBatteryCard(state, notifier, isDark),
              SizedBox(height: 24.h),

              // 7. Start / Stop Action Button
              _buildActionToggleButton(context, state, notifier),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    LocationTrackingState state,
    bool isDark,
  ) {
    final isActive = state.isTracking;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isActive
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF262938) : const Color(0xFFE2E8F0)),
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                  : (isDark ? const Color(0xFF232736) : const Color(0xFFF1F5F9)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.radar_rounded : Icons.location_off_rounded,
              color: isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              size: 26.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      isActive ? 'Tracking Active' : 'Tracking Idle',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  isActive
                      ? 'Foreground service running • Persistent notification active'
                      : 'Background service stopped. Tap below to begin tracking.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedCard(LocationTrackingState state, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: AppColors.liveLocationPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.speed_rounded,
                  color: AppColors.liveLocationPurple,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Speed',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Real-time GPS velocity',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: state.speedKmh.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                TextSpan(
                  text: ' km/h',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.liveLocationPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesGrid(LocationTrackingState state, bool isDark) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Telemetry',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              if (state.lastPingTime != null)
                Text(
                  'Synced ${_formatTime(state.lastPingTime!)}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryCell(
                  label: 'Latitude',
                  value: state.latitude != null
                      ? state.latitude!.toStringAsFixed(6)
                      : '--',
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTelemetryCell(
                  label: 'Longitude',
                  value: state.longitude != null
                      ? state.longitude!.toStringAsFixed(6)
                      : '--',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildTelemetryCell(
                  label: 'Accuracy',
                  value: state.accuracy != null
                      ? '±${state.accuracy!.toStringAsFixed(1)} m'
                      : '--',
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTelemetryCell(
                  label: 'Altitude',
                  value: state.altitude != null
                      ? '${state.altitude!.toStringAsFixed(1)} m'
                      : '--',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryCell({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131520) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryCard(
    LocationTrackingState state,
    LiveLocationTrackingNotifier notifier,
    bool isDark,
  ) {
    final isIgnored = state.isBatteryOptimizationIgnored;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: isIgnored
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIgnored
                  ? Icons.battery_charging_full_rounded
                  : Icons.battery_alert_rounded,
              color: isIgnored
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIgnored
                      ? 'Battery Optimization: Excluded'
                      : 'Battery Optimization: Restricted',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isIgnored
                      ? 'OS will not kill tracking in the background'
                      : 'Tap Exclude & choose "No restrictions"',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (!isIgnored)
            TextButton(
              onPressed: () => notifier.requestBatteryExemption(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                backgroundColor:
                    AppColors.liveLocationPurple.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Exclude',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.liveLocationPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGpsDisabledCard(
    LiveLocationTrackingNotifier notifier,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_disabled_rounded,
            color: const Color(0xFFEF4444),
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device GPS is Off',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Please turn on GPS to enable live safety tracking.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => notifier.openGpsSettings(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Turn On',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: const Color(0xFFF59E0B), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionToggleButton(
    BuildContext context,
    LocationTrackingState state,
    LiveLocationTrackingNotifier notifier,
  ) {
    final isTracking = state.isTracking;

    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: (isTracking
                    ? const Color(0xFFEF4444)
                    : AppColors.liveLocationPurple)
                .withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          if (isTracking) {
            await notifier.stopTracking();
          } else {
            await notifier.startTracking();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isTracking
              ? const Color(0xFFEF4444)
              : AppColors.liveLocationPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              isTracking
                  ? 'Stop Background Tracking'
                  : 'Start Background Tracking',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $amPm';
  }
}

