import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/feature/AboutUs/repository/content_repository.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../provider/our_mission_provider.dart';
import '../widget/mission_content.dart';

class OurMissionScreen extends ConsumerWidget {
  const OurMissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ourMissionControllerProvider);
    final missionAsync = ref.watch(ourMissionFutureProvider);
    final cmsData = missionAsync.value;

    final title = cmsData?.title.isNotEmpty == true
        ? cmsData!.title
        : state.missionData.title;

    final description = (cmsData?.subtitle.isNotEmpty == true ? cmsData!.subtitle : null) ??
        (cmsData?.content.isNotEmpty == true ? cmsData!.content : null) ??
        state.missionData.description;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MissionContent(
                title: title,
                description: description,
                image: ImageAssets.ourMissionImage,
              ),
              if (cmsData != null && cmsData.sections.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...cmsData.sections.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.heading,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.body,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
