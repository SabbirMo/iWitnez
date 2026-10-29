import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../model/sos_recipient_model.dart';
import '../model/sos_upload_state.dart';
import '../provider/sos_upload_provider.dart';

class SosVideoStoppedScreen extends ConsumerStatefulWidget {
  final String? videoPath;
  final String? alertId;
  final int? durationSeconds;

  const SosVideoStoppedScreen({
    super.key,
    this.videoPath,
    this.alertId,
    this.durationSeconds,
  });

  @override
  ConsumerState<SosVideoStoppedScreen> createState() =>
      _SosVideoStoppedScreenState();
}

class _SosVideoStoppedScreenState extends ConsumerState<SosVideoStoppedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(sosUploadProvider.notifier).uploadRecording(
              alertId: widget.alertId,
              videoFilePath: widget.videoPath,
              durationSeconds: widget.durationSeconds,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(sosUploadProvider);
    final isUploading = uploadState.isUploading;
    final isUploadSuccess = uploadState.isUploadSuccess;
    final errorMessage = uploadState.errorMessage;
    final formattedDuration = uploadState.formattedDuration;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: const Color(0xFF1E232C),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),

              // ── 1. Animated Success Checkmark Badge ──
              const Center(child: AnimatedSuccessBadge()),

              SizedBox(height: 16.h),

              // ── 2. "Video Stopped" Title ──
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Video ',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E232C),
                        letterSpacing: -0.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Stopped',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00C853),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                isUploadSuccess
                    ? 'Your emergency recording has been\nuploaded and secured.'
                    : 'Your emergency recording is being\nuploaded securely.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),

              SizedBox(height: 24.h),

              // ── 3. Uploading & Sharing Card ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isUploadSuccess
                              ? Icons.cloud_done_rounded
                              : Icons.cloud_upload_outlined,
                          color: const Color(0xFF00C853),
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUploadSuccess
                                ? 'Evidence Uploaded & Secured'
                                : 'Uploading & Sharing Evidence',
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            isUploadSuccess
                                ? (formattedDuration != null
                                    ? 'Incident recording ($formattedDuration) stored safely. Contacts alerted.'
                                    : 'Your incident file is stored safely. Contacts have received evidence link.')
                                : 'Your recording, live location and alert will be shared with trusted contacts.',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF6B7280),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    if (isUploading)
                      SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00C853),
                          ),
                        ),
                      )
                    else if (isUploadSuccess)
                      Icon(
                        Icons.check_circle_rounded,
                        color: const Color(0xFF00C853),
                        size: 24.sp,
                      )
                    else if (errorMessage != null)
                      IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          ref.read(sosUploadProvider.notifier).uploadRecording(
                                alertId: widget.alertId,
                                videoFilePath: widget.videoPath,
                                durationSeconds: widget.durationSeconds,
                              );
                        },
                        tooltip: 'Retry Upload',
                      ),
                  ],
                ),
              ),

              if (errorMessage != null) ...[
                SizedBox(height: 10.h),
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              SizedBox(height: 24.h),

              // ── 4. Section: Sharing with Trusted Contacts ──
              Row(
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    size: 19.sp,
                    color: const Color(0xFF00C853),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Sharing with Trusted Contacts',
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // ── 5. Contacts List Card (Dynamically rendered from Riverpod state) ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildContactsContent(uploadState),
              ),

              SizedBox(height: 20.h),

              // ── 6. Stay Safe! Card ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: const Color(0xFFDCFCE7),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.verified_user_rounded,
                          color: const Color(0xFF15803D),
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay Safe!',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Your trusted circle has been alerted. Live evidence and GPS details are accessible securely.',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF6B7280),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
      // ── 7. Bottom Go To Home Button ──
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go(AppRouteNames.mainUserHome);
              },
              icon: Icon(Icons.home_rounded, color: Colors.white, size: 20.sp),
              label: Text(
                'Go To Home',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF00C853).withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactsContent(SosUploadState uploadState) {
    if (uploadState.isUploading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF00C853),
                strokeWidth: 2.2,
              ),
              SizedBox(height: 12.h),
              Text(
                'Sharing evidence with trusted contacts...',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final recipients = uploadState.recipients;
    if (recipients.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Text(
            uploadState.isUploadSuccess
                ? 'Evidence securely stored. Contacts have been alerted.'
                : 'No contacts shared yet.',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < recipients.length; i++) ...[
          if (i > 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ),
          _buildContactRow(recipients[i]),
        ],
      ],
    );
  }

  Widget _buildContactRow(SosRecipientModel recipient) {
    return Row(
      children: [
        // Avatar with initial letter or default green ring
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: recipient.relationshipBgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              recipient.contactName.isNotEmpty
                  ? recipient.contactName[0].toUpperCase()
                  : 'C',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: recipient.relationshipTextColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Name, relationship badge & shared status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      recipient.contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: recipient.relationshipBgColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      recipient.relationship,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: recipient.relationshipTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    'Successfully shared',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF00C853),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 13.sp,
                    color: const Color(0xFF00C853),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Right green checkmark circle badge
        Container(
          width: 26.w,
          height: 26.h,
          decoration: const BoxDecoration(
            color: Color(0xFFECFDF5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: const Color(0xFF00C853),
              size: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}

/// ── Animated Success Badge ──
class AnimatedSuccessBadge extends StatefulWidget {
  const AnimatedSuccessBadge({super.key});

  @override
  State<AnimatedSuccessBadge> createState() => _AnimatedSuccessBadgeState();
}

class _AnimatedSuccessBadgeState extends State<AnimatedSuccessBadge>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _haloScale;
  late final Animation<double> _badgeScale;
  late final Animation<double> _checkScale;
  late final Animation<double> _checkRotation;
  late final Animation<double> _dotsScale;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _haloScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.75, curve: Curves.elasticOut),
      ),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.42, 0.92, curve: Curves.elasticOut),
      ),
    );

    _checkRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _dotsScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.w,
      height: 150.h,
      child: AnimatedBuilder(
        animation: Listenable.merge([_entranceController, _pulseController]),
        builder: (context, _) {
          final double t1 = _pulseController.value;
          final double t2 = (_pulseController.value + 0.5) % 1.0;
          final double breathe = math.sin(_pulseController.value * 2 * math.pi);

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ── Continuous Ripple Wave 1 (Radar pulse) ──
                Transform.scale(
                  scale: 0.95 + (t1 * 0.42),
                  child: Opacity(
                    opacity: ((1.0 - t1) * 0.38 * _fadeAnimation.value).clamp(
                      0.0,
                      1.0,
                    ),
                    child: Container(
                      width: 95.w,
                      height: 95.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Continuous Ripple Wave 2 (Phase offset radar pulse) ──
                Transform.scale(
                  scale: 0.95 + (t2 * 0.42),
                  child: Opacity(
                    opacity: ((1.0 - t2) * 0.38 * _fadeAnimation.value).clamp(
                      0.0,
                      1.0,
                    ),
                    child: Container(
                      width: 95.w,
                      height: 95.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Soft Glowing Outer Halo ──
                Transform.scale(
                  scale: _haloScale.value * (1.0 + (breathe * 0.04)),
                  child: Container(
                    width: 130.w,
                    height: 130.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF86EFAC).withValues(alpha: 0.50),
                          const Color(0xFFD1FAE5).withValues(alpha: 0.35),
                          const Color(0xFFD1FAE5).withValues(alpha: 0.0),
                        ],
                        stops: const [0.35, 0.70, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Floating Decorative Satellite Dot 1 ──
                Positioned(
                  top: 10.h + (breathe * 3),
                  right:
                      30.w +
                      (math.cos(_pulseController.value * 2 * math.pi) * 2),
                  child: ScaleTransition(
                    scale: _dotsScale,
                    child: Container(
                      width: 5.5.w,
                      height: 5.5.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // ── Floating Decorative Satellite Dot 2 ──
                Positioned(
                  bottom:
                      22.h +
                      (math.sin((_pulseController.value + 0.5) * 2 * math.pi) *
                          3),
                  left: 26.w,
                  child: ScaleTransition(
                    scale: _dotsScale,
                    child: Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // ── Central Solid Vibrant Green Badge ──
                Transform.scale(
                  scale: _badgeScale.value * (1.0 + (breathe * 0.02)),
                  child: Container(
                    width: 86.w,
                    height: 86.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF00E676), Color(0xFF00C853)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C853).withValues(alpha: 0.38),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ScaleTransition(
                        scale: _checkScale,
                        child: RotationTransition(
                          turns: _checkRotation,
                          child: Icon(
                            Icons.check_rounded,
                            size: 44.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
