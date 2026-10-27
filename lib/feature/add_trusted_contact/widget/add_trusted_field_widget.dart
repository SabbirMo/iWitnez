import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import 'package:iwitnez/core/widgets/textfield_hint_text.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/provider/trusted_circle_provider.dart';
import 'package:iwitnez/feature/add_trusted_contact/model/trusted_contact_model.dart';
import 'package:iwitnez/feature/add_trusted_contact/provider/add_trusted_contact_provider.dart';
import 'package:iwitnez/feature/add_trusted_contact/widget/add_contact_widget.dart';

class AddTrustedFieldWidget extends ConsumerStatefulWidget {
  final TrustedContactModel? contact;
  final CircleMember? circleMember;
  final String? circleTitle;
  final bool isEditMember;

  const AddTrustedFieldWidget({
    super.key,
    this.contact,
    this.circleMember,
    this.circleTitle,
    this.isEditMember = false,
  });

  @override
  ConsumerState<AddTrustedFieldWidget> createState() =>
      _AddTrustedFieldWidgetState();
}

class _AddTrustedFieldWidgetState extends ConsumerState<AddTrustedFieldWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  bool get _isEditMode => widget.contact != null || widget.isEditMember;

  @override
  void initState() {
    super.initState();
    final circleMember = widget.circleMember;
    final contact = widget.contact;
    final state = ref.read(addTrustedContactProvider);

    _nameController = TextEditingController(
      text: circleMember?.name ?? contact?.fullName ?? state.fullName,
    );
    _emailController = TextEditingController(
      text: circleMember?.email ?? contact?.email ?? state.email,
    );
    _phoneController = TextEditingController(
      text: circleMember?.phone ?? contact?.phoneNumber ?? state.phoneNumber,
    );

    if (widget.circleMember != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(addTrustedContactProvider.notifier)
            .setContact(
              TrustedContactModel(
                id: widget.circleMember!.id,
                fullName: widget.circleMember!.name,
                email: widget.circleMember!.email,
                phoneNumber: widget.circleMember!.phone,
                relationship: widget.circleMember!.relationship.isNotEmpty
                    ? widget.circleMember!.relationship
                    : 'Sister',
                circle: widget.circleTitle?.toLowerCase() ?? 'family',
                emergencyAlerts: widget.circleMember!.emergencyAlerts,
                avatarUrl: widget.circleMember!.avatarUrl,
              ),
            );
      });
    } else if (widget.contact != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(addTrustedContactProvider.notifier)
            .setContact(widget.contact!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        ref
            .read(addTrustedContactProvider.notifier)
            .updateAvatarUrl(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _handleRemoveContact() {
    final contactId = widget.contact?.id ?? widget.circleMember?.id;
    final contactName =
        widget.contact?.fullName ?? widget.circleMember?.name ?? 'this contact';
    if (contactId == null || contactId.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Remove Trusted Contact',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Are you sure you want to remove $contactName from your trusted contacts?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await ref
                              .read(trustedContactsProvider.notifier)
                              .deleteContact(contactId);

                          if (widget.circleMember != null) {
                            final circleTitle = widget.circleTitle ?? 'Family';
                            ref
                                .read(trustedCircleProvider.notifier)
                                .removeMember(circleTitle, contactId);
                          }

                          if (mounted) {
                            CustomSnackBar.showSuccess(
                              context,
                              message:
                                  'Trusted contact was successfully removed.',
                            );
                            ref
                                .read(addTrustedContactProvider.notifier)
                                .resetForm();
                            if (context.canPop()) {
                              context.pop();
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            final msg = e is ApiError
                                ? e.message
                                : 'Failed to remove contact.';
                            CustomSnackBar.showError(context, message: msg);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Remove',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSaveContact() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      CustomSnackBar.showError(context, message: 'Please enter contact name.');
      return;
    }

    if (phone.isEmpty) {
      CustomSnackBar.showError(context, message: 'Please enter phone number.');
      return;
    }

    final state = ref.read(addTrustedContactProvider);
    final chosenAvatar =
        state.avatarUrl ??
        widget.circleMember?.avatarUrl ??
        widget.contact?.avatarUrl;

    final chosenRelationship = state.relationship.isNotEmpty
        ? state.relationship
        : (widget.circleMember?.relationship.isNotEmpty == true
              ? widget.circleMember!.relationship
              : (widget.contact?.relationship.isNotEmpty == true
                    ? widget.contact!.relationship
                    : 'Sister'));

    final chosenCircle = state.circle.isNotEmpty
        ? state.circle
        : (widget.contact?.circle.isNotEmpty == true
              ? widget.contact!.circle
              : (widget.circleTitle != null
                    ? widget.circleTitle!.toLowerCase()
                    : TrustedContactModel.defaultCircleFor(
                        chosenRelationship,
                      )));

    final localAvatarPath =
        (chosenAvatar != null &&
            !chosenAvatar.startsWith('http') &&
            File(chosenAvatar).existsSync())
        ? chosenAvatar
        : null;

    setState(() => _isSaving = true);

    try {
      if (widget.contact != null && widget.contact!.id != null) {
        // Edit Mode: PATCH /api/v1/contacts/<contact_id>/
        final updatePayload = <String, dynamic>{
          'name': name,
          'phone_number': phone,
          'email': email,
          'relationship': chosenRelationship.toLowerCase().trim(),
          'circle': chosenCircle.toLowerCase().trim(),
          'emergency_alerts_enabled': state.emergencyAlerts,
        };

        await ref
            .read(trustedContactsProvider.notifier)
            .updateContact(
              widget.contact!.id!,
              updatePayload,
              avatarFilePath: localAvatarPath,
            );

        if (mounted) {
          CustomSnackBar.showSuccess(
            context,
            message: 'Contact updated successfully.',
          );
          ref.read(addTrustedContactProvider.notifier).resetForm();
          if (context.canPop()) {
            context.pop();
          }
        }
      } else if (widget.isEditMember && widget.circleMember != null) {
        // Update Circle Member & Contact API
        final circleTitle = widget.circleTitle ?? 'Family';
        final updatePayload = <String, dynamic>{
          'name': name,
          'phone_number': phone,
          'email': email,
          'relationship': chosenRelationship.toLowerCase().trim(),
          'circle': circleTitle.toLowerCase().trim(),
          'emergency_alerts_enabled': state.emergencyAlerts,
        };

        if (widget.circleMember!.id.isNotEmpty) {
          await ref
              .read(trustedContactsProvider.notifier)
              .updateContact(
                widget.circleMember!.id,
                updatePayload,
                avatarFilePath: localAvatarPath,
              );
        }

        final updatedMember = widget.circleMember!.copyWith(
          name: name,
          phone: phone,
          email: email,
          relationship: chosenRelationship,
          emergencyAlerts: state.emergencyAlerts,
          avatarUrl: chosenAvatar,
        );

        ref
            .read(trustedCircleProvider.notifier)
            .updateMember(circleTitle, updatedMember);

        if (mounted) {
          CustomSnackBar.showSuccess(
            context,
            message: 'Member updated successfully.',
          );
          ref.read(addTrustedContactProvider.notifier).resetForm();
          if (context.canPop()) {
            context.pop();
          }
        }
      } else {
        // Add Mode: POST /api/v1/contacts/
        final newContact = TrustedContactModel(
          fullName: name,
          phoneNumber: phone,
          email: email,
          relationship: chosenRelationship,
          circle: chosenCircle,
          emergencyAlerts: state.emergencyAlerts,
          avatarUrl: chosenAvatar,
        );

        final created = await ref
            .read(trustedContactsProvider.notifier)
            .addContact(newContact, avatarFilePath: localAvatarPath);

        // Also add to circle
        final targetCircleTitle =
            widget.circleTitle ??
            (chosenCircle.isNotEmpty
                ? '${chosenCircle[0].toUpperCase()}${chosenCircle.substring(1)}'
                : 'Family');

        ref
            .read(trustedCircleProvider.notifier)
            .addMember(
              targetCircleTitle,
              CircleMember(
                id:
                    created?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                phone: phone,
                email: email,
                relationship: chosenRelationship,
                emergencyAlerts: state.emergencyAlerts,
                avatarUrl: created?.avatarUrl ?? chosenAvatar ?? '',
              ),
            );

        if (mounted) {
          CustomSnackBar.showSuccess(
            context,
            message: 'Trusted contact added successfully.',
          );
          ref.read(addTrustedContactProvider.notifier).resetForm();
          if (context.canPop()) {
            context.pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final msg = e is ApiError ? e.message : 'Failed to save contact.';
        CustomSnackBar.showError(context, message: msg);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTrustedContactProvider);
    final notifier = ref.read(addTrustedContactProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.black,
            size: 32.sp,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: _isEditMode
            ? Text(
                widget.isEditMember ? 'Edit Member' : 'Edit Contact',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                  letterSpacing: -0.2,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              if (!_isEditMode) ...[
                Text(
                  AppString.addTrustedContactTitle,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.ibold28(AppColors.black),
                ),
                SizedBox(height: 6.h),
                Text(
                  AppString.addTrustedContactEmer,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.regular12(AppColors.gray),
                ),
                SizedBox(height: 24.h),
              ] else ...[
                SizedBox(height: 10.h),
              ],

              // Avatar picker with purple border and gallery image picker
              _AvatarPicker(
                avatarUrl:
                    state.avatarUrl ??
                    widget.contact?.avatarUrl ??
                    widget.circleMember?.avatarUrl,
                onTap: _pickImageFromGallery,
              ),

              SizedBox(height: 18.h),

              // Form fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TrustedInputField(
                    label: "Full Name",
                    hintText: "@ name",
                    svgIcon: ImageAssets.personSvg,
                    controller: _nameController,
                  ),

                  _TrustedInputField(
                    label: "Email Address",
                    hintText: "example@gmail.com",
                    svgIcon: ImageAssets.emailSvg,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  _TrustedInputField(
                    label: "Phone Number",
                    hintText: "+880 1712 345678",
                    svgIcon: ImageAssets.callSvg,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const TextFieldHintText(text: "Relationship"),
                  RelationshipFieldWidget(
                    selectedRelationship: state.relationship.isNotEmpty
                        ? state.relationship
                        : (widget.contact?.relationship ??
                              widget.circleMember?.relationship ??
                              'Sister'),
                    onRelationshipChanged: notifier.updateRelationship,
                  ),

                  SizedBox(height: 12.h),

                  const TextFieldHintText(text: "Notification Preference"),
                  NotificationPreferenceWidget(
                    isEnabled: state.emergencyAlerts,
                    onChanged: notifier.toggleEmergencyAlerts,
                  ),

                  SizedBox(height: 28.h),

                  // Button: "Update Contact" / "Save Contact"
                  CustomButton(
                    text: _isEditMode ? "Update Contact" : "Save Contact",
                    icon: Icons.person_add_alt_1_outlined,
                    isLeadingIcon: true,
                    isLoading: _isSaving,
                    onTap: _handleSaveContact,
                  ),

                  if (_isEditMode) ...[
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: _handleRemoveContact,
                      borderRadius: BorderRadius.circular(50.r),
                      child: Container(
                        height: 52.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50.r),
                          border: Border.all(
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              ImageAssets.deleteIcon,
                              width: 18.w,
                              height: 18.w,
                              color: const Color(0xFFEF4444),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Remove Contact",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable pill-shaped input field
class _TrustedInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final String svgIcon;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _TrustedInputField({
    required this.label,
    required this.hintText,
    required this.svgIcon,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldHintText(text: label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: _pillBorder(),
            enabledBorder: _pillBorder(),
            focusedBorder: _pillBorder(AppColors.buttonGradientStart),
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.0.w),
              child: SvgPicture.asset(
                svgIcon,
                height: 16.h,
                width: 16.w,
                colorFilter: const ColorFilter.mode(
                  AppColors.buttonGradientStart,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  static OutlineInputBorder _pillBorder([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(50.r),
      borderSide: BorderSide(
        color: color ?? AppColors.fieldColor.withValues(alpha: 0.6),
      ),
    );
  }
}

/// Circular avatar picker with purple gradient border and edit badge
class _AvatarPicker extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onTap;

  const _AvatarPicker({required this.avatarUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 110.w,
        height: 105.w,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.buttonGradientStart,
                  width: 2.5,
                ),
              ),
              child: ClipOval(
                child: ContactAvatarWidget(avatarUrl: avatarUrl, radius: 46),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  color: AppColors.buttonGradientStart,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.buttonGradientStart.withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/svg/edit.svg',
                  width: 14.w,
                  height: 14.w,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
