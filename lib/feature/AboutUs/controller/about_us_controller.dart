import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../model/about_us_model.dart';

class AboutUsState {
  final List<AboutMenuItemModel> menuItems;

  AboutUsState({
    required this.menuItems, 
  });
}

class AboutUsController extends StateNotifier<AboutUsState> {
  AboutUsController()
      : super(
          AboutUsState(
            menuItems: [
              AboutMenuItemModel(
                id: '1',
                title: 'Our Mission',
                icon: Icons.favorite_border,
              ),
              AboutMenuItemModel(
                id: '2',
                title: 'Who We Are',
                icon: Icons.people_outline,
              ),
              AboutMenuItemModel(
                id: '3',
                title: 'Privacy Policy',
                icon: Icons.lock_outline,
              ),
              AboutMenuItemModel(
                id: '4',
                title: 'Terms Of Service',
                icon: Icons.description_outlined,
              ),
            ],
          ),
        );

  void onMenuItemTap(String id, BuildContext context) {
    switch (id) {
      case '1':
        context.push(AppRouteNames.ourMissionScreen);
        break;
      case '2':
        context.push(AppRouteNames.whoWeAreScreen);
        break;
      case '3':
        context.push(AppRouteNames.privacyPolicyScreen);
        break;
      case '4':
        context.push(AppRouteNames.termsOfServiceScreen);
        break;
    }
  }
}