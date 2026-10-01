import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';

class CircleMemberCard extends StatelessWidget {
  final CircleMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CircleMemberCard({
    super.key,
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Avatar
          Container(
            width: 50.r,
            height: 50.r,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: _buildAvatar(member),
            ),
          ),
          SizedBox(width: 14.w),

          // Name and Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.inter(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  member.phone,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Edit Button (Purple pencil)
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_rounded,
              color: const Color(0xFF7C3AED),
              size: 20.sp,
            ),
            visualDensity: VisualDensity.compact,
            splashRadius: 20.r,
          ),

          SizedBox(width: 4.w),

          // Delete Button (Soft circular red button)
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: onDelete,
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(ImageAssets.deleteIcon, width: 14.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(CircleMember member) {
    final avatarUrl = member.avatarUrl;
    if (avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('http')) {
        return Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackLetter(member),
        );
      } else {
        final file = File(avatarUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _fallbackLetter(member),
          );
        }
      }
    }
    return _fallbackLetter(member);
  }

  Widget _fallbackLetter(CircleMember member) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Center(
        child: Text(
          member.name.isNotEmpty ? member.name[0] : '?',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
