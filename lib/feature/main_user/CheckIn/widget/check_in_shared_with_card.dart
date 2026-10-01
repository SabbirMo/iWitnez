import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInSharedWithCard extends StatelessWidget {
  const CheckInSharedWithCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          Center(
            child: Icon(
              Icons.people_alt_rounded,
              color: const Color(0xFF7C3AED),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared with',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Your trusted circles will get this check-in.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Overlapping avatars +2
          SizedBox(
            width: 90.w,
            height: 32.h,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                _buildAvatar(
                  left: 0,
                  imageUrl:
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
                  fallbackColor: const Color(0xFFFED7AA),
                  fallbackIcon: Icons.person_rounded,
                ),
                _buildAvatar(
                  left: 18.w,
                  imageUrl:
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                  fallbackColor: const Color(0xFFBAE6FD),
                  fallbackIcon: Icons.person_rounded,
                ),
                _buildAvatar(
                  left: 36.w,
                  imageUrl:
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
                  fallbackColor: const Color(0xFFDDD6FE),
                  fallbackIcon: Icons.person_rounded,
                ),
                Positioned(
                  left: 54.w,
                  child: Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                    child: Center(
                      child: Text(
                        '+2',
                        style: GoogleFonts.inter(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7C3AED),
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
    );
  }

  Widget _buildAvatar({
    required double left,
    required String imageUrl,
    required Color fallbackColor,
    required IconData fallbackIcon,
  }) {
    return Positioned(
      left: left,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: fallbackColor,
              child: Icon(fallbackIcon, size: 16.sp, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
