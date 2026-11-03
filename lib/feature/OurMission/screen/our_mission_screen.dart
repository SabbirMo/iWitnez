import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../provider/our_mission_provider.dart';
import '../widget/mission_content.dart';

class OurMissionScreen extends ConsumerWidget {
  const OurMissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ourMissionControllerProvider);
    final missionData = state.missionData;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E15) : const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D0E15) : const Color(0xFFF9F9F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouteNames.mainUserHome);
            }
          },
        ),
        title: Text(
          'Our Mission',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: MissionContent(
            title: missionData.title,
            description: missionData.description,
            image: ImageAssets.ourMissionImage, 
          ),
        ),
      ),
    );
  }
}
