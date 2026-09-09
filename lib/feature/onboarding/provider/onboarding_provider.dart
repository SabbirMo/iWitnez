import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingProvider extends Notifier<int> {
  @override
  int build() => 0;

  void changeIndex(int index) {
    state = index;
  }

  void nextPage(PageController pageController, int totalPage) {
    if (state < totalPage - 1) {
      state++;
      pageController.animateToPage(
        state,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}

final onboardingProvider = NotifierProvider<OnboardingProvider, int>(
  OnboardingProvider.new,
);
