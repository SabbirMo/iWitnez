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

final onboardingScreens = [
  OnboardingScreenModel(
    image: ImageAssets.onboarding1,
    title: AppString.onboardingTitle1,
    impText: AppString.subTitle1,
    subTitle: AppString.subTitle2,
    description: AppString.onboardingDescription1,
  ),
  OnboardingScreenModel(
    image: ImageAssets.onboarding2,
    title: AppString.onboardingTitle2,
    impText: AppString.subTitle3,
    subTitle: AppString.subTitle4,
    description: AppString.onboardingDescription2,
  ),
  OnboardingScreenModel(
    image: ImageAssets.onboarding3,
    title: AppString.onboardingTitle2,
    impText: AppString.subTitle3,
    subTitle: AppString.subTitle4,
    description: AppString.onboardingDescription2,
  ),
];
