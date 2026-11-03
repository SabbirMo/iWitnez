import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Ultra-smooth, Dark & Light Mode adaptive Shimmer Effect
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = widget.baseColor ??
        (isDark ? const Color(0xFF1B1E2B) : const Color(0xFFE2E8F0));
    final highlight = widget.highlightColor ??
        (isDark ? const Color(0xFF2C3246) : const Color(0xFFF8FAFC));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(2.0, 0.3),
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              colors: [
                base,
                base,
                highlight,
                base,
                base,
              ],
              transform:
                  _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0.0,
      0.0,
    );
  }
}

/// Generic Shimmer Box with rounded corners
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1E2B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }
}

/// Generic Shimmer Circle (ideal for avatars & icons)
class ShimmerCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const ShimmerCircle({
    super.key,
    required this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1E2B) : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
    );
  }
}

// =============================================================================
// DOMAIN-SPECIFIC SHIMMER SKELETON WIDGETS
// =============================================================================

/// 1. Chat List Screen Shimmer (Conversation items)
class ChatListShimmer extends StatelessWidget {
  final int count;
  const ChatListShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (context, _) => Row(
          children: [
            ShimmerCircle(size: 48.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140.w, height: 14.h, borderRadius: 4),
                  SizedBox(height: 8.h),
                  ShimmerBox(width: 200.w, height: 11.h, borderRadius: 4),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ShimmerBox(width: 48.w, height: 10.h, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// 2. Chat Details Screen Shimmer (Message bubbles)
class ChatDetailsShimmer extends StatelessWidget {
  final int count;
  const ChatDetailsShimmer({super.key, this.count = 7});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: count,
        itemBuilder: (context, index) {
          final isMe = index % 2 == 1;
          final widths = [160.w, 220.w, 130.w, 200.w, 170.w, 240.w, 140.w];
          final bubbleWidth = widths[index % widths.length];

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) ...[
                    ShimmerCircle(size: 28.r),
                    SizedBox(width: 8.w),
                  ],
                  ShimmerBox(
                    width: bubbleWidth,
                    height: (index % 3 == 0) ? 60.h : 40.h,
                    borderRadius: 14,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 3. Calls Screen Shimmer (Call history logs)
class CallsListShimmer extends StatelessWidget {
  final int count;
  const CallsListShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (context, _) => Row(
          children: [
            ShimmerCircle(size: 46.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 130.w, height: 14.h, borderRadius: 4),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      ShimmerBox(width: 14.w, height: 14.h, borderRadius: 3),
                      SizedBox(width: 6.w),
                      ShimmerBox(width: 90.w, height: 11.h, borderRadius: 3),
                    ],
                  ),
                ],
              ),
            ),
            ShimmerCircle(size: 34.r),
          ],
        ),
      ),
    );
  }
}

/// 4. Notifications Screen Shimmer
class NotificationsShimmer extends StatelessWidget {
  final int count;
  const NotificationsShimmer({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, _) => Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181A26) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerCircle(size: 40.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 160.w, height: 13.h, borderRadius: 4),
                    SizedBox(height: 8.h),
                    ShimmerBox(width: double.infinity, height: 10.h, borderRadius: 4),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 90.w, height: 9.h, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 5. Emergency Alerts Shimmer
class AlertsListShimmer extends StatelessWidget {
  final int count;
  const AlertsListShimmer({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, _) => Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181A26) : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 90.w, height: 22.h, borderRadius: 6),
                  ShimmerBox(width: 60.w, height: 12.h, borderRadius: 4),
                ],
              ),
              SizedBox(height: 12.h),
              ShimmerBox(width: 200.w, height: 15.h, borderRadius: 4),
              SizedBox(height: 8.h),
              ShimmerBox(width: double.infinity, height: 12.h, borderRadius: 4),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: ShimmerBox(height: 38.h, borderRadius: 10),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ShimmerBox(height: 38.h, borderRadius: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 6. Contacts List Shimmer
class ContactsListShimmer extends StatelessWidget {
  final int count;
  const ContactsListShimmer({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, _) => Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181A26) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
            ),
          ),
          child: Row(
            children: [
              ShimmerCircle(size: 44.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 130.w, height: 13.h, borderRadius: 4),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 90.w, height: 10.h, borderRadius: 4),
                  ],
                ),
              ),
              ShimmerBox(width: 65.w, height: 24.h, borderRadius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// 7. Check-In Dashboard Screen Shimmer
class CheckInDashboardShimmer extends StatelessWidget {
  const CheckInDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            // Location card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShimmerCircle(size: 36.r),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: 100.w, height: 12.h, borderRadius: 4),
                          SizedBox(height: 6.h),
                          ShimmerBox(width: 180.w, height: 10.h, borderRadius: 4),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  ShimmerBox(width: double.infinity, height: 120.h, borderRadius: 12),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Timer status card
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                children: [
                  ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4),
                  SizedBox(height: 12.h),
                  ShimmerCircle(size: 110.r),
                  SizedBox(height: 16.h),
                  ShimmerBox(width: double.infinity, height: 44.h, borderRadius: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 8. Trusted Contact Monitored Dashboard Shimmer
class TrustedDashboardShimmer extends StatelessWidget {
  const TrustedDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            // User header
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                children: [
                  ShimmerCircle(size: 54.r),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 140.w, height: 16.h, borderRadius: 4),
                        SizedBox(height: 8.h),
                        ShimmerBox(width: 90.w, height: 11.h, borderRadius: 4),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 70.w, height: 26.h, borderRadius: 8),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Map container
            ShimmerBox(width: double.infinity, height: 200.h, borderRadius: 18),
            SizedBox(height: 16.h),
            // Bottom status cards
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(height: 90.h, borderRadius: 16),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ShimmerBox(height: 90.h, borderRadius: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 9. Main User Home Dashboard Screen Shimmer
class HomeDashboardShimmer extends StatelessWidget {
  const HomeDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(17.w, 10.h, 17.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Shimmer
            Row(
              children: [
                ShimmerCircle(size: 46.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 140.w, height: 16.h, borderRadius: 4),
                      SizedBox(height: 6.h),
                      ShimmerBox(width: 100.w, height: 11.h, borderRadius: 4),
                    ],
                  ),
                ),
                ShimmerCircle(size: 42.r),
              ],
            ),
            SizedBox(height: 18.h),

            // 2. Protected Banner Shimmer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                children: [
                  ShimmerCircle(size: 32.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 120.w, height: 13.h, borderRadius: 4),
                        SizedBox(height: 5.h),
                        ShimmerBox(width: 180.w, height: 10.h, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 3. Live Location Card Shimmer
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ShimmerCircle(size: 28.r),
                          SizedBox(width: 8.w),
                          ShimmerBox(width: 110.w, height: 14.h, borderRadius: 4),
                        ],
                      ),
                      ShimmerBox(width: 44.w, height: 24.h, borderRadius: 12),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ShimmerBox(width: 220.w, height: 11.h, borderRadius: 4),
                  SizedBox(height: 14.h),
                  ShimmerBox(width: double.infinity, height: 130.h, borderRadius: 14),
                ],
              ),
            ),
            SizedBox(height: 22.h),

            // 4. Quick Actions Header & Row
            ShimmerBox(width: 110.w, height: 16.h, borderRadius: 4),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(height: 95.h, borderRadius: 18),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ShimmerBox(height: 95.h, borderRadius: 18),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ShimmerBox(height: 95.h, borderRadius: 18),
                ),
              ],
            ),
            SizedBox(height: 26.h),

            // 5. Trusted Circles Header & Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 130.w, height: 16.h, borderRadius: 4),
                ShimmerBox(width: 50.w, height: 12.h, borderRadius: 4),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                ShimmerBox(width: 120.w, height: 120.h, borderRadius: 18),
                SizedBox(width: 14.w),
                ShimmerBox(width: 120.w, height: 120.h, borderRadius: 18),
                SizedBox(width: 14.w),
                Expanded(
                  child: ShimmerBox(height: 120.h, borderRadius: 18),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // 6. SOS Button Shimmer
            Center(
              child: ShimmerCircle(size: 96.r),
            ),
          ],
        ),
      ),
    );
  }
}

/// 10. Profile Screen Shimmer (Header card, stats, menu items)
class ProfileScreenShimmer extends StatelessWidget {
  const ProfileScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            ShimmerBox(width: 90.w, height: 24.h, borderRadius: 6),
            SizedBox(height: 20.h),

            // Profile Header Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                children: [
                  ShimmerCircle(size: 64.r),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 140.w, height: 16.h, borderRadius: 4),
                        SizedBox(height: 8.h),
                        ShimmerBox(width: 110.w, height: 12.h, borderRadius: 4),
                        SizedBox(height: 8.h),
                        ShimmerBox(width: 80.w, height: 20.h, borderRadius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Menu Section Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      children: [
                        ShimmerCircle(size: 38.r),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4),
                        ),
                        ShimmerBox(width: 18.w, height: 18.h, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Secondary Card (Preferences / Logout)
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      children: [
                        ShimmerCircle(size: 38.r),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: ShimmerBox(width: 100.w, height: 14.h, borderRadius: 4),
                        ),
                        ShimmerBox(width: 18.w, height: 18.h, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 11. Personal Information Screen Shimmer (Avatar, input fields)
class PersonalInfoShimmer extends StatelessWidget {
  const PersonalInfoShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ShimmerCircle(size: 96.r),
                  ShimmerCircle(size: 32.r),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 80.w, height: 12.h, borderRadius: 4),
                    SizedBox(height: 8.h),
                    ShimmerBox(width: double.infinity, height: 50.h, borderRadius: 14),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ShimmerBox(width: double.infinity, height: 50.h, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}

/// 12. Help & Support Screen Shimmer (Search box, categories, FAQ items)
class HelpSupportShimmer extends StatelessWidget {
  const HelpSupportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search box
            ShimmerBox(width: double.infinity, height: 48.h, borderRadius: 16),
            SizedBox(height: 16.h),

            // Horizontal Category Pills
            Row(
              children: [
                ShimmerBox(width: 80.w, height: 36.h, borderRadius: 20),
                SizedBox(width: 10.w),
                ShimmerBox(width: 90.w, height: 36.h, borderRadius: 20),
                SizedBox(width: 10.w),
                ShimmerBox(width: 75.w, height: 36.h, borderRadius: 20),
                SizedBox(width: 10.w),
                Expanded(child: ShimmerBox(height: 36.h, borderRadius: 20)),
              ],
            ),
            SizedBox(height: 24.h),

            // FAQ Items
            ...List.generate(
              5,
              (index) => Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181A26) : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                            width: (index % 2 == 0) ? 200.w : 160.w,
                            height: 14.h,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 6.h),
                          ShimmerBox(
                            width: double.infinity,
                            height: 10.h,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ShimmerCircle(size: 24.r),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 13. Manage Sharing Screen Shimmer
class ManageSharingShimmer extends StatelessWidget {
  const ManageSharingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, _) => Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181A26) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
            ),
          ),
          child: Row(
            children: [
              ShimmerCircle(size: 46.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 130.w, height: 14.h, borderRadius: 4),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 90.w, height: 11.h, borderRadius: 4),
                  ],
                ),
              ),
              ShimmerBox(width: 44.w, height: 24.h, borderRadius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// 14. Trusted Check-In Status Screen Shimmer
class CheckInStatusShimmer extends StatelessWidget {
  const CheckInStatusShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            // Status Circle
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ShimmerCircle(size: 160.r),
                  Container(
                    width: 120.r,
                    height: 120.r,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D0E15) : const Color(0xFFFAFAFC),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Center(child: ShimmerBox(width: 140.w, height: 18.h, borderRadius: 6)),
            SizedBox(height: 8.h),
            Center(child: ShimmerBox(width: 200.w, height: 12.h, borderRadius: 4)),
            SizedBox(height: 28.h),

            // Info Card 1: User details
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                children: [
                  ShimmerCircle(size: 48.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 130.w, height: 14.h, borderRadius: 4),
                        SizedBox(height: 6.h),
                        ShimmerBox(width: 90.w, height: 11.h, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Info Card 2: Location
            ShimmerBox(width: double.infinity, height: 90.h, borderRadius: 18),
            SizedBox(height: 24.h),

            // Action button
            ShimmerBox(width: double.infinity, height: 50.h, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}

/// 15. Trusted Journey ETA Screen Shimmer
class JourneyEtaShimmer extends StatelessWidget {
  const JourneyEtaShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            // ETA Hero Card
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                children: [
                  ShimmerBox(width: 100.w, height: 12.h, borderRadius: 4),
                  SizedBox(height: 10.h),
                  ShimmerBox(width: 150.w, height: 32.h, borderRadius: 8),
                  SizedBox(height: 14.h),
                  ShimmerBox(width: double.infinity, height: 8.h, borderRadius: 4),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Route timeline card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ShimmerCircle(size: 16.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ShimmerBox(width: 180.w, height: 13.h, borderRadius: 4),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 7.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ShimmerBox(width: 2.w, height: 28.h, borderRadius: 1),
                    ),
                  ),
                  Row(
                    children: [
                      ShimmerCircle(size: 16.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ShimmerBox(width: 180.w, height: 13.h, borderRadius: 4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Map Card
            ShimmerBox(width: double.infinity, height: 220.h, borderRadius: 20),
          ],
        ),
      ),
    );
  }
}

/// 16. Live Location Map Screen Shimmer
class LiveLocationMapShimmer extends StatelessWidget {
  const LiveLocationMapShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: Stack(
        children: [
          // Full screen map placeholder
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF12141F) : const Color(0xFFE9ECEF),
            ),
          ),
          // Top pill
          Positioned(
            top: 16.h,
            left: 20.w,
            right: 20.w,
            child: ShimmerBox(width: double.infinity, height: 46.h, borderRadius: 24),
          ),
          // Bottom card
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 24.h,
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ShimmerCircle(size: 48.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: 140.w, height: 15.h, borderRadius: 4),
                            SizedBox(height: 6.h),
                            ShimmerBox(width: 90.w, height: 11.h, borderRadius: 4),
                          ],
                        ),
                      ),
                      ShimmerBox(width: 50.w, height: 26.h, borderRadius: 8),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  ShimmerBox(width: double.infinity, height: 44.h, borderRadius: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 17. Safe Place Details Screen Shimmer
class SafePlaceDetailsShimmer extends StatelessWidget {
  const SafePlaceDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            Center(child: ShimmerBox(width: 180.w, height: 12.h, borderRadius: 4)),
            SizedBox(height: 16.h),
            ShimmerBox(width: double.infinity, height: 200.h, borderRadius: 20),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4),
                  SizedBox(height: 10.h),
                  ShimmerBox(width: double.infinity, height: 12.h, borderRadius: 4),
                  SizedBox(height: 16.h),
                  ShimmerBox(width: double.infinity, height: 40.h, borderRadius: 8),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            ShimmerBox(width: double.infinity, height: 50.h, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}

/// 18. Trusted Circles Screen Shimmer (Cards list)
class TrustedCirclesListShimmer extends StatelessWidget {
  final int count;
  const TrustedCirclesListShimmer({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Center(child: ShimmerBox(width: 260.w, height: 12.h, borderRadius: 4)),
          SizedBox(height: 6.h),
          Center(child: ShimmerBox(width: 180.w, height: 12.h, borderRadius: 4)),
          SizedBox(height: 20.h),
          ...List.generate(
            count,
            (index) => Container(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                children: [
                  ShimmerCircle(size: 46.r),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 120.w, height: 15.h, borderRadius: 4),
                        SizedBox(height: 6.h),
                        ShimmerBox(width: 80.w, height: 11.h, borderRadius: 4),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 24.w, height: 24.h, borderRadius: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

