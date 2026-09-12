import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/feature/onboarding/model/onboarding_screen_model.dart';
import 'package:iwitnez/feature/onboarding/provider/onboarding_provider.dart';
import 'package:iwitnez/feature/onboarding/widget/onboarding_widget.dart';
import 'package:iwitnez/router/app_route_names.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(onboardingProvider);
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              context.pushReplacement(AppRouteNames.loginScreen);
            },
            child: Text(
              "Skip",
              style: CustomTextStyle.semiBold14(AppColors.buttonPrimaryLight),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) {
                    ref.read(onboardingProvider.notifier).changeIndex(value);
                  },
                  itemBuilder: (_, index) {
                    final data = onboardingScreens[index];
                    return OnboardingWidget(data: data);
                  },
                  itemCount: onboardingScreens.length,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: .center,
                spacing: 10,
                children: List.generate(onboardingScreens.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 10.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedIndex == index
                          ? AppColors.primaryColor
                          : AppColors.grayWhite,
                    ),
                  );
                }),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: "Next",
                onTap: () {
                  ref
                      .read(onboardingProvider.notifier)
                      .nextPage(_pageController, onboardingScreens.length);
                  if (mounted) {
                    if (selectedIndex == onboardingScreens.length - 1) {
                      context.pushReplacement(
                        AppRouteNames.createAccountScreen,
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
