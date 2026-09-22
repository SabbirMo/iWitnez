import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/feature/auth/verification/model/verification_type.dart';
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

  void _handleSuccess() {
    if (!mounted) return;
    if (widget.onVerified != null) {
      widget.onVerified!();
      return;
    }

    final type = ref.read(verificationProvider).type;
    if (type == VerificationType.forgotPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified! Please login to your account.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      context.go(AppRouteNames.loginScreen);
    } else {
      // createAccount flow -> navigate to locationScreen
      context.go(AppRouteNames.shareingScreen);
    }
  }

  void _showError(String errorMsg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMsg), backgroundColor: AppColors.accentRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verificationProvider);
    final notifier = ref.read(verificationProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
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
                            style: CustomTextStyle.bold30(AppColors.textDark)
                                .copyWith(
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
                              color: AppColors.gray,
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
                              fillColor: Colors.white,
                              focusedFillColor: Colors.white,
                              filledFillColor: Colors.white,
                              showCursor: true,
                              cursorColor: AppColors.buttonGradientStart,
                              cursorWidth: 2.0,
                              hintCharacter: '-',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF9CA3AF),
                              ),
                              textStyle: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            onChanged: notifier.onPinChanged,
                            onCompleted: (pin) {
                              notifier.verifyCode(
                                onSuccess: _handleSuccess,
                                onError: _showError,
                              );
                            },
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
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                              GestureDetector(
                                onTap: state.canResend
                                    ? () {
                                        notifier.resendCode(
                                          onResent: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Verification code resent successfully!',
                                                ),
                                                backgroundColor: AppColors
                                                    .buttonGradientStart,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    : null,
                                child: Text(
                                  'Resend',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: state.canResend
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
                            isLoading: state.isLoading,
                            onTap: () {
                              notifier.verifyCode(
                                onSuccess: _handleSuccess,
                                onError: _showError,
                              );
                            },
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
                                  color: AppColors.textDark,
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
