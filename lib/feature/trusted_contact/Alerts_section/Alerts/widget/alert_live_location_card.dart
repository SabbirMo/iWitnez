import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/router/app_route_names.dart';

class AlertLiveLocationCard extends StatelessWidget {
  const AlertLiveLocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 146.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFEAECF0),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Info Details Column
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 6.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title Row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: const Color(0xFF8B2CF5),
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          "Emma's\nLive Location",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Status: Online • Sos Activated
                  Row(
                    children: [
                      Container(
                        width: 5.r,
                        height: 5.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFF12B76A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Online',
                        style: GoogleFonts.inter(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF12B76A),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Sos Activated',
                        style: GoogleFonts.inter(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD92D20),
                        ),
                      ),
                    ],
                  ),

                  // Address
                  Text(
                    '1200 Park Ave,\nNew York, NY 10028, USA',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF667085),
                      height: 1.25,
                    ),
                  ),

                  // "View Full Map" Red Button
                  InkWell(
                    onTap: () {
                      context.push(AppRouteNames.trustedLiveLocationScreen);
                    },
                    borderRadius: BorderRadius.circular(100.r),
                    child: Container(
                      width: double.infinity,
                      height: 28.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4D4F), Color(0xFFF04438)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(100.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFF04438).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'View Full Map',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Map Radar Preview
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(16.r),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Base Map Graphic
                  Image.asset(
                    ImageAssets.liveTrackingMap,
                    fit: BoxFit.cover,
                  ),

                  // Radar Pulse Rings in center
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Radar Ring
                        Container(
                          width: 82.r,
                          height: 82.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF04438)
                                .withValues(alpha: 0.12),
                          ),
                        ),
                        // Mid Radar Ring
                        Container(
                          width: 56.r,
                          height: 56.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF04438)
                                .withValues(alpha: 0.22),
                          ),
                        ),
                        // Inner Halo
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF04438)
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        // Center Red Dot
                        Container(
                          width: 14.r,
                          height: 14.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF04438),
                            border: Border.all(
                              color: Colors.white,
                              width: 2.5.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF04438)
                                    .withValues(alpha: 0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Emma Avatar Marker Pin (top right corner of map)
                  Positioned(
                    top: 10.h,
                    right: 32.w,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              ImageAssets.emmaAvatar,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Alert Exclamation Badge
                        Positioned(
                          right: -3.w,
                          bottom: -2.h,
                          child: Container(
                            width: 14.r,
                            height: 14.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFD92D20),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5.w,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '!',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w900,
                                ),
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
        ],
      ),
    );
  }
}
