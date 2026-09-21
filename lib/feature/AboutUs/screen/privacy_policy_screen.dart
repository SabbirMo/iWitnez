import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/router/app_route_names.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    _PolicySection(
      title: 'Your Privacy Matters',
      body:
          'At iWitnez, we respect your privacy and are committed to protecting your personal information. This policy explains what information we collect, how we use it, and your choices.',
    ),
    _PolicySection(
      title: 'Information We Collect',
      body:
          'We collect only the information needed to provide and improve our services. This may include your name, email address, phone number, and location data when the app is in use.',
    ),
    _PolicySection(
      title: 'How We Use Your Information',
      body:
          'We use your information to provide safety features, send important alerts, improve app performance, and respond to your requests. We do not use your information for any other purpose.',
    ),
    _PolicySection(
      title: 'Data Protection',
      body:
          'We use industry-standard security measures to keep your data safe. Your information is stored securely and accessed only when necessary.',
    ),
    _PolicySection(
      title: 'Your Choices',
      body:
          'You have full control over your information. You can review, update, or delete your data at any time through the app settings.',
    ),
    _PolicySection(
      title: 'Third-Party Services',
      body:
          'We do not sell or share your personal information with third parties for marketing purposes. We may share data only when required by law or to protect safety.',
    ),
    _PolicySection(
      title: 'Policy Updates',
      body:
          'We may update this policy from time to time. Any changes will be posted in the app with the updated effective date.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FB),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouteNames.aboutUsScreen);
            }
          },
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._sections.map(
                  (s) => Padding(
                    padding: EdgeInsets.only(bottom: 18.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: GoogleFonts.inter(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          s.body,
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Last updated: May 27, 2026',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicySection {
  const _PolicySection({
    required this.title,
    required this.body,
  });
  final String title;
  final String body;
}

