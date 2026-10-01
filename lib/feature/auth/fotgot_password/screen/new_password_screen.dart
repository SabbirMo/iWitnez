import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/utils/app_validator.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/core/widgets/textfield_hint_text.dart';
import 'package:iwitnez/feature/auth/fotgot_password/provider/new_password_provider.dart';
import 'package:iwitnez/feature/onboarding/controller/start_animations.dart';
import 'package:iwitnez/router/app_route_names.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  final String? email;

  const NewPasswordScreen({super.key, this.email});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen>
    with TickerProviderStateMixin {
  late final StartAnimations _animations;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _animations = StartAnimations(this);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void reassemble() {
    super.reassemble();
    _animations.entranceController.forward(from: 0.0);
    _animations.reassemble();
  }

  @override
  void dispose() {
    _animations.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(NewPasswordProvider notifier) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    notifier.setLoading(true);

    // Simulate network request for updating the password
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    notifier.setLoading(false);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76.w,
                    height: 76.w,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 54.w,
                        height: 54.w,
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Password Changed!",
                    textAlign: TextAlign.center,
                    style: CustomTextStyle.bold30(
                      AppColors.textDark,
                    ).copyWith(fontSize: 22.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Your new password has been set successfully. You can now login to your account.",
                    textAlign: TextAlign.center,
                    style: CustomTextStyle.regular14(
                      AppColors.onboardingDesc,
                    ).copyWith(fontSize: 13.sp, height: 1.4),
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    text: "Back to Login",
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      context.go(AppRouteNames.loginScreen);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newPasswordProvider);
    final notifier = ref.read(newPasswordProvider.notifier);

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
                            AppString.newPasswordTitle,
                            style: CustomTextStyle.bold30(AppColors.textDark),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            AppString.newPasswordDescription,
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.regular16(
                              AppColors.gray,
                            ).copyWith(fontSize: 12.sp),
                          ),
                          SizedBox(height: 16.h),

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFieldHintText(text: AppString.newPassword),
                                TextFormField(
                                  controller: _passwordController,
                                  validator: AppValidator.validatePassword,
                                  obscureText: !state.isPasswordVisible,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    hintText: "Enter new password",
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.only(
                                        top: 15,
                                        bottom: 15,
                                      ),
                                      child: SvgPicture.asset(
                                        ImageAssets.lockSvg,
                                        width: 6.w,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed:
                                          notifier.togglePasswordVisibility,
                                      icon: Icon(
                                        state.isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: AppColors.onboardingDesc,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                TextFieldHintText(
                                  text: AppString.confirmPassword,
                                ),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  validator: (value) =>
                                      AppValidator.validateConfirmPassword(
                                        value,
                                        _passwordController.text,
                                      ),
                                  obscureText: !state.isConfirmPasswordVisible,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                    hintText: "Confirm new password",
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.only(
                                        top: 15,
                                        bottom: 15,
                                      ),
                                      child: SvgPicture.asset(
                                        ImageAssets.lockSvg,
                                        width: 6.w,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: notifier
                                          .toggleConfirmPasswordVisibility,
                                      icon: Icon(
                                        state.isConfirmPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: AppColors.onboardingDesc,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30.h),
                          CustomButton(
                            text: AppString.resetPassword,
                            isLoading: state.isLoading,
                            onTap: () => _handleSubmit(notifier),
                          ),
                          SizedBox(height: 24.h),

                          RichText(
                            text: TextSpan(
                              text: "Remember your password? ",
                              style: CustomTextStyle.regular14(AppColors.gray),
                              children: [
                                TextSpan(
                                  text: "Login",
                                  style: CustomTextStyle.semiBold14(
                                    AppColors.primaryPurple,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.go(AppRouteNames.loginScreen);
                                    },
                                ),
                              ],
                            ),
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
