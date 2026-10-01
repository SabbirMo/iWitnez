import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/feature/main_user/CheckIn/provider/check_in_provider.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/check_in_location_card.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/check_in_shared_with_card.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/check_in_time_card.dart';
import 'package:iwitnez/feature/main_user/CheckIn/widget/im_safe_banner_card.dart';

class CheckInScreen extends ConsumerWidget {
  const CheckInScreen({super.key});

  void _onCheckInNow(BuildContext context, WidgetRef ref) {
    ref.read(checkInProvider.notifier).checkIn();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Check-in shared with your trusted circles!"),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkInProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: const Color(0xFF111827),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Check-In',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Subtitle
              Center(
                child: Column(
                  children: [
                    Text(
                      'Let your trusted circles know',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "you're safe with your current location.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // 1. I'm Safe Banner Card
              const ImSafeBannerCard(),
              SizedBox(height: 14.h),

              // 2. Your Location Card with Map Image
              CheckInLocationCard(
                address: state.address,
                accuracy: state.accuracy,
                onUpdateTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location updated to current GPS location'),
                      duration: Duration(milliseconds: 1400),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              SizedBox(height: 14.h),

              // 3. Shared with Card
              const CheckInSharedWithCard(),
              SizedBox(height: 14.h),

              // 4. Check-in Time Card
              CheckInTimeCard(
                timeText: state.checkInTime,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Time set to current time'),
                      duration: Duration(milliseconds: 1200),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),

              // 5. "Check In Now" CustomButton
              CustomButton(
                text: 'Check In Now',
                icon: Icons.check_rounded,
                isLeadingIcon: true,
                height: 52.h,
                borderRadius: 26.r,
                onTap: () => _onCheckInNow(context, ref),
              ),
              SizedBox(height: 12.h),

              // 6. Security Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Your location is only shared with trusted circles.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
