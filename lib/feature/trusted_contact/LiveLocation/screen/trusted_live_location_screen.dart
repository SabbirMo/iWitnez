import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/router/app_route_names.dart';

class TrustedLiveLocationScreen extends StatefulWidget {
  const TrustedLiveLocationScreen({super.key});

  @override
  State<TrustedLiveLocationScreen> createState() =>
      _TrustedLiveLocationScreenState();
}

class _TrustedLiveLocationScreenState extends State<TrustedLiveLocationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.15).clamp(0.7, 1.8);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.15).clamp(0.7, 1.8);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: const Color(0xFF111827),
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Live Location',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Live Tracking Map Image Background
          Positioned.fill(
            child: ClipRect(
              child: Transform.scale(
                scale: _zoomLevel,
                child: Image.asset(
                  ImageAssets.liveTrackingMap,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. Concentric Radar Pulse Rings around user location marker
          Positioned(
            left: 110.w,
            top: 240.h,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final wave = _pulseAnimation.value;
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Outer largest concentric circle
                    Container(
                      width: 95.r,
                      height: 95.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.10),
                      ),
                    ),

                    // Mid concentric circle
                    Container(
                      width: 68.r,
                      height: 68.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.20),
                      ),
                    ),

                    // Dynamic pulsing ring
                    Container(
                      width: (40 + wave * 30).r,
                      height: (40 + wave * 30).r,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF8B5CF6,
                        ).withValues(alpha: (1.0 - wave) * 0.35),
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Inner static halo
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.38),
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Center location dot with white border
                    Container(
                      width: 20.r,
                      height: 20.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B2CF5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5.w),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF8B2CF5,
                            ).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 3. Map Floating Controls on Right
          Positioned(
            right: 16.w,
            top: 130.h,
            child: Column(
              children: [
                // Target / GPS Button
                _buildCircleMapButton(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Centered to Emma’s live location'),
                        duration: Duration(milliseconds: 1200),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.h),

                // Layers Button
                _buildCircleMapButton(
                  icon: Icons.layers_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Map layer: Standard'),
                        duration: Duration(milliseconds: 1200),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.h),

                // Zoom In / Zoom Out Pill
                Container(
                  width: 38.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(19.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _zoomIn,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(19.r),
                        ),
                        child: SizedBox(
                          height: 36.h,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 19.sp,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Color(0xFFE5E7EB),
                      ),
                      InkWell(
                        onTap: _zoomOut,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(19.r),
                        ),
                        child: SizedBox(
                          height: 36.h,
                          child: Center(
                            child: Icon(
                              Icons.remove,
                              size: 19.sp,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Top Floating Card (Emma Roy status & battery)
          Positioned(
            left: 16.w,
            right: 16.w,
            top: 10.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(width: 1.w, color: const Color(0xFFF2F4F7)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with green status dot
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: const Color(0xFFFDA4AF),
                                  child: Center(
                                    child: Text(
                                      'E',
                                      style: GoogleFonts.inter(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10.r,
                          height: 10.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.8.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),

                  // Name & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Emma Roy',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Text(
                              'Online',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                            Text(
                              ' • ',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              'Moving',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Updated 2 min ago',
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Battery Indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.battery_5_bar_rounded,
                        size: 20.sp,
                        color: const Color(0xFF344054),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '78%',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF344054),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 5. Bottom Overlay Cards: (Near East 75th St + Journey Timeline)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Card A: Near East 75th St + Get Directions
                    _buildCurrentLocationCard(context),
                    SizedBox(height: 12.h),

                    // Card B: Journey / Route Timeline (Home -> Work)
                    _buildRouteTimelineCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleMapButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.r),
      child: Container(
        width: 38.r,
        height: 38.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF4B5563), size: 19.sp),
      ),
    );
  }

  Widget _buildCurrentLocationCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 1.w, color: const Color(0xFFF2F4F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Purple location icon container
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.location_on,
              color: const Color(0xFF8B2CF5),
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // Address lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Near East 75th St',
                  style: GoogleFonts.inter(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Manhattan, New York...',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // "Get Directions" Pill Button
          InkWell(
            onTap: () {
              context.push(AppRouteNames.getDirectionsScreen);
            },
            borderRadius: BorderRadius.circular(100.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: const Color(0xFF8B2CF5),
                  width: 1.2.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.near_me_outlined,
                    size: 16.sp,
                    color: const Color(0xFF8B2CF5),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Get Directions',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8B2CF5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTimelineCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 1.w, color: const Color(0xFFF2F4F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stop 1: Home
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F3FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_rounded,
                  color: const Color(0xFF7F56D9),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Home',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Left at 08:15 AM',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  'Left',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF12B76A),
                  ),
                ),
              ),
            ],
          ),

          // Dotted Vertical Line connecting stops
          Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 22.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 2.5.r,
                      height: 2.5.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F56D9).withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stop 2: Work
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F3FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business_center_rounded,
                  color: const Color(0xFF7F56D9),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Work',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Expected arrival 09:05 AM',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F3FF),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  'ETA 24 min',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7F56D9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
