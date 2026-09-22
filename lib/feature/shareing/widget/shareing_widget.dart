import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/onboarding/controller/start_animations.dart';
import 'package:iwitnez/feature/shareing/model/shareing_model.dart';

class ShareingWidget extends StatefulWidget {
  const ShareingWidget({super.key, required this.data});

  final ShareingModel data;

  @override
  State<ShareingWidget> createState() => _ShareingWidgetState();
}

class _ShareingWidgetState extends State<ShareingWidget>
    with TickerProviderStateMixin {
  late final StartAnimations _animations = StartAnimations(this);

  @override
  void reassemble() {
    super.reassemble();
    _animations.reassemble();
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Image on top (just like the screenshot)
        SizedBox(
          height: 300.h,
          width: double.infinity,
          child: Center(
            child: _animations.buttonTransition(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                child: Image.asset(widget.data.image, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // 2. Title with animated transition
        _animations.textTransition(
          child: widget.data.impText != null && widget.data.impText!.isNotEmpty
              ? RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: widget.data.title,
                    style: CustomTextStyle.bold32(
                      AppColors.textDark,
                    ).copyWith(fontSize: 28.sp, fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(
                        text: " ${widget.data.impText}",
                        style:
                            CustomTextStyle.bold32(
                              AppColors.onboardingGradient,
                            ).copyWith(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (widget.data.subTitle != null &&
                          widget.data.subTitle!.isNotEmpty)
                        TextSpan(
                          text: "\n${widget.data.subTitle}",
                          style: CustomTextStyle.bold32(AppColors.textDark)
                              .copyWith(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                    ],
                  ),
                )
              : Text(
                  widget.data.title,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.bold32(
                    AppColors.textDark,
                  ).copyWith(fontSize: 28.sp, fontWeight: FontWeight.w800),
                ),
        ),
        SizedBox(height: 12.h),

        // 3. Description with animated tagline transition
        _animations.taglineTransition(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              widget.data.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
