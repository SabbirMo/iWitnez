import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/router/app_route_names.dart';

class SosVideoStoppedScreen extends StatelessWidget {
  const SosVideoStoppedScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Your emergency recording is being\nuploaded securely.',
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
                          Icons.cloud_upload_outlined,
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
                            'Uploading & Sharing',
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Your recording, live location and alert will be shared with trusted contacts.',
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
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00C853),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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

              // ── 5. Contacts List Card ──
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
                child: Column(
                  children: [
                    _buildContactRow(
                      name: 'Rafiq Ahmed',
                      relation: 'Brother',
                      relationBg: const Color(0xFFECFDF5),
                      relationColor: const Color(0xFF059669),
                      avatarUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Divider(height: 1, color: const Color(0xFFF3F4F6)),
                    ),
                    _buildContactRow(
                      name: 'Sadia Islam',
                      relation: 'Sister',
                      relationBg: const Color(0xFFF3E8FF),
                      relationColor: const Color(0xFF7C3AED),
                      avatarUrl:
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Divider(height: 1, color: const Color(0xFFF3F4F6)),
                    ),
                    _buildContactRow(
                      name: 'Mahin Uddin',
                      relation: 'Friend',
                      relationBg: const Color(0xFFEFF6FF),
                      relationColor: const Color(0xFF2563EB),
                      avatarUrl:
                          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // ── 6. Stay Safe! Card ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FD),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 0.8,
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
                          Icons.verified_user_outlined,
                          color: const Color(0xFF2563EB),
                          size: 22.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay Safe!',
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Your recording, live location and alerts are successfully shared with your trusted contacts.',
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

  Widget _buildContactRow({
    required String name,
    required String relation,
    required Color relationBg,
    required Color relationColor,
    required String avatarUrl,
  }) {
    return Row(
      children: [
        // Avatar with green online dot
        Stack(
          children: [
            CircleAvatar(
              radius: 23.r,
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: NetworkImage(avatarUrl),
            ),
            Positioned(
              bottom: 1.h,
              right: 1.w,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 12.w),
        // Name and Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: relationBg,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      relation,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: relationColor,
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
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
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
/// Features:
/// 1. Dynamic pop-in entrance animation (bouncy elastic scale + delayed checkmark snap).
/// 2. Looping radar ripple waves expanding and fading outwards.
/// 3. Ambient breathing soft-green halo with floating satellite accent particles.
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

    // 1. One-shot dynamic entrance animation on landing
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

    // 2. Continuous ambient pulse & floating particles loop
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

                // ── Soft Glowing Outer Halo (Radial Gradient + gentle breathing) ──
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

                // ── Floating Decorative Satellite Dot 1 (Top-right) ──
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
                        boxShadow: [
                          BoxShadow(color: Color(0x3310B981), blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Floating Decorative Satellite Dot 2 (Bottom-left) ──
                Positioned(
                  bottom:
                      22.h +
                      (math.cos(_pulseController.value * 2 * math.pi) * 3),
                  left: 14.w + (breathe * 2),
                  child: ScaleTransition(
                    scale: _dotsScale,
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x3310B981), blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Floating Decorative Satellite Dot 3 (Right-center) ──
                Positioned(
                  top:
                      44.h +
                      (math.sin((_pulseController.value + 0.3) * 2 * math.pi) *
                          2.5),
                  right: 8.w,
                  child: ScaleTransition(
                    scale: _dotsScale,
                    child: Container(
                      width: 4.5.w,
                      height: 4.5.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.65),
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
                          color: const Color(0xFF00C853).withValues(
                            alpha: (0.35 + (breathe * 0.08)).clamp(0.2, 0.6),
                          ),
                          blurRadius: 18,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: _checkRotation.value,
                        child: ScaleTransition(
                          scale: _checkScale,
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 46.sp,
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
