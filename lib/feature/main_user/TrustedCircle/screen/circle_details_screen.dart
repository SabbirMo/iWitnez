import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/provider/trusted_circle_provider.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/widget/circle_member_card.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/widget/remove_member_bottom_sheet.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/provider/add_trusted_contact_provider.dart';
import 'package:iwitnez/router/app_route_names.dart';

class CircleDetailsScreen extends ConsumerWidget {
  final TrustedCircleItem? circle;

  const CircleDetailsScreen({super.key, this.circle});

  void _confirmDeleteMember(
    BuildContext context,
    WidgetRef ref,
    String circleTitle,
    CircleMember member,
  ) {
    RemoveMemberBottomSheet.show(
      context: context,
      member: member,
      circleTitle: circleTitle,
      onConfirmRemove: () {
        ref
            .read(trustedCircleProvider.notifier)
            .removeMember(circleTitle, member.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.name} removed from $circleTitle'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circles = ref.watch(trustedCircleProvider);
    final targetTitle = circle?.title ?? 'Family';
    final activeCircle = circles.firstWhere(
      (c) => c.title.toLowerCase() == targetTitle.toLowerCase(),
      orElse: () => circle ?? circles.first,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: const Color(0xFF111827),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          activeCircle.title,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(addTrustedContactProvider.notifier).resetForm();
              context.push(
                AppRouteNames.addTrustedFieldWidget,
                extra: {'circleTitle': activeCircle.title},
              );
            },
            icon: Container(
              width: 32.r,
              height: 32.r,
              decoration: const BoxDecoration(
                color: Color(0xFF9333EA),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.add, color: Colors.white, size: 20.sp),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),

              // Overlapping Avatar Cluster with Badge
              _buildTopAvatarCluster(activeCircle),
              SizedBox(height: 16.h),

              // Title: "X Members"
              Text(
                '${activeCircle.members.length} Members',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 6.h),

              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'They can view your location and get alerts in case of emergency.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ),

              SizedBox(height: 28.h),

              // Member Cards List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeCircle.members.length,
                itemBuilder: (context, index) {
                  final member = activeCircle.members[index];
                  return CircleMemberCard(
                    member: member,
                    onEdit: () {
                      context.push(
                        AppRouteNames.addTrustedFieldWidget,
                        extra: {
                          'isEdit': true,
                          'member': member,
                          'circleTitle': activeCircle.title,
                        },
                      );
                    },
                    onDelete: () => _confirmDeleteMember(
                      context,
                      ref,
                      activeCircle.title,
                      member,
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAvatarCluster(TrustedCircleItem circle) {
    final displayMembers = circle.members.take(3).toList();
    const double avatarSize = 54.0;
    const double overlap = 28.0;
    final count = displayMembers.length;

    if (count == 0) {
      return Container(
        width: avatarSize.r,
        height: avatarSize.r,
        decoration: BoxDecoration(
          color: circle.badgeBg,
          shape: BoxShape.circle,
        ),
        child: Icon(
          circle.badgeIcon,
          color: circle.badgeIconColor,
          size: 28.sp,
        ),
      );
    }

    final totalWidth = avatarSize + (count - 1) * overlap + 14;

    return Center(
      child: SizedBox(
        width: totalWidth.w,
        height: (avatarSize + 8).h,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            for (int i = 0; i < count; i++)
              Positioned(
                left: (i * overlap).w,
                child: Container(
                  width: avatarSize.r,
                  height: avatarSize.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildClusterAvatar(displayMembers[i]),
                  ),
                ),
              ),

            // Little badge at the bottom right corner
            Positioned(
              right: 0,
              bottom: 4.h,
              child: Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  color: circle.badgeBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    circle.badgeIcon,
                    color: circle.badgeIconColor,
                    size: 12.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClusterAvatar(CircleMember member) {
    final avatarUrl = member.avatarUrl;
    if (avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('http')) {
        return Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _fallbackClusterLetter(member),
        );
      } else {
        final file = File(avatarUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _fallbackClusterLetter(member),
          );
        }
      }
    }
    return _fallbackClusterLetter(member);
  }

  Widget _fallbackClusterLetter(CircleMember member) {
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
