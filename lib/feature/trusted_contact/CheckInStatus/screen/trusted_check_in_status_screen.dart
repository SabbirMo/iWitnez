import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/check_in_status_provider.dart';
import '../widget/check_in_location_card.dart';
import '../widget/check_in_profile_card.dart';
import '../widget/check_in_success_card.dart';

class TrustedCheckInStatusScreen extends ConsumerWidget {
  const TrustedCheckInStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(checkInStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Check In Status',
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
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Profile Card
              CheckInProfileCard(data: data),
              SizedBox(height: 16.h),

              // 2. Note from Emma Section
              Text(
                'Note From ${data.wardName}',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF8F1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  data.note,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // 3. Location Card (Live)
              CheckInLocationCard(
                isLive: true,
                address: data.address,
                statusText: 'Live',
                updateTimeText: 'Updated just now',
              ),
              SizedBox(height: 16.h),

              // 4. Checked In Success Card
              CheckInSuccessCard(
                wardName: data.wardName,
                checkInTime: data.checkInTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
