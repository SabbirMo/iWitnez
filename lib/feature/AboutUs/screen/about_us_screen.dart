import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../provider/about_us_provider.dart';
import '../widget/about_menu_tile.dart';

class AboutUsScreen extends ConsumerWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aboutUsControllerProvider);
    final controller = ref.read(aboutUsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Assuming AppColors.background is this
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouteNames.mainUserHome);
            }
          },
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
             SizedBox(height: 10.h),
            Container(
              height: 100,
              width: 100,
              child:  Image.asset(ImageAssets.mainLogo),
            ),
            SizedBox(height: 5.h),
           Image.asset(ImageAssets.logoText,width: 140.w,),
           SizedBox(height: 20.h),
            // --- Menu Items Container ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ...state.menuItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    
                    return Column(
                      children: [
                        AboutMenuTile(
                          icon: item.icon,
                          title: item.title,
                          onTap: () => controller.onMenuItemTap(item.id, context),
                        ),
                        // Add divider between items, but not after the last one
                        if (index != state.menuItems.length - 1)
                          Divider(
                            height: 1,
                            indent: 70, // Aligns with text, skipping the icon
                            endIndent: 16,
                            color: Colors.grey.withOpacity(0.1),
                          ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}