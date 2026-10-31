import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import 'package:iwitnez/feature/auth/verification/model/verification_type.dart';
import 'package:iwitnez/feature/auth/verification/provider/verification_notifer.dart';
import 'package:iwitnez/feature/auth/verification/provider/verification_provider.dart';
import 'package:iwitnez/feature/onboarding/controller/start_animations.dart';
import 'package:iwitnez/router/app_route_names.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String? email;
  final VerificationType type;
  final int codeLength;
  final VoidCallback? onVerified;
  final VoidCallback? onChangeEmail;

  const VerificationScreen({
    super.key,
    this.email,
    this.type = VerificationType.createAccount,
    this.codeLength = 4,
    this.onVerified,
    this.onChangeEmail,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen>
    with TickerProviderStateMixin {
  late final StartAnimations _animations = StartAnimations(this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(verificationProvider.notifier)
          .init(
            email: widget.email,
            type: widget.type,
            codeLength: widget.codeLength,
          );
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _animations.reassemble();
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  Future<void> _handleVerify([String? code]) async {
    if (ref.read(verificationNotiferProvider).isLoading) return;

    final state = ref.read(verificationProvider);
    final notifier = ref.read(verificationProvider.notifier);
    final enteredCode = (code ?? notifier.pinController.text).trim();

    if (enteredCode.length != state.codeLength) {
      notifier.pinController.triggerError();
      CustomSnackBar.showError(
        context,
        message: 'Please enter the complete ${state.codeLength}-digit code',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final isForgotPassword = state.type == VerificationType.forgotPassword;

    final success = await ref
        .read(verificationNotiferProvider.notifier)
        .verifyOtp(
          email: state.email,
          otp: enteredCode,
          isForgotPassword: isForgotPassword,
        );

    if (!mounted) return;

    if (success) {
      CustomSnackBar.showSuccess(
        context,
        message: isForgotPassword
            ? 'Code verified successfully!'
            : 'Email verified successfully!',
      );
      _handleSuccess(enteredCode);
    } else {
      notifier.pinController.triggerError();
      final error = ref.read(verificationNotiferProvider).error;
      final message = error is ApiError
          ? error.message
          : error != null
          ? ApiErrorHandler.getMessage(error)
          : 'Verification failed. Please check the code and try again.';

      CustomSnackBar.showError(context, message: message);
    }
  }

  Future<void> _handleResendOtp() async {
    final state = ref.read(verificationProvider);
    final notifier = ref.read(verificationProvider.notifier);

    if (!state.canResend || ref.read(verificationNotiferProvider).isLoading) {
      return;
    }

    final purpose = state.type == VerificationType.forgotPassword
        ? 'password_reset'
        : 'email_verification';

    final success = await ref
        .read(verificationNotiferProvider.notifier)
        .resendOtp(email: state.email, purpose: purpose);

    if (!mounted) return;

    if (success) {
      notifier.restartTimer();
      notifier.clear();
      CustomSnackBar.showSuccess(
        context,
        message: 'A fresh verification code has been sent to your email.',
      );
    } else {
      final error = ref.read(verificationNotiferProvider).error;
      final message = error is ApiError
          ? error.message
          : error != null
          ? ApiErrorHandler.getMessage(error)
          : 'Failed to resend code. Please try again.';

      CustomSnackBar.showError(context, message: message);
    }
  }

  void _handleSuccess([String? code]) {
    if (!mounted) return;
    if (widget.onVerified != null) {
      widget.onVerified!();
      return;
    }

    final state = ref.read(verificationProvider);
    if (state.type == VerificationType.forgotPassword) {
      context.go(
        AppRouteNames.newPasswordScreen,
        extra: {
          'email': state.email,
          'otp':
              code ??
              ref.read(verificationProvider.notifier).pinController.text,
        },
      );
    } else {
      // createAccount flow -> navigate to locationScreen
      context.go(AppRouteNames.shareingScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verificationProvider);
    final notifier = ref.read(verificationProvider.notifier);
    final verifyState = ref.watch(verificationNotiferProvider);
    final isLoading = verifyState.isLoading || state.isLoading;

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
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _animations.taglineTransition(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. App Logo (Shield Camera)
                          Image.asset(
                            ImageAssets.mainLogo,
                            width: 130.w,
                            height: 130.w,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 28.h),

                          // 2. Title
                          Text(
                            'Verify Your Email',
                            textAlign: TextAlign.center,
                            style:
                                CustomTextStyle.bold30(
                                  isDark ? AppColors.white : AppColors.textDark,
                                ).copyWith(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          SizedBox(height: 10.h),

                          // 3. Subtitle description
                          Text(
                            "We've Sent A ${state.codeLength}-Digit Verification Code To",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? AppColors.white.withValues(alpha: 0.65)
                                  : AppColors.gray,
                            ),
                          ),
                          SizedBox(height: 5.h),

                          // 4. Target Email
                          Text(
                            state.email,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                            ),
                          ),
                          SizedBox(height: 32.h),

                          // 5. PIN Code Fields using pin_code_fields: ^10.0.0
                          MaterialPinField(
                            length: state.codeLength,
                            pinController: notifier.pinController,
                            autoFocus: true,
                            theme: MaterialPinTheme(
                              shape: MaterialPinShape.outlined,
                              cellSize: Size(64.w, 64.h),
                              spacing: 14.w,
                              borderRadius: BorderRadius.circular(14.r),
                              borderWidth: 1.5,
                              focusedBorderWidth: 1.8,
                              borderColor: const Color(0xFFE5E7EB),
                              focusedBorderColor: AppColors.buttonGradientStart,
                              filledBorderColor: AppColors.buttonGradientStart,
                              fillColor: isDark
                                  ? Colors.transparent
                                  : Colors.white,
                              focusedFillColor: isDark
                                  ? Colors.transparent
                                  : Colors.white,
                              filledFillColor: isDark
                                  ? Colors.transparent
                                  : Colors.white,
                              showCursor: true,
                              cursorColor: AppColors.buttonGradientStart,
                              cursorWidth: 2.0,
                              hintCharacter: '-',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w300,
                                color: isDark
                                    ? AppColors.white
                                    : const Color(0xFF9CA3AF),
                              ),
                              textStyle: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.textDark,
                              ),
                            ),
                            onChanged: notifier.onPinChanged,
                            onCompleted: (pin) => _handleVerify(pin),
                          ),
                          SizedBox(height: 24.h),

                          // 6. Resend Countdown Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't Receive The Code? ",
                                style: GoogleFonts.inter(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? AppColors.white.withValues(alpha: 0.65)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                              GestureDetector(
                                onTap: state.canResend && !isLoading
                                    ? _handleResendOtp
                                    : null,
                                child: Text(
                                  'Resend',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: state.canResend && !isLoading
                                        ? AppColors.buttonGradientStart
                                        : AppColors.buttonGradientStart
                                              .withValues(alpha: 0.75),
                                  ),
                                ),
                              ),
                              if (!state.canResend) ...[
                                Text(
                                  ' In ${state.formattedTimer}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 28.h),

                          // 7. Verify Button
                          CustomButton(
                            text: 'Verify Email',
                            icon: Icons.arrow_forward_rounded,
                            isLoading: isLoading,
                            onTap: isLoading ? null : () => _handleVerify(),
                          ),
                          SizedBox(height: 24.h),

                          // 8. Wrong Email? Change Email
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Wrong Email? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.textDark,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (widget.onChangeEmail != null) {
                                    widget.onChangeEmail!();
                                  } else if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    final type = ref
                                        .read(verificationProvider)
                                        .type;
                                    if (type ==
                                        VerificationType.forgotPassword) {
                                      context.pushReplacement(
                                        AppRouteNames.forgotPasswordScreen,
                                      );
                                    } else {
                                      context.pushReplacement(
                                        AppRouteNames.createAccountScreen,
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  'Change Email',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.buttonGradientStart,
                                  ),
                                ),
                              ),
                            ],
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
