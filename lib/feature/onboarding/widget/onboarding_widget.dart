import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/onboarding/controller/start_animations.dart';
import 'package:iwitnez/feature/onboarding/model/onboarding_screen_model.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key, required this.data});

  final OnboardingScreenModel data;

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget>
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
        _animations.textTransition(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: widget.data.title,
              style: CustomTextStyle.bold32(AppColors.textDark),
              children: [
                TextSpan(
                  text: " ${widget.data.impText} ",
                  style: CustomTextStyle.bold32(AppColors.onboardingGradient),
                ),
                TextSpan(
                  text: widget.data.subTitle,
                  style: CustomTextStyle.bold32(AppColors.textDark),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 18.h),
        _animations.taglineTransition(
          child: Text(
            widget.data.description,
            textAlign: TextAlign.center,
            style: CustomTextStyle.regular16(AppColors.onboardingDesc),
          ),
        ),
        SizedBox(height: 24.h),
        _animations.buttonTransition(child: Image.asset(widget.data.image)),
      ],
    );
  }
}
