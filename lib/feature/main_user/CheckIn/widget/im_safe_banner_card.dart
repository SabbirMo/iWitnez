import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class ImSafeBannerCard extends StatelessWidget {
  const ImSafeBannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Image.asset(
        ImageAssets.checkinImage,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
