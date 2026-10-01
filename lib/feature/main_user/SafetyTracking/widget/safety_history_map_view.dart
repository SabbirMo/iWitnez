import 'package:flutter/material.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';

class SafetyHistoryMapView extends StatelessWidget {
  const SafetyHistoryMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(ImageAssets.historyMap, fit: BoxFit.cover),
    );
  }
}
