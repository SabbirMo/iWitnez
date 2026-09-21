import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: SingleChildScrollView(
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
                  // Email Address
                  AccountSettingsTile(
                    icon: Icons.email_outlined,
                    title: 'Email Address',
                    subtitle: state.email,
                    onTap: () => _showEditDialog(
                      context,
                      ref,
                      title: 'Update Email',
                      initialValue: state.email,
                      keyboardType: TextInputType.emailAddress,
                      onSave: (val) =>
                          ref.read(accountSettingsProvider.notifier).updateEmail(val),
                    ),
                  ),

                  // Phone Number
                  AccountSettingsTile(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    subtitle: state.phone,
                    onTap: () => _showEditDialog(
                      context,
                      ref,
                      title: 'Update Phone',
                      initialValue: state.phone,
                      keyboardType: TextInputType.phone,
                      onSave: (val) =>
                          ref.read(accountSettingsProvider.notifier).updatePhone(val),
                    ),
                  ),

                  // Password
                  AccountSettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Password',
                    subtitle: '••••••••',
                    onTap: () {
                      // TODO: navigate to change-password screen
                    },
                  ),

                  // Two-Factor Authentication
                  AccountSettingsTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Two-Factor Authentication',
                    subtitle: state.isTwoFactorEnabled ? 'On' : 'Off',
                    onTap: () {
                      ref
                          .read(accountSettingsProvider.notifier)
                          .toggleTwoFactor(!state.isTwoFactorEnabled);
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
                    onTap: () => _confirmDeleteAccount(context),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ── Inline edit dialog ──
  void _showEditDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String initialValue,
    required TextInputType keyboardType,
    required void Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.of(ctx).pop();
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Delete confirmation dialog ──
  void _confirmDeleteAccount(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Delete Account',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFFEF4444)),
        ),
        content: Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: call delete account API then navigate to login
              context.go(AppRouteNames.loginScreen);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
