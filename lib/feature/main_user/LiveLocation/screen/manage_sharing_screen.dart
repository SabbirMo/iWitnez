import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/model/live_sharing_model.dart';
import 'package:iwitnez/feature/main_user/LiveLocation/provider/live_location_screen_provider.dart';

class ManageSharingScreen extends ConsumerWidget {
  const ManageSharingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveState = ref.watch(liveLocationScreenProvider);
    final notifier = ref.read(liveLocationScreenProvider.notifier);

    // Filter out "Emma (You)" so we only manage trusted contacts
    final trustedContacts = liveState.contacts
        .where((c) => !c.name.toLowerCase().contains('(you)'))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64.h,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: AppColors.textDark,
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
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Select who can see your live location',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.onboardingDesc,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF3F4F6), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Text(
                'Trusted Contacts',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onboardingDesc,
                ),
              ),
              SizedBox(height: 14.h),

              // Contacts List with Toggle Switches
              ...trustedContacts.expand(
                (person) => [
                  _buildContactTile(person, notifier),
                  const Divider(
                    color: Color(0xFFF3F4F6),
                    height: 1,
                    thickness: 1,
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Info Box (Lavender container with shield check icon)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3FF),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFF5F3FF), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.liveLocationPurple.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              color: AppColors.liveLocationPurple,
                              size: 22.sp,
                            ),
                            Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 13.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        'Your location is only shared with selected trusted contacts.',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
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
    );
  }

  Widget _buildContactTile(
    SharingPersonModel person,
    LiveLocationScreenNotifier notifier,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          // Contact Avatar
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.network(
                person.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: person.fallbackColor,
                    child: Center(
                      child: Text(
                        person.name[0],
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Contact Name
          Expanded(
            child: Text(
              person.name,
              style: GoogleFonts.inter(
                fontSize: 15.5.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),

          // Cupertino Toggle Switch
          CupertinoSwitch(
            activeTrackColor: AppColors.liveLocationPurple,
            value: person.isSharingWith,
            onChanged: (val) {
              notifier.toggleContactSharing(person.id);
            },
          ),
        ],
      ),
    );
  }
}
