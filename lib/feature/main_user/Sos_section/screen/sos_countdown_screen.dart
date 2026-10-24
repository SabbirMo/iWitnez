import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../provider/sos_countdown_provider.dart';
import '../widget/sos_countdown_widget.dart';
import 'sos_active_camera_screen.dart';

class SosCountdownScreen extends ConsumerStatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? address;

  const SosCountdownScreen({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
  });

  @override
  ConsumerState<SosCountdownScreen> createState() => _SosCountdownScreenState();
}

class _SosCountdownScreenState extends ConsumerState<SosCountdownScreen> {
  bool _isDispatched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(sosCountdownProvider.notifier).initiateSos(
          latitude: widget.latitude,
          longitude: widget.longitude,
          address: widget.address,
        );
      }
    });
  }

  void _dispatchSos() {
    if (_isDispatched) return;
    _isDispatched = true;
    ref.read(sosCountdownProvider.notifier).triggerImmediateSend();
    _navigateToCamera();
  }

  void _navigateToCamera() {
    if (!mounted) return;
    try {
      context.pushReplacement(AppRouteNames.sosActiveCameraScreen);
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SosActiveCameraScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sosCountdownProvider);
    final notifier = ref.read(sosCountdownProvider.notifier);

    // When 10-second countdown reaches 0 automatically, navigate directly to camera
    ref.listen(sosCountdownProvider, (previous, next) {
      if (next.isAlertSent && !(previous?.isAlertSent ?? false)) {
        if (!_isDispatched) {
          _isDispatched = true;
          _navigateToCamera();
        }
      }
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        // Only cancel if user actually pressed back without dispatching SOS
        if (didPop && !_isDispatched) {
          try {
            notifier.cancelAlert(reason: 'False alarm / Accidental tap');
          } catch (_) {}
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16.h),

                // ── Top 3D Glowing SOS Button with Ripple Halos ──
                SosGlowingButton(onTap: _dispatchSos),

                SizedBox(height: 16.h),

                // ── Header Text Section ──
                const SosHeaderSection(),

                SizedBox(height: 24.h),

                // ── Timer Card with Slide Action ──
                SosTimerCard(
                  formattedTime: state.formattedTime,
                  onSlideComplete: _dispatchSos,
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.h, top: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    notifier.cancelAlert(reason: 'False alarm / Accidental tap');
                    if (context.mounted) {
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SOS Alert Cancelled'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    child: Text(
                      'Cancel SOS',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
