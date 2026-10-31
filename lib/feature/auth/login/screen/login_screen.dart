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
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import 'package:iwitnez/core/widgets/textfield_hint_text.dart';
import 'package:iwitnez/feature/auth/login/provider/login_notifier.dart';
import 'package:iwitnez/feature/auth/login/provider/login_provider.dart';
import 'package:iwitnez/core/services/fcm_service.dart';
import 'package:iwitnez/feature/onboarding/controller/start_animations.dart';
import 'package:iwitnez/router/app_route_names.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late final StartAnimations _animations = StartAnimations(this);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final userRole = await ref
        .read(loginNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (userRole != null) {
      final isTrusted = userRole == 'trusted_contact';
      final role = isTrusted ? UserRole.trustedContact : UserRole.mainUser;

      ref.read(userRoleProvider.notifier).set(role);

      // Step 1.1: Register Device Token with Backend if already permitted
      FcmService.instance.syncDeviceTokenIfPermitted();

      if (isTrusted) {
        context.go(AppRouteNames.trustedHome);
      } else {
        context.go(AppRouteNames.mainUserHome);
      }
    } else {
      final error = ref.read(loginNotifierProvider).error;
      final message = error is ApiError
          ? error.message
          : error != null
          ? ApiErrorHandler.getMessage(error)
          : 'Login failed. Please check your credentials and try again.';

      CustomSnackBar.showError(context, message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    final loginState = ref.watch(loginNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                            AppString.loginTitle,
                            style: CustomTextStyle.bold30(
                              isDark ? AppColors.white : AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            AppString.loginSubTitle,
                            style: CustomTextStyle.regular16(
                              isDark
                                  ? AppColors.white.withValues(alpha: 0.65)
                                  : AppColors.gray,
                            ).copyWith(fontSize: 12.sp),
                          ),
                          SizedBox(height: 20.h),

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFieldHintText(text: "Email Address"),
                                TextFormField(
                                  validator: AppValidator.validateEmail,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  decoration: InputDecoration(
                                    hintText: "example@gmail.com",
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.only(
                                        top: 15,
                                        bottom: 15,
                                      ),
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
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  decoration: InputDecoration(
                                    hintText: "Password",
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
                                      onPressed: () =>
                                          notifier.passwordToggle(),
                                      icon: Icon(
                                        provider.password
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                    ),
                                  ),
                                  obscureText: !provider.password,
                                ),

                                Align(
                                  alignment: .centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      context.push(
                                        AppRouteNames.forgotPasswordScreen,
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password ?",
                                      style: CustomTextStyle.regular14(
                                        AppColors.forgotPass,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14.h),
                          CustomButton(
                            text: 'Log In',
                            isLoading: loginState.isLoading,
                            onTap: loginState.isLoading
                                ? null
                                : () => _handleLogin(),
                          ),
                          SizedBox(height: 20.h),
                          RichText(
                            text: TextSpan(
                              text: AppString.haveAnAccount,
                              style: CustomTextStyle.regular14(
                                isDark ? AppColors.white : AppColors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: AppString.createAccount,
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      context.push(
                                        AppRouteNames.createAccountScreen,
                                      );
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
            );
          },
        ),
      ),
    );
  }
}
