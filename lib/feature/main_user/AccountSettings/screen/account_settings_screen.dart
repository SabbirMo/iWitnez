import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../provider/account_settings_provider.dart';
import '../widget/account_settings_tile.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountSettingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(
          'Account Settings',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(accountSettingsProvider.notifier).loadSettings(),
        color: const Color(0xFF8B5CF6),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              // ── Section label ──
              Text(
                'Account',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 10.h),

              // ── Settings card ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Email Address (Read-only: cannot be changed)
                    AccountSettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Email Address',
                      subtitle: state.email.isNotEmpty
                          ? state.email
                          : (state.isLoading ? '...' : ''),
                      onTap: null,
                    ),

                    // Phone Number (Read-only)
                    AccountSettingsTile(
                      icon: Icons.phone_outlined,
                      title: 'Phone Number',
                      subtitle: state.phone.isNotEmpty
                          ? state.phone
                          : (state.isLoading ? '...' : ''),
                      onTap: null,
                    ),

                    // Password (Navigates to Change Password screen)
                    AccountSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Password',
                      subtitle: '••••••••',
                      onTap: () {
                        context.push(AppRouteNames.changePasswordScreen);
                      },
                    ),

                    // Two-Factor Authentication
                    AccountSettingsTile(
                      icon: Icons.verified_user_outlined,
                      title: 'Two-Factor Authentication',
                      subtitle: state.isTwoFactorEnabled ? 'On' : 'Off',
                      isLoading: state.isToggling2FA,
                      onTap: state.isToggling2FA
                          ? null
                          : () {
                              ref
                                  .read(accountSettingsProvider.notifier)
                                  .toggleTwoFactor(context);
                            },
                    ),

                    // Delete Account (destructive — red)
                    AccountSettingsTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      iconColor: const Color(0xFFEF4444),
                      iconBgColor: const Color(0xFFFEE2E2),
                      titleColor: const Color(0xFFEF4444),
                      showDivider: false,
                      onTap: () => _confirmDeleteAccount(context, ref),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Delete confirmation dialog with password prompt ──
  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool isDeleting = false;
    String? errorMessage;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: const Color(0xFFEF4444),
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Delete Account',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to permanently delete your account? This action cannot be undone. Please enter your password to confirm.',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    enabled: !isDeleting,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFF6B7280),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: const BorderSide(
                          color: Color(0xFFEF4444),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: 10.h),
                    Text(
                      errorMessage!,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFEF4444),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDeleting
                    ? null
                    : () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                ),
                onPressed: isDeleting
                    ? null
                    : () async {
                        final password = passwordController.text.trim();
                        if (password.isEmpty) {
                          setDialogState(() {
                            errorMessage = 'Please enter your password';
                          });
                          return;
                        }

                        setDialogState(() {
                          isDeleting = true;
                          errorMessage = null;
                        });

                        try {
                          final successMessage = await ref
                              .read(accountSettingsProvider.notifier)
                              .deleteAccount(password: password);

                          if (dialogCtx.mounted) {
                            Navigator.of(dialogCtx).pop();
                          }

                          if (context.mounted) {
                            CustomSnackBar.showSuccess(
                              context,
                              message:
                                  successMessage ??
                                  'Your account has been deleted successfully.',
                            );
                            context.go(AppRouteNames.loginScreen);
                          }
                        } catch (e) {
                          final msg = ApiErrorHandler.getMessage(e);
                          if (dialogCtx.mounted) {
                            setDialogState(() {
                              isDeleting = false;
                              errorMessage = msg;
                            });
                          }
                        }
                      },
                child: isDeleting
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
