import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/check_in_page_model.dart';

class CheckInSharedWithCard extends StatelessWidget {
  final CheckInSharedWithData sharedWith;
  final bool isCompleted;

  const CheckInSharedWithCard({
    super.key,
    this.sharedWith = const CheckInSharedWithData(),
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final contacts = sharedWith.contacts;
    final totalCount = sharedWith.totalCount;
    final overflowCount = sharedWith.overflowCount;

    final String subtitleText;
    if (isCompleted) {
      subtitleText = sharedWith.subtitle.isNotEmpty
          ? sharedWith.subtitle
          : (sharedWith.circlesCount > 0
              ? 'Your location was shared with ${sharedWith.circlesCount} trusted circles.'
              : (totalCount > 0
                  ? 'Your location was shared with $totalCount trusted contacts.'
                  : 'Your location was shared with your trusted circles.'));
    } else {
      subtitleText = totalCount > 0
          ? 'Shared with $totalCount trusted contact${totalCount > 1 ? 's' : ''}.'
          : 'Your trusted circles will get this check-in.';
    }

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
          Container(
            width: 36.r,
            height: 36.r,
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.people_alt_rounded,
                color: const Color(0xFF7C3AED),
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 14.w),
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
                  subtitleText,
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

          // Avatars row with +overflowCount badge
          SizedBox(
            width: 86.w,
            height: 32.h,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                if (contacts.isNotEmpty)
                  for (int i = 0; i < contacts.length && i < 3; i++)
                    _buildAvatarItem(
                      left: (i * 18.0).w,
                      contact: contacts[i],
                      index: i,
                    )
                else ...[
                  _buildFallbackBadge(
                    left: 0,
                    color: const Color(0xFFF3E8FF),
                    icon: Icons.groups_rounded,
                    iconColor: const Color(0xFFA855F7),
                  ),
                  _buildFallbackBadge(
                    left: 18.w,
                    color: const Color(0xFFDBEAFE),
                    icon: Icons.people_alt_rounded,
                    iconColor: const Color(0xFF3B82F6),
                  ),
                ],
                if (overflowCount > 0)
                  Positioned(
                    left: (contacts.length >= 3 ? 54.0 : contacts.length * 18.0).w,
                    child: Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
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
                        child: Text(
                          '+$overflowCount',
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

  Widget _buildAvatarItem({
    required double left,
    required CheckInContactItem contact,
    required int index,
  }) {
    final colors = [
      const Color(0xFFFED7AA),
      const Color(0xFFBAE6FD),
      const Color(0xFFDDD6FE),
    ];
    final fallbackColor = colors[index % colors.length];

    final hasAvatar =
        contact.avatarUrl != null && contact.avatarUrl!.isNotEmpty;

    return Positioned(
      left: left,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: fallbackColor,
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
          child: hasAvatar
              ? Image.network(
                  contact.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildInitial(contact),
                )
              : _buildInitial(contact),
        ),
      ),
    );
  }

  Widget _buildInitial(CheckInContactItem contact) {
    final initial =
        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '';
    if (initial.isEmpty) {
      return Icon(Icons.person_rounded, size: 16.sp, color: Colors.white);
    }
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFallbackBadge({
    required double left,
    required Color color,
    required IconData icon,
    required Color iconColor,
  }) {
    return Positioned(
      left: left,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: color,
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
          child: Icon(icon, size: 14.sp, color: iconColor),
        ),
      ),
    );
  }
}
