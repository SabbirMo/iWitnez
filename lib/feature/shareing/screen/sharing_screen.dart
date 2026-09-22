import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/services/permission_service.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/feature/shareing/model/shareing_model.dart';
import 'package:iwitnez/feature/shareing/provider/shareing_provider.dart';
import 'package:iwitnez/feature/shareing/widget/shareing_widget.dart';
import 'package:iwitnez/router/app_route_names.dart';

class SharingScreen extends ConsumerStatefulWidget {
  const SharingScreen({super.key});

  @override
  ConsumerState<SharingScreen> createState() => _SharingScreenState();
}

class _SharingScreenState extends ConsumerState<SharingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    context.go(AppRouteNames.addTrustedContactScreen);
  }

  void _handleError(String message, bool isPermanentlyDenied) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isPermanentlyDenied ? 4 : 3),
        action: isPermanentlyDenied
            ? SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () {
                  ref.read(permissionServiceProvider).openSettings();
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharingState = ref.watch(shareingProvider);
    final notifier = ref.read(shareingProvider.notifier);
    final currentItem = shareingList[sharingState.currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              // Top Bar: Back Button & Step Counter (e.g. 1 of 3)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      notifier.previousPage(
                        _pageController,
                        onBack: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            _navigateToNextScreen();
                          }
                        },
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textDark,
                      size: 20.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    '${sharingState.currentIndex + 1} of ${shareingList.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.buttonPrimaryLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Page Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: shareingList.length,
                  onPageChanged: (index) {
                    notifier.changeIndex(index);
                  },
                  itemBuilder: (_, index) {
                    final data = shareingList[index];
                    return ShareingWidget(data: data);
                  },
                ),
              ),

              // Action Buttons
              CustomButton(
                text: currentItem.buttonText,
                icon: currentItem.buttonIcon,
                isLoading: sharingState.isLoading,
                onTap: sharingState.isLoading
                    ? null
                    : () => notifier.executeCurrentStep(
                        controller: _pageController,
                        totalPages: shareingList.length,
                        onCompleted: _navigateToNextScreen,
                        onError: _handleError,
                      ),
              ),
              SizedBox(height: 8.h),

              TextButton(
                onPressed: () {
                  notifier.skip(
                    _pageController,
                    shareingList.length,
                    onCompleted: _navigateToNextScreen,
                  );
                },
                child: Text(
                  'Not Now',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buttonPrimaryLight,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
