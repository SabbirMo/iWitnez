import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/feature/onboarding/controller/start_animations.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen>
    with TickerProviderStateMixin {
  late final StartAnimations _animations = StartAnimations(this);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void reassemble() {
    super.reassemble();
    _animations.reassemble();
  }

  @override
  void dispose() {
    _animations.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _animations.taglineTransition(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(ImageAssets.mainLogo, width: 120.w),
                          SizedBox(height: 16.h),
                          Text(
                            AppString.forgotPasswordTitle,
                            style: CustomTextStyle.bold30(AppColors.textDark),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            AppString.forgotPasswordDescription,
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.regular16(
                              AppColors.gray,
                            ).copyWith(fontSize: 12.sp),
                          ),
                          SizedBox(height: 16.h),

                          SizedBox(height: 30.h),
                          CustomButton(
                            text: 'Send',
                            onTap: () {
                              if (_formKey.currentState?.validate() ?? false) {}
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
