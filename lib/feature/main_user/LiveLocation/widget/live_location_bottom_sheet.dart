import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/model/live_sharing_model.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/provider/live_location_screen_provider.dart';
import 'package:iwitnez/router/app_route_names.dart';

class LiveLocationBottomSheet extends ConsumerStatefulWidget {
  final void Function(SharingPersonModel person)? onPersonTap;

  const LiveLocationBottomSheet({super.key, this.onPersonTap});

  @override
  ConsumerState<LiveLocationBottomSheet> createState() =>
      _LiveLocationBottomSheetState();
}

class _LiveLocationBottomSheetState
    extends ConsumerState<LiveLocationBottomSheet> {
  bool _isStartingSharing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveLocationScreenProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.46,
      minChildSize: 0.28,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  // Drag handle pill
                  Center(
                    child: Container(
                      width: 38.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Section Title: People Sharing Your Location
                  Text(
                    'People Sharing Your Location',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // People List
                  if (state.contacts.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: Text(
                          'No contacts currently sharing location',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.contacts.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: const Color(0xFFF1F5F9), height: 12.h),
                      itemBuilder: (context, index) {
                        final person = state.contacts[index];
                        final isSelf = person.id == 'self' || index == 0;
                        return _buildPersonTile(
                          context,
                          person,
                          isSelf: isSelf,
                          isSharingActive: state.isSharing,
                        );
                      },
                    ),

                  SizedBox(height: 20.h),

                  // Section Title: Location Sharing Settings
                  Text(
                    'Location Sharing Settings',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // "Share for" tile
                  InkWell(
                    onTap: () => _showShareDurationPicker(context, ref),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5EEFF),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.access_time_rounded,
                              color: const Color(0xFF8B2CF5),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share for',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  state.selectedDuration,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Stop / Start Sharing Location button
                  CustomButton(
                    text: state.isSharing
                        ? 'Stop Sharing Location'
                        : 'Start Sharing Location',
                    isLoading: _isStartingSharing,
                    icon: state.isSharing
                        ? Icons.navigation_rounded
                        : Icons.location_on_rounded,
                    isLeadingIcon: true,
                    height: 52.h,
                    borderRadius: 30.r,
                    gradientColors: state.isSharing
                        ? const [Color(0xFF6B21A8), Color(0xFF2563EB)]
                        : const [Color(0xFF10B981), Color(0xFF059669)],
                    textStyle: GoogleFonts.inter(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    onTap: () async {
                      if (state.isSharing) {
                        context.push(AppRouteNames.stopSharingLocationScreen);
                      } else {
                        if (_isStartingSharing) return;
                        setState(() => _isStartingSharing = true);
                        await ref
                            .read(liveLocationScreenProvider.notifier)
                            .startSharing();
                        if (mounted) {
                          setState(() => _isStartingSharing = false);
                        }
                      }
                    },
                  ),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonTile(
    BuildContext context,
    SharingPersonModel person, {
    required bool isSelf,
    required bool isSharingActive,
  }) {
    final showLiveBadge = isSelf ? isSharingActive : person.isLive;

    return InkWell(
      onTap: () => widget.onPersonTap?.call(person),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            // Avatar with green status dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        person.imageUrl.isNotEmpty &&
                            person.imageUrl.startsWith('http')
                        ? Image.network(
                            person.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildAvatarFallback(person),
                          )
                        : _buildAvatarFallback(person),
                  ),
                ),
                // Green online dot (grey if self is not sharing)
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 11.r,
                    height: 11.r,
                    decoration: BoxDecoration(
                      color: showLiveBadge
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF9CA3AF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),

            // Name and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          person.name,
                          style: GoogleFonts.inter(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Emma (You): purple badge Live or Off
                      if (showLiveBadge) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Live',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8B2CF5),
                            ),
                          ),
                        ),
                      ] else if (isSelf && !isSharingActive) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'Off',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // distance_display ("Now" for you, "Now • 200 ft away" for others)
                  Text(
                    isSelf
                        ? (isSharingActive ? 'Now' : 'Sharing is off')
                        : person.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelf && isSharingActive
                          ? const Color(0xFF8B2CF5)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF9CA3AF),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(SharingPersonModel person) {
    return Container(
      color: person.fallbackColor,
      child: Center(
        child: Text(
          person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showShareDurationPicker(BuildContext context, WidgetRef ref) {
    final currentType = ref.read(liveLocationScreenProvider).durationType;

    final options = [
      {'type': 'until_off', 'label': 'Until I turn it off'},
      {'type': '1_hour', 'label': 'For 1 hour'},
      {'type': '8_hours', 'label': 'For 8 hours'},
    ];

    showModalBottomSheet<void>(
      context: context,
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
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Share Duration',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 12.h),
                ...options.map((opt) {
                  final isSelected = opt['type'] == currentType;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      opt['label']!,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF8B2CF5)
                            : const Color(0xFF1F2937),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF8B2CF5),
                          )
                        : null,
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await ref
                          .read(liveLocationScreenProvider.notifier)
                          .updateDuration(opt['type']!);
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Location sharing set to: ${opt['label']}',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
