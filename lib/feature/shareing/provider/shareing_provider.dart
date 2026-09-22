import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iwitnez/feature/shareing/actions/sharing_step_action.dart';

class SharingState {
  final int currentIndex;
  final bool isLoading;
  final bool hasAutoRequestedNotification;

  const SharingState({
    this.currentIndex = 0,
    this.isLoading = false,
    this.hasAutoRequestedNotification = false,
  });

  SharingState copyWith({
    int? currentIndex,
    bool? isLoading,
    bool? hasAutoRequestedNotification,
  }) {
    return SharingState(
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      hasAutoRequestedNotification:
          hasAutoRequestedNotification ?? this.hasAutoRequestedNotification,
    );
  }
}

class ShareingProvider extends Notifier<SharingState> {
  final List<SharingStepAction> _actions;

  ShareingProvider({List<SharingStepAction>? actions})
      : _actions = actions ??
            const [
              LocationStepAction(),
              NotificationStepAction(),
              MediaStepAction(),
            ];

  @override
  SharingState build() => const SharingState();

  void changeIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void nextPage(
    PageController pageController,
    int totalPages, {
    VoidCallback? onCompleted,
  }) {
    if (state.currentIndex < totalPages - 1) {
      pageController.animateToPage(
        state.currentIndex + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      onCompleted?.call();
    }
  }

  void previousPage(
    PageController pageController, {
    VoidCallback? onBack,
  }) {
    if (state.currentIndex > 0) {
      pageController.animateToPage(
        state.currentIndex - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      onBack?.call();
    }
  }

  void skip(
    PageController pageController,
    int totalPages, {
    VoidCallback? onCompleted,
  }) {
    nextPage(pageController, totalPages, onCompleted: onCompleted);
  }

  /// Executes the action for the current step (OCP & Strategy Pattern).
  Future<void> executeCurrentStep({
    required PageController controller,
    required int totalPages,
    VoidCallback? onCompleted,
    void Function(String message, bool isPermanentlyDenied)? onError,
  }) async {
    if (state.isLoading) return;

    final index = state.currentIndex;
    if (index >= _actions.length) {
      nextPage(controller, totalPages, onCompleted: onCompleted);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final action = _actions[index];
      final result = await action.execute(ref);

      if (result.isSuccess) {
        nextPage(controller, totalPages, onCompleted: onCompleted);
      } else if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
        onError?.call(result.errorMessage!, result.isPermanentlyDenied);
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Automatically requests notification permission when user arrives at index 1.
  void handleAutoRequestForIndex({
    required int index,
    required PageController controller,
    required int totalPages,
    VoidCallback? onCompleted,
    void Function(String message, bool isPermanentlyDenied)? onError,
  }) {
    if (index == 1 && !state.hasAutoRequestedNotification) {
      state = state.copyWith(hasAutoRequestedNotification: true);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (state.currentIndex == 1 && !state.isLoading) {
          executeCurrentStep(
            controller: controller,
            totalPages: totalPages,
            onCompleted: onCompleted,
            onError: onError,
          );
        }
      });
    }
  }
}

final shareingProvider =
    NotifierProvider<ShareingProvider, SharingState>(ShareingProvider.new);
