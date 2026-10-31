import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/utils/app_validator.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import 'package:iwitnez/core/widgets/textfield_hint_text.dart';
import '../provider/change_password_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword(ChangePasswordNotifier notifier) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final success = await notifier.changePassword(
      oldPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      final msg = ref.read(changePasswordProvider).successMessage ??
          'Password changed successfully';
      CustomSnackBar.showSuccess(
        context,
        message: msg,
      );
      if (context.canPop()) {
        context.pop();
      }
    } else {
      final errorMsg = ref.read(changePasswordProvider).errorMessage ??
          'Failed to change password. Please try again.';
      CustomSnackBar.showError(
        context,
        message: errorMsg,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordProvider);
    final notifier = ref.read(changePasswordProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 32.sp,
            color: AppColors.textDark,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'Change Password',
          style: GoogleFonts.inter(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Text(
                'Your new password must be different from previously used passwords and at least 8 characters long.',
                style: CustomTextStyle.regular16(
                  AppColors.onboardingDesc,
                ).copyWith(fontSize: 13.sp, height: 1.4),
              ),
              SizedBox(height: 20.h),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Current Password
                    const TextFieldHintText(text: 'Current Password'),
                    TextFormField(
                      controller: _currentPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter current password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                      obscureText: !state.isCurrentPasswordVisible,
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter current password',
                        prefixIcon: Icon(
                          Icons.key_outlined,
                          size: 20.sp,
                          color: AppColors.onboardingDesc,
                        ),
                        suffixIcon: IconButton(
                          onPressed: notifier.toggleCurrentPasswordVisibility,
                          icon: Icon(
                            state.isCurrentPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.onboardingDesc,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // 2. New Password
                    const TextFieldHintText(text: 'New Password'),
                    TextFormField(
                      controller: _newPasswordController,
                      validator: (value) {
                        final basicValidation = AppValidator.validatePassword(
                          value,
                        );
                        if (basicValidation != null) {
                          return basicValidation;
                        }
                        if (value == _currentPasswordController.text) {
                          return 'New password must be different from current password';
                        }
                        return null;
                      },
                      obscureText: !state.isNewPasswordVisible,
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        prefixIcon: Icon(
                          Icons.key_outlined,
                          size: 20.sp,
                          color: AppColors.onboardingDesc,
                        ),
                        suffixIcon: IconButton(
                          onPressed: notifier.toggleNewPasswordVisibility,
                          icon: Icon(
                            state.isNewPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.onboardingDesc,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // 3. Confirm New Password
                    const TextFieldHintText(text: 'Confirm New Password'),
                    TextFormField(
                      controller: _confirmPasswordController,
                      validator: (value) =>
                          AppValidator.validateConfirmPassword(
                            value,
                            _newPasswordController.text,
                          ),
                      obscureText: !state.isConfirmPasswordVisible,
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm new password',
                        prefixIcon: Icon(
                          Icons.key_outlined,
                          size: 20.sp,
                          color: AppColors.onboardingDesc,
                        ),
                        suffixIcon: IconButton(
                          onPressed: notifier.toggleConfirmPasswordVisibility,
                          icon: Icon(
                            state.isConfirmPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.onboardingDesc,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Action button
              CustomButton(
                text: 'Update Password',
                isLoading: state.isLoading,
                onTap: () => _handleUpdatePassword(notifier),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
