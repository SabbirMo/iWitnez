import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/provider/trusted_circle_provider.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/widget/circle_safety_banner.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/widget/trusted_circle_card.dart';
import 'package:iwitnez/router/app_route_names.dart';

class TrustedCircleScreen extends ConsumerWidget {
  const TrustedCircleScreen({super.key});

  void _onCircleTap(BuildContext context, TrustedCircleItem circle) {
    context.push(AppRouteNames.circleDetailsScreen, extra: circle);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circles = ref.watch(trustedCircleProvider);

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
            color: const Color(0xFF1E293B),
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
          style: GoogleFonts.inter(
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Text(
              'These are your trusted contacts who can view your live location and get alerts.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            ...circles.map(
              (circle) => TrustedCircleCard(
                circle: circle,
                onTap: () => _onCircleTap(context, circle),
              ),
            ),
            SizedBox(height: 8.h),
            const CircleSafetyBanner(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
