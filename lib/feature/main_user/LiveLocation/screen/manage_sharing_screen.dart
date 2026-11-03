import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/widgets/shimmer_loading.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/model/manage_sharing_model.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/provider/manage_sharing_provider.dart';

const List<Color> _avatarColors = [
  Color(0xFFFDA4AF), // Pink
  Color(0xFF60A5FA), // Blue
  Color(0xFFFB923C), // Orange
  Color(0xFF34D399), // Mint
  Color(0xFFA78BFA), // Purple
];

class ManageSharingScreen extends ConsumerWidget {
  const ManageSharingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manageSharingProvider);
    final notifier = ref.read(manageSharingProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E15) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D0E15) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64.h,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Manage Sharing',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Select who can see your live location',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? const Color(0xFF98A2B3)
                    : AppColors.onboardingDesc,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? const Color(0xFF262938) : const Color(0xFFF3F4F6),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => notifier.fetchContacts(),
          color: const Color(0xFF8B2CF5),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Text(
                  'Trusted Contacts',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF98A2B3)
                        : AppColors.onboardingDesc,
                  ),
                ),
                SizedBox(height: 14.h),

                // Loading State
                if (state.isLoading)
                  const ManageSharingShimmer()
                // Empty Contacts
                else if (state.contacts.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Center(
                      child: Text(
                        'No trusted contacts found',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: isDark
                              ? const Color(0xFF98A2B3)
                              : AppColors.onboardingDesc,
                        ),
                      ),
                    ),
                  )
                // Contacts List
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.contacts.length,
                    separatorBuilder: (context, index) => Divider(
                      color: isDark
                          ? const Color(0xFF262938)
                          : const Color(0xFFF3F4F6),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final contact = state.contacts[index];
                      final color = _avatarColors[index % _avatarColors.length];
                      return _buildContactTile(
                        context,
                        contact,
                        color,
                        notifier,
                        isDark,
                      );
                    },
                  ),

                SizedBox(height: 28.h),

                // Security Note Box
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF181A26)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF262938)
                          : const Color(0xFFF3F4F6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: const BoxDecoration(
                          color: AppColors.liveLocationPurple,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          'Your location is only shared with selected trusted contacts.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF98A2B3)
                                : const Color(0xFF374151),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    ManageSharingContactModel contact,
    Color fallbackColor,
    ManageSharingNotifier notifier,
    bool isDark,
  ) {
    final subtitle = contact.relationship?.isNotEmpty == true
        ? contact.relationship!
        : (contact.email?.isNotEmpty == true
              ? contact.email!
              : (contact.phoneNumber ?? ''));

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          // Contact Avatar
          Container(
            width: 46.r,
            height: 46.r,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child:
                  contact.avatarUrl != null &&
                      contact.avatarUrl!.isNotEmpty &&
                      contact.avatarUrl!.startsWith('http')
                  ? Image.network(
                      contact.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildAvatarFallback(contact.name, fallbackColor),
                    )
                  : _buildAvatarFallback(contact.name, fallbackColor),
            ),
          ),
          SizedBox(width: 14.w),

          // Contact Name & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFF98A2B3)
                          : AppColors.onboardingDesc,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Cupertino Toggle Switch
          CupertinoSwitch(
            activeTrackColor: AppColors.liveLocationPurple,
            value: contact.isSharingEnabled,
            onChanged: (val) async {
              final success = await notifier.toggleContact(contact.id, val);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to update sharing for ${contact.name}',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String name, Color color) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
