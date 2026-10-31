import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/provider/trusted_circle_provider.dart';

class CheckInSharedWithCard extends ConsumerWidget {
  const CheckInSharedWithCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circles = ref.watch(trustedCircleProvider);
    final totalMembers =
        circles.fold<int>(0, (sum, c) => sum + c.memberCount);

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
                  totalMembers > 0
                      ? 'Shared with $totalMembers trusted contact${totalMembers > 1 ? 's' : ''}.'
                      : 'Your trusted circles will get this check-in.',
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

          // Circle icon badges
          SizedBox(
            width: 80.w,
            height: 32.h,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                _buildBadge(
                  left: 0,
                  bgColor: const Color(0xFFF3E8FF),
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFFA855F7),
                ),
                _buildBadge(
                  left: 18.w,
                  bgColor: const Color(0xFFDBEAFE),
                  icon: Icons.people_alt_rounded,
                  iconColor: const Color(0xFF3B82F6),
                ),
                _buildBadge(
                  left: 36.w,
                  bgColor: const Color(0xFFFFE4E6),
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFF43F5E),
                ),
                if (totalMembers > 3)
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
                          '+${totalMembers - 3}',
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

  Widget _buildBadge({
    required double left,
    required Color bgColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Positioned(
      left: left,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: bgColor,
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
        child: Center(
          child: Icon(
            icon,
            size: 14.sp,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
