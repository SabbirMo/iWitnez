import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/router/app_route_names.dart';

class TrustedCircleItem {
  final String title;
  final int memberCount;
  final List<String> avatars;
  final Color badgeBg;
  final IconData badgeIcon;
  final Color badgeIconColor;

  const TrustedCircleItem({
    required this.title,
    required this.memberCount,
    required this.avatars,
    required this.badgeBg,
    required this.badgeIcon,
    required this.badgeIconColor,
  });
}

class TrustedCircleScreen extends StatelessWidget {
  const TrustedCircleScreen({super.key});

  static final List<TrustedCircleItem> _circles = [
    const TrustedCircleItem(
      title: 'Family',
      memberCount: 3,
      avatars: [
        'https://i.pravatar.cc/150?img=5',
        'https://i.pravatar.cc/150?img=12',
        'https://i.pravatar.cc/150?img=32',
      ],
      badgeBg: Color(0xFFF3E8FF),
      badgeIcon: Icons.groups_rounded,
      badgeIconColor: Color(0xFFA855F7),
    ),
    const TrustedCircleItem(
      title: 'Friends',
      memberCount: 3,
      avatars: [
        'https://i.pravatar.cc/150?img=47',
        'https://i.pravatar.cc/150?img=60',
        'https://i.pravatar.cc/150?img=33',
      ],
      badgeBg: Color(0xFFDBEAFE),
      badgeIcon: Icons.people_alt_rounded,
      badgeIconColor: Color(0xFF3B82F6),
    ),
    const TrustedCircleItem(
      title: 'Partner',
      memberCount: 1,
      avatars: [
        'https://i.pravatar.cc/150?img=49',
      ],
      badgeBg: Color(0xFFFCE7F3),
      badgeIcon: Icons.favorite_rounded,
      badgeIconColor: Color(0xFFEC4899),
    ),
    const TrustedCircleItem(
      title: 'Work',
      memberCount: 2,
      avatars: [
        'https://i.pravatar.cc/150?img=11',
        'https://i.pravatar.cc/150?img=14',
      ],
      badgeBg: Color(0xFFDCFCE7),
      badgeIcon: Icons.business_center_rounded,
      badgeIconColor: Color(0xFF10B981),
    ),
  ];

  void _onCircleTap(BuildContext context, TrustedCircleItem circle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: circle.badgeBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        circle.badgeIcon,
                        color: circle.badgeIconColor,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circle.title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${circle.memberCount} Members in this circle',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EDFF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(Icons.person_add_rounded, color: Color(0xFF6C4DF6)),
                  ),
                  title: const Text('Add Member to Circle', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRouteNames.addTrustedFieldWidget);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EDFF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(Icons.share_location_rounded, color: Color(0xFF6C4DF6)),
                  ),
                  title: const Text('Share Location with Circle', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Live location shared with ${circle.title} circle'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF1E293B),
            size: 18.sp,
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
          'Trusted Circle',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push(AppRouteNames.addTrustedFieldWidget);
            },
            icon: Container(
              width: 30.r,
              height: 30.r,
              decoration: const BoxDecoration(
                color: Color(0xFF8B5CF6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Text(
              'These are your trusted contacts who can view your live location and get alerts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            ..._circles.map(
              (circle) => _buildCircleCard(context, circle),
            ),
            SizedBox(height: 8.h),
            _buildSafetyBanner(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleCard(BuildContext context, TrustedCircleItem circle) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF1F3F7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _onCircleTap(context, circle),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                _buildStackedAvatars(circle),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        circle.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${circle.memberCount} Members',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStackedAvatars(TrustedCircleItem circle) {
    const double avatarSize = 42.0;
    const double overlap = 18.0;
    final count = circle.avatars.length.clamp(1, 3);
    final totalWidth = avatarSize + (count - 1) * overlap + 10;

    return SizedBox(
      width: totalWidth.w,
      height: (avatarSize + 4).h,
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
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    circle.avatars[i],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1EDFF),
                      child: Icon(
                        Icons.person_rounded,
                        size: 22.sp,
                        color: const Color(0xFF6C4DF6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: ((count - 1) * overlap + 20).w,
            bottom: 0,
            child: Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                color: circle.badgeBg,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Icon(
                circle.badgeIcon,
                color: circle.badgeIconColor,
                size: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: const BoxDecoration(
              color: Color(0xFF5A32FA),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Connected, Stay Safe',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your trusted circle will be notified in case of SOS or safety alerts.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
