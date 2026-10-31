import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInCompleteBannerCard extends StatelessWidget {
  const CheckInCompleteBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Soft wave decoration at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 70.h,
            child: CustomPaint(
              painter: _GreenWavePainter(),
            ),
          ),

          // Card Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              children: [
                // Glowing calendar icon badge with sparkles
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 76.r,
                        height: 76.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7).withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Inner glow ring
                      Container(
                        width: 58.r,
                        height: 58.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBF7D0).withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Center Calendar + Checkmark container
                      Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFF22C55E),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 22.r,
                            height: 22.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Sparkle dots around the badge
                      Positioned(
                        top: 2.h,
                        left: -6.w,
                        child: Text(
                          '+',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4ADE80),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -2.h,
                        right: -4.w,
                        child: Text(
                          '+',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF86EFAC),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8.h,
                        right: -10.w,
                        child: Container(
                          width: 4.r,
                          height: 4.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // Title: Check-In Complete
                Text(
                  'Check-In Complete',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16A34A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  "You've successfully checked in today.\nStay safe and keep sharing your location with your trusted circles.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 6.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFDCFCE7).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.45);
    path1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.15,
      size.width * 0.65,
      size.height * 0.60,
    );
    path1.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.90,
      size.width,
      size.height * 0.50,
    );
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFFF0FDF4).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.65);
    path2.quadraticBezierTo(
      size.width * 0.40,
      size.height * 0.45,
      size.width * 0.75,
      size.height * 0.75,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

