import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/feature/auth/create_account/screen/create_account_screen.dart';
import 'package:iwitnez/feature/onboarding/onboarding_start_screen.dart';
import 'package:iwitnez/feature/onboarding/screen/onboarding_screen.dart';
import 'package:iwitnez/feature/splash/screen/splash_screen.dart';
import 'package:iwitnez/router/app_route_names.dart';

final appPages = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRouteNames.splashScreen,
    routes: [
      GoRoute(
        path: AppRouteNames.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: AppRouteNames.onBoardingStartScreen,
        builder: (context, state) => const OnboardingStartScreen(),
      ),
      GoRoute(
        path: AppRouteNames.onBoardingScreen,
        builder: (context, state) => const OnboardingScreen(),
      ),

      //Account Routes
      GoRoute(
        path: AppRouteNames.createAccountScreen,
        builder: (context, state) => const CreateAccountScreen(),
      ),
    ],

    //if page not found show this message
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text("Page Not Found: ${state.error}"))),
  ),
);
