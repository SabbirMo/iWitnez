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
import 'package:iwitnez/core/constants/user_role/user_role.dart';
import 'package:iwitnez/core/utils/app_validator.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/core/widgets/role_selector.dart';
import 'package:iwitnez/core/widgets/textfield_hint_text.dart';
import 'package:iwitnez/feature/auth/create_account/provider/create_account_provider.dart';
import 'package:iwitnez/feature/onboarding/controller/start_animations.dart';
import 'package:iwitnez/router/app_route_names.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen>
    with TickerProviderStateMixin {
  late final StartAnimations _animations = StartAnimations(this);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void reassemble() {
    super.reassemble();
    _animations.reassemble();
  }

  @override
  void dispose() {
    _animations.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(createAccountProvider);
    final notifier = ref.read(createAccountProvider.notifier);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _animations.taglineTransition(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Image.asset(ImageAssets.mainLogo, width: 120.w),
                    SizedBox(height: 16.h),
                    Text(
                      AppString.createAccountTitle,
                      style: CustomTextStyle.bold30(AppColors.textDark),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      AppString.createAccountSubTitle,
                      style: CustomTextStyle.regular16(
                        AppColors.gray,
                      ).copyWith(fontSize: 12.sp),
                    ),
                    SizedBox(height: 10.h),

                    RoleSelector(
                      selectedRole: provider.role,
                      onChanged: notifier.setRole,
                    ),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFieldHintText(text: "Your Name"),
                          TextFormField(
                            validator: AppValidator.validateName,
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: "Your Name",
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(top: 14, bottom: 14),
                                child: SvgPicture.asset(
                                  ImageAssets.personSvg,
                                  width: 6.w,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextFieldHintText(text: "Email Address"),
                          TextFormField(
                            validator: AppValidator.validateEmail,
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "example@gmail.com",
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(top: 15, bottom: 15),
                                child: SvgPicture.asset(
                                  ImageAssets.emailSvg,
                                  width: 6.w,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextFieldHintText(text: "Password"),
                          TextFormField(
                            validator: AppValidator.validatePassword,
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: "Password",
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(top: 15, bottom: 15),
                                child: SvgPicture.asset(
                                  ImageAssets.lockSvg,
                                  width: 6.w,
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => notifier.passwordToggle(),
                                icon: Icon(
                                  provider.password
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            obscureText: !provider.password,
                          ),
                          SizedBox(height: 10.h),
                          TextFieldHintText(text: "Confirm Password"),
                          TextFormField(
                            validator: (value) =>
                                AppValidator.validateConfirmPassword(
                                  value,
                                  _passwordController.text,
                                ),
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              hintText: "Confirm Password",
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(top: 15, bottom: 15),
                                child: SvgPicture.asset(
                                  ImageAssets.lockSvg,
                                  width: 6.w,
                                ),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    notifier.confirmPasswordToggle(),
                                icon: Icon(
                                  provider.confirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            obscureText: !provider.confirmPassword,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Terms and Privacy Policy Checkbox Row
                    GestureDetector(
                      onTap: () => notifier.checkTermsAndConditions(
                        !provider.termsAndConditions,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.r),
                              border: Border.all(
                                color: AppColors.buttonGradientStart,
                                width: 1.8,
                              ),
                              color: provider.termsAndConditions
                                  ? AppColors.buttonGradientStart
                                  : Colors.transparent,
                            ),
                            child: provider.termsAndConditions
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 14.sp,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: AppString.youAcceptThe,
                                style: CustomTextStyle.regular14(
                                  AppColors.onboardingDesc,
                                ).copyWith(fontSize: 12.sp),
                                children: [
                                  TextSpan(
                                    text: AppString.termsOfService,
                                    style:
                                        CustomTextStyle.regular14(
                                          AppColors.buttonGradientStart,
                                        ).copyWith(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  TextSpan(
                                    text: AppString.and,
                                    style: CustomTextStyle.regular14(
                                      AppColors.onboardingDesc,
                                    ).copyWith(fontSize: 12.sp),
                                  ),
                                  TextSpan(
                                    text: AppString.privacyPolicy,
                                    style:
                                        CustomTextStyle.regular14(
                                          AppColors.buttonGradientStart,
                                        ).copyWith(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    CustomButton(
                      text: 'Create Account',
                      isEnabled: provider.termsAndConditions,
                      onTap: provider.termsAndConditions
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                final role = provider.role;
                                if (role == UserRole.mainUser) {
                                  context.go(AppRouteNames.mainUserHome);
                                } else {
                                  context.go(AppRouteNames.trustedHome);
                                }
                              }
                            }
                          : null,
                    ),
                    SizedBox(height: 20.h),
                    RichText(
                      text: TextSpan(
                        text: AppString.alreadyHaveAccount,
                        style: CustomTextStyle.regular14(AppColors.black),
                        children: [
                          TextSpan(
                            text: "Login",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.push(AppRouteNames.loginScreen);
                              },
                            style: CustomTextStyle.regular16(
                              AppColors.buttonGradientStart,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
