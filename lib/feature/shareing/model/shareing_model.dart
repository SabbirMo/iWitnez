import 'package:flutter/material.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class ShareingModel {
  final String image;
  final String title;
  final String? impText;
  final String? subTitle;
  final String description;
  final String buttonText;
  final IconData buttonIcon;

  ShareingModel({
    required this.image,
    required this.title,
    this.impText,
    this.subTitle,
    required this.description,
    this.buttonText = "Continue",
    this.buttonIcon = Icons.arrow_forward_rounded,
  });
}

List<ShareingModel> shareingList = [
  ShareingModel(
    image: ImageAssets.location,
    title: AppString.allowLocationTitle,
    impText: AppString.allowLocationImportantText,
    subTitle: AppString.allowLocationImp1,
    description: AppString.allowLocationDesc,
    buttonText: "Allow Location",
    buttonIcon: Icons.location_on_outlined,
  ),
  ShareingModel(
    image: ImageAssets.notification,
    title: AppString.allowNotiticationTitle,
    impText: AppString.allowNotiticationImportantText,
    subTitle: AppString.allowNotiticationImp1,
    description: AppString.allowNotiticationDesc,
    buttonText: "Allow Notifications",
    buttonIcon: Icons.notifications_none_outlined,
  ),
  ShareingModel(
    image: ImageAssets.allowCamera,
    title: AppString.allowCameraTitle,
    impText: AppString.allowCameraImportantText,
    subTitle: "",
    description: AppString.allowCameraDesc,
    buttonText: "Allow Camera & Microphone",
    buttonIcon: Icons.camera_alt_outlined,
  ),
];
