import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/router/app_route_names.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const _sections = [
    _TermsSection(
      title: 'Welcome to iWitnez',
      body:
          'These Terms of Service explain the rules for using our app and services. By using iWitnez, you agree to these terms.',
    ),
    _TermsSection(
      number: '1',
      title: 'Acceptance of Terms',
      body:
          'By creating an account or using iWitnez, you agree to follow these Terms of Service and our policies.',
    ),
    _TermsSection(
      number: '2',
      title: 'Use of the App',
      body:
          'You agree to use iWitnez only for personal and lawful purposes. You will not misuse the app or try to access it in an unauthorized way.',
    ),
    _TermsSection(
      number: '3',
      title: 'User Responsibilities',
      body:
          'You are responsible for keeping your account information safe and for all activities that happen under your account.',
    ),
    _TermsSection(
      number: '4',
      title: 'Privacy',
      body:
          'Your privacy is important to us. Please review our Privacy Policy to understand how we collect and use your information.',
    ),
    _TermsSection(
      number: '5',
      title: 'Limitation of Liability',
      body:
          'iWitnez is provided "as is". We are not responsible for any direct or indirect damages that may result from using the app.',
    ),
    _TermsSection(
      number: '6',
      title: 'Changes to Terms',
      body:
          'We may update these Terms of Service from time to time. Any changes will be posted in the app with the updated effective date.',
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
          'Terms Of Service',
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
                  (s) {
                    final displayTitle = s.number != null
                        ? '${s.number}. ${s.title}'
                        : s.title;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayTitle,
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
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F5F9),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 2.h),
                Text(
                  'Thank you for choosing iWitnez. We\'re here to help you stay safe and connected.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.55,
                  ),
                ),
                SizedBox(height: 14.h),
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

class _TermsSection {
  const _TermsSection({
    required this.title,
    required this.body,
    this.number,
  });
  final String? number;
  final String title;
  final String body;
}

