import 'package:flutter/material.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class OnboardingScreenModel {
  final String image;
  final String title;
  final String impText;
  final String subTitle;
  final String description;
  OnboardingScreenModel({
    required this.image,
    required this.title,
    required this.impText,
    required this.subTitle,
    required this.description,
  });
}

List<OnboardingScreenModel> onboardingScreens(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return [
    OnboardingScreenModel(
      image: isDarkMode ? ImageAssets.darkOnboarding1 : ImageAssets.onboarding1,
      title: AppString.onboardingTitle1,
      impText: AppString.subTitle1,
      subTitle: AppString.subTitle2,
      description: AppString.onboardingDescription1,
    ),
    OnboardingScreenModel(
      image: isDarkMode ? ImageAssets.darkOnboarding2 : ImageAssets.onboarding2,
      title: AppString.onboardingTitle2,
      impText: AppString.subTitle3,
      subTitle: AppString.subTitle4,
      description: AppString.onboardingDescription2,
    ),
    OnboardingScreenModel(
      image: isDarkMode ? ImageAssets.darkOnboarding3 : ImageAssets.onboarding3,
      title: AppString.onboardingTitle2,
      impText: AppString.subTitle3,
      subTitle: AppString.subTitle4,
      description: AppString.onboardingDescription2,
    ),
  ];
}
