import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class TrustedLiveLocationCard extends StatefulWidget {
  const TrustedLiveLocationCard({
    super.key,
    required this.wardName,
    required this.wardStatus,
    required this.address,
    required this.wardAvatarUrl,
    this.onViewFullMapTap,
  });

  final String wardName;
  final String wardStatus;
  final String address;
  final String wardAvatarUrl;
  final VoidCallback? onViewFullMapTap;

  @override
  State<TrustedLiveLocationCard> createState() =>
      _TrustedLiveLocationCardState();
}

class _TrustedLiveLocationCardState extends State<TrustedLiveLocationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 172.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(width: 1.w, color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          children: [
            // Left Panel — Live Location details & View Full Map button
            Container(
              width: 140.w,
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 10.w, 12.h),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Pin icon + Live Location
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF8B2CF5),
                            size: 17.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              "${widget.wardName}'s\nLive Location",
                              style: GoogleFonts.inter(
                                color: const Color(0xFF111827),
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),

                      // Status: "Online • moving"
                      Row(
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            widget.wardStatus,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF16A34A),
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Address
                      Text(
                        widget.address,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF111827),
                          fontSize: 8.6.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),

                  // "View Full Map" Pill Button
                  InkWell(
                    onTap: widget.onViewFullMapTap,
                    borderRadius: BorderRadius.circular(100.r),
                    child: Container(
                      width: double.infinity,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B2CF5),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Center(
                        child: Text(
                          'View Full Map',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Panel — Interactive Dummy Map with radar pulse & avatar pin
            Expanded(
              child: InkWell(
                onTap: widget.onViewFullMapTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  child: Stack(
                    children: [
                      // Live Tracking Map Image
                      Positioned.fill(
                        child: Image.asset(
                          ImageAssets.liveTrackingMap,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Radar Rings & Pulsing Center Point
                      Positioned(
                        left: 28.w,
                        bottom: 12.h,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final wave = _pulseAnimation.value;
                            return Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Outer large radar concentric circle
                                Container(
                                  width: 90.r,
                                  height: 90.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF8B5CF6)
                                          .withValues(alpha: 0.12),
                                      width: 1.2.w,
                                    ),
                                    color: const Color(0xFF8B5CF6)
                                        .withValues(alpha: 0.04),
                                  ),
                                ),

                                // Mid radar concentric circle
                                Container(
                                  width: 62.r,
                                  height: 62.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF3B82F6)
                                          .withValues(alpha: 0.18),
                                      width: 1.2.w,
                                    ),
                                    color: const Color(0xFF3B82F6)
                                        .withValues(alpha: 0.06),
                                  ),
                                ),

                                // Dynamic pulse wave
                                Container(
                                  width: (34 + wave * 22).r,
                                  height: (34 + wave * 22).r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withValues(
                                      alpha: (1.0 - wave) * 0.28,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                // Inner fixed halo
                                Container(
                                  width: 32.r,
                                  height: 32.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF93C5FD)
                                        .withValues(alpha: 0.35),
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                // Blue location center dot with white rim
                                Container(
                                  width: 18.r,
                                  height: 18.r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.2.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF3B82F6)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 5,
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

                      // Emma's Avatar Pin on the map
                      Positioned(
                        right: 32.w,
                        top: 14.h,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 30.r,
                              height: 30.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  widget.wardAvatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: const Color(0xFFFDA4AF),
                                    child: Center(
                                      child: Text(
                                        widget.wardName.isNotEmpty
                                            ? widget.wardName[0]
                                            : 'E',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
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
                                width: 8.r,
                                height: 8.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5.w,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
