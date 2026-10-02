import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/trusted_contact/Alerts_section/Alerts/provider/alerts_provider.dart';

class AlertHistoryCard extends StatelessWidget {
  final AlertHistoryModel item;

  const AlertHistoryCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF2F4F7),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Left: Video Thumbnail Box with Play Button
          SizedBox(
            width: 86.w,
            height: 98.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    item.thumbnail,
                    fit: BoxFit.cover,
                  ),
                ),

                // Bottom Gradient
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 36.h,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12.r),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Bottom-Left Duration Badge (02:45)
                Positioned(
                  bottom: 6.h,
                  left: 6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      item.duration,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Bottom-Right Circular Red Play Button
                Positioned(
                  bottom: 6.h,
                  right: 6.w,
                  child: Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF04438),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF04438).withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // 2. Middle: Alert Details (Title, Date, Address, Media Badges)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // SOS Alert Title
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF04438),
                  ),
                ),
                SizedBox(height: 2.h),

                // Date / Time
                Text(
                  item.date,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF667085),
                  ),
                ),
                SizedBox(height: 4.h),

                // Location Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: const Color(0xFF7F56D9),
                        size: 13.sp,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        item.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF667085),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // Badges: Video & Audio
                Row(
                  children: [
                    if (item.hasVideo) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F3FF),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.videocam_rounded,
                              color: const Color(0xFF7F56D9),
                              size: 12.sp,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Video',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7F56D9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    if (item.hasAudio) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F3FF),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Audio',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF7F56D9),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),

          // 3. Right: Mini Map Snippet with Red Location Pin
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 58.w,
              height: 84.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    ImageAssets.liveTrackingMap,
                    fit: BoxFit.cover,
                  ),
                  Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: const Color(0xFFF04438),
                      size: 22.sp,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
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
