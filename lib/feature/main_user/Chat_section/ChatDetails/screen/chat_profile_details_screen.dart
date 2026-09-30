import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';
import 'package:iwitnez/router/app_route_names.dart';

const Color _kAccentPurple = Color(0xFF6C4DF6);
const Color _kIconBgPurple = Color(0xFFF1EDFF);
const Color _kCardBorder = Color(0xFFF1F3F7);
const Color _kTextDark = Color(0xFF1E293B);
const Color _kTextSubtitle = Color(0xFF64748B);

class ChatProfileDetailsScreen extends StatelessWidget {
  const ChatProfileDetailsScreen({
    super.key,
    this.name = 'Sarah Khan',
    this.avatarUrl = 'https://i.pravatar.cc/150?img=5',
    this.isOnline = true,
    this.relationship = 'Sister',
    this.trustedCircle = 'Family',
  });

  factory ChatProfileDetailsScreen.fromExtra(dynamic extra) {
    if (extra is Map<String, dynamic>) {
      return ChatProfileDetailsScreen(
        name:
            extra['name'] as String? ??
            extra['contactName'] as String? ??
            'Sarah Khan',
        avatarUrl:
            extra['avatarUrl'] as String? ?? 'https://i.pravatar.cc/150?img=5',
        isOnline: extra['isOnline'] as bool? ?? true,
        relationship: extra['relationship'] as String? ?? 'Sister',
        trustedCircle: extra['trustedCircle'] as String? ?? 'Family',
      );
    }
    return const ChatProfileDetailsScreen();
  }

  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String relationship;
  final String trustedCircle;

  void _showMoreOptions(BuildContext context) {
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
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: _kTextDark),
                  title: const Text(
                    'Share Contact',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contact info copied for $name'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.notifications_off_outlined,
                    color: _kTextDark,
                  ),
                  title: const Text(
                    'Mute Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notifications muted for $name'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block_outlined, color: Colors.red),
                  title: const Text(
                    'Block Contact',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Blocked $name'),
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

  void _shareLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 10.w),
            Expanded(child: Text('Live location shared with $name')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFBFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kTextDark,
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: _kTextDark,
              size: 24.sp,
            ),
            onPressed: () => _showMoreOptions(context),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),

            // Profile Avatar with concentric soft glowing ring
            Center(
              child: Container(
                width: 106.r,
                height: 106.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: _kAccentPurple.withValues(alpha: 0.12),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kAccentPurple.withValues(alpha: 0.08),
                      blurRadius: 18,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(3.w),
                child: ClipOval(
                  child: avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: _kIconBgPurple,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 48.sp,
                                  color: _kAccentPurple,
                                ),
                              ),
                        )
                      : Container(
                          color: _kIconBgPurple,
                          child: Icon(
                            Icons.person_rounded,
                            size: 48.sp,
                            color: _kAccentPurple,
                          ),
                        ),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // Name
            Text(
              name,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: _kTextDark,
                letterSpacing: -0.2,
              ),
            ),

            SizedBox(height: 8.h),

            // Online Status Pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFFE8F8F0)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Card 1: Relationship & Trusted Circle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: _kCardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  // Relationship Row
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: _kIconBgPurple,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.people_alt_rounded,
                          color: _kAccentPurple,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Text(
                        'Relationship',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _kTextDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        relationship,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: _kTextSubtitle,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  // Trusted Circle Row
                  InkWell(
                    onTap: () {
                      context.push(AppRouteNames.trustedCircleScreen);
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: _kIconBgPurple,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.groups_rounded,
                            color: _kAccentPurple,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Text(
                          'Trusted Circle',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _kTextDark,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              trustedCircle,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: _kAccentPurple,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: _kAccentPurple,
                              size: 13.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Card 2: Action options (Audio call, Video call, Share location)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: _kCardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  // Start Audio Call
                  _buildActionTile(
                    icon: Icons.call_rounded,
                    title: 'Start Audio Call',
                    onTap: () {
                      CallFlowController.startAudioCall(
                        context,
                        name: name,
                        avatarUrl: avatarUrl,
                      );
                    },
                  ),
                  SizedBox(height: 18.h),

                  // Start Video Call
                  _buildActionTile(
                    icon: Icons.videocam_rounded,
                    title: 'Start Video Call',
                    onTap: () {
                      CallFlowController.startVideoCall(
                        context,
                        name: name,
                        avatarUrl: avatarUrl,
                      );
                    },
                  ),
                  SizedBox(height: 18.h),

                  // Share Location
                  _buildActionTile(
                    icon: Icons.location_on_rounded,
                    title: 'Share Location',
                    onTap: () => _shareLocation(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: _kIconBgPurple,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: _kAccentPurple, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _kTextDark,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: const Color(0xFF94A3B8),
            size: 14.sp,
          ),
        ],
      ),
    );
  }
}
