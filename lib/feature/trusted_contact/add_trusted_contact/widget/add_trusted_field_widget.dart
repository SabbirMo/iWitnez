import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/image_assets/image_assets.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/core/widgets/textfield_hint_text.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/model/trusted_contact_model.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/provider/add_trusted_contact_provider.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/widget/add_contact_widget.dart';

class AddTrustedFieldWidget extends ConsumerStatefulWidget {
  final TrustedContactModel? contact;
  const AddTrustedFieldWidget({super.key, this.contact});

  @override
  ConsumerState<AddTrustedFieldWidget> createState() =>
      _AddTrustedFieldWidgetState();
}

class _AddTrustedFieldWidgetState extends ConsumerState<AddTrustedFieldWidget> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    final state = ref.read(addTrustedContactProvider);
    _nameController = TextEditingController(
      text: contact?.fullName ?? state.fullName,
    );
    _emailController = TextEditingController(
      text: contact?.email ?? state.email,
    );
    _phoneController = TextEditingController(
      text: contact?.phoneNumber ?? state.phoneNumber,
    );

    if (widget.contact != null) {
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

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.accentRed
            : AppColors.buttonGradientStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _handleSaveContact() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      _showFeedback("Please enter full name", isError: true);
      return;
    }

    if (phone.isEmpty) {
      _showFeedback("Please enter phone number", isError: true);
      return;
    }

    final state = ref.read(addTrustedContactProvider);
    final existingId = widget.contact?.id ?? state.id;

    final savedContact = TrustedContactModel(
      id: existingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: name,
      email: email,
      phoneNumber: phone,
      relationship: state.relationship.isNotEmpty
          ? state.relationship
          : (widget.contact?.relationship.isNotEmpty == true
                ? widget.contact!.relationship
                : 'Sister'),
      emergencyAlerts: state.emergencyAlerts,
      avatarUrl: state.avatarUrl ?? widget.contact?.avatarUrl,
    );

    // Save or update in shared provider list
    ref
        .read(trustedContactsProvider.notifier)
        .saveOrUpdateContact(savedContact);

    // Reset form state
    ref.read(addTrustedContactProvider.notifier).resetForm();

    _showFeedback(
      existingId != null
          ? "Updated contact: $name"
          : "Added $name to trusted contacts",
    );

    if (context.canPop()) {
      context.pop();
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.black,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Text(
                AppString.addTrustedContactTitle,
                textAlign: TextAlign.center,
                style: CustomTextStyle.ibold32(AppColors.black),
              ),
              SizedBox(height: 6.h),
              Text(
                AppString.addTrustedContactEmer,
                textAlign: TextAlign.center,
                style: CustomTextStyle.regular12(AppColors.gray),
              ),
              SizedBox(height: 24.h),

              // Avatar picker with purple border and gallery image picker
              _AvatarPicker(
                avatarUrl: state.avatarUrl,
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
                    selectedRelationship: state.relationship,
                    onRelationshipChanged: notifier.updateRelationship,
                  ),

                  SizedBox(height: 12.h),

                  const TextFieldHintText(text: "Notification Preference"),
                  NotificationPreferenceWidget(
                    isEnabled: state.emergencyAlerts,
                    onChanged: notifier.toggleEmergencyAlerts,
                  ),

                  SizedBox(height: 28.h),

                  // Save Contact Button
                  CustomButton(
                    text: "Save Contact",
                    icon: Icons.person_add_alt_1_outlined,
                    isLeadingIcon: true,
                    onTap: _handleSaveContact,
                  ),
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
