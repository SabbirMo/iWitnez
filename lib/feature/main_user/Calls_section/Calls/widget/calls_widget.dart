import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/model/calls_model.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/provider/calls_provider.dart';

const Color _kPurple = AppColors.callsPurple;
const Color _kTextDark = Color(0xFF1E293B);
const Color _kTextMuted = AppColors.callsGray;
const Color _kGreen = Color(0xFF10B981);
const Color _kRed = Color(0xFFEF4444);

class CallSearchField extends StatelessWidget {
  const CallSearchField({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: _kTextMuted, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(fontSize: 14.sp, color: _kTextDark),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search Call',
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: _kTextMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CallFilterTabs extends StatelessWidget {
  const CallFilterTabs({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final CallFilterTab currentTab;
  final ValueChanged<CallFilterTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildTab(CallFilterTab.all, 'All'),
          _buildTab(CallFilterTab.missed, 'Missed'),
          _buildTab(CallFilterTab.recent, 'Recent'),
        ],
      ),
    );
  }

  Widget _buildTab(CallFilterTab tab, String label) {
    final isSelected = currentTab == tab;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.callsPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.callsGray,
            ),
          ),
        ),
      ),
    );
  }
}

class CallsSectionHeader extends StatelessWidget {
  const CallsSectionHeader({super.key, required this.title, this.onSeeAllTap});

  final String title;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _kTextDark,
          ),
        ),
        GestureDetector(
          onTap: onSeeAllTap,
          child: Text(
            'See all',
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              color: _kPurple,
            ),
          ),
        ),
      ],
    );
  }
}

class CallLogTile extends StatelessWidget {
  const CallLogTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onVoiceCall,
    this.onVideoCall,
  });

  final CallLogEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onVoiceCall;
  final VoidCallback? onVideoCall;

  bool get _isMissed => entry.direction == CallDirection.missed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            // Contact Avatar
            CircleAvatar(
              radius: 22.r,
              backgroundColor: const Color(0xFFF1EDFF),
              backgroundImage: NetworkImage(entry.avatarUrl),
              onBackgroundImageError: (exception, stackTrace) {},
              child: entry.avatarUrl.isEmpty
                  ? Icon(Icons.person, color: _kPurple, size: 24.sp)
                  : null,
            ),
            SizedBox(width: 12.w),

            // Name + Direction/Type + Duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: _kTextDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        _isMissed
                            ? Icons.call_received_rounded
                            : Icons.call_made_rounded,
                        size: 13.sp,
                        color: _isMissed ? _kRed : _kGreen,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _isMissed
                            ? 'Missed ${entry.type == CallType.video ? 'video' : 'audio'} call'
                            : '${entry.type == CallType.video ? 'Video' : 'Audio'} call',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _kTextMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  if (entry.duration != null && !_isMissed) ...[
                    SizedBox(height: 1.5.h),
                    Text(
                      'Duration: ${entry.duration}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _kTextMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Date & Time Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.date,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  entry.time,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            SizedBox(width: 12.w),

            // Action Icons (Video + Audio)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onVideoCall,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.r),
                    child: Icon(
                      Icons.videocam_rounded,
                      color: _kPurple,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                InkWell(
                  onTap: onVoiceCall,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.r),
                    child: Icon(
                      Icons.call_rounded,
                      color: _kPurple,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessengerCallBottomSheet extends StatelessWidget {
  const MessengerCallBottomSheet({
    super.key,
    required this.entry,
    required this.onAudioCall,
    required this.onVideoCall,
    required this.onMessage,
    required this.onProfile,
  });

  final CallLogEntry entry;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;
  final VoidCallback onMessage;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final isMissed = entry.direction == CallDirection.missed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Profile Avatar with subtle purple ring
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.callsPurple.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 36.r,
                backgroundColor: const Color(0xFFF3F0FF),
                backgroundImage: NetworkImage(entry.avatarUrl),
                onBackgroundImageError: (exception, stackTrace) {},
                child: entry.avatarUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        color: AppColors.callsPurple,
                        size: 36.sp,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 10.h),

            // Contact Name
            Text(
              entry.name,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 3.h),

            // Subtitle
            Text(
              '${entry.date} • ${entry.time}',
              style: TextStyle(
                fontSize: 12.5.sp,
                color: AppColors.callsGray,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 22.h),

            // Messenger 4 circular action buttons: Audio | Video | Message | Profile
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.call_rounded,
                  label: 'Audio',
                  bgColor: const Color(0xFFF3F0FF),
                  iconColor: AppColors.callsPurple,
                  onTap: onAudioCall,
                ),
                _buildActionButton(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  bgColor: const Color(0xFFF3F0FF),
                  iconColor: AppColors.callsPurple,
                  onTap: onVideoCall,
                ),
                _buildActionButton(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Message',
                  bgColor: const Color(0xFFF1F5F9),
                  iconColor: const Color(0xFF334155),
                  onTap: onMessage,
                ),
                _buildActionButton(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  bgColor: const Color(0xFFF1F5F9),
                  iconColor: const Color(0xFF334155),
                  onTap: onProfile,
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Messenger style Call Activity Summary Card
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: isMissed
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      isMissed
                          ? Icons.call_received_rounded
                          : Icons.call_made_rounded,
                      color: isMissed
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMissed
                              ? 'Missed ${entry.type == CallType.video ? 'Video' : 'Audio'} Call'
                              : '${entry.type == CallType.video ? 'Video' : 'Audio'} Call',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          entry.duration != null && !isMissed
                              ? 'Duration: ${entry.duration}'
                              : '${entry.date} at ${entry.time}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.callsGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
