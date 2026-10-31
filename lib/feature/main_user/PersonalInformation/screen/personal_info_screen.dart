import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iwitnez/core/network/base_url/api_base_url.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import '../provider/personal_info_provider.dart';
import '../widget/custom_text_field.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final GlobalKey _genderFieldKey = GlobalKey();

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _dobController;
  late final TextEditingController _genderController;
  late final TextEditingController _addressController;

  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    final user = ref.read(personalInfoControllerProvider).userInfo;
    _fullNameController = TextEditingController(text: user.fullName);
    _phoneNumberController = TextEditingController(text: user.phoneNumber);
    _emailController = TextEditingController(text: user.email);
    _dobController = TextEditingController(text: user.dateOfBirth);
    _genderController = TextEditingController(text: user.gender);
    _addressController = TextEditingController(text: user.address);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  IconData _getGenderIcon(String gender) {
    final g = gender.toLowerCase();
    if (g.contains('female')) {
      return Icons.female_rounded;
    } else if (g.contains('male')) {
      return Icons.male_rounded;
    } else if (g.contains('other')) {
      return Icons.transgender_rounded;
    }
    return Icons.person_outline_rounded;
  }

  ImageProvider? _getProfileImage(String savedUrl) {
    if (_pickedImagePath != null && _pickedImagePath!.isNotEmpty) {
      final file = File(_pickedImagePath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    final clean = savedUrl.trim();
    if (clean.isEmpty) {
      return null;
    }
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return NetworkImage(clean);
    }
    if (clean.startsWith('/')) {
      return NetworkImage('${ApiBaseUrl.baseUrl}$clean');
    }
    final file = File(clean);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _pickedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _selectDate(String currentDateStr) async {
    DateTime initialDate = DateTime(1998, 5, 12);
    try {
      final parsed = DateTime.tryParse(currentDateStr.trim());
      if (parsed != null) {
        initialDate = parsed;
      } else {
        final parts = currentDateStr.trim().split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          final day = int.tryParse(parts[0]) ?? 12;
          final monthStr = parts[1].toLowerCase();
          const monthNames = [
            'jan',
            'feb',
            'mar',
            'apr',
            'may',
            'jun',
            'jul',
            'aug',
            'sep',
            'oct',
            'nov',
            'dec',
          ];
          final monthIndex = monthNames.indexWhere(
            (m) => monthStr.startsWith(m),
          );
          final month = monthIndex != -1 ? monthIndex + 1 : 5;
          final year = int.tryParse(parts[2]) ?? 1998;
          initialDate = DateTime(year, month, day);
        }
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF101828),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      const monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final formatted =
          '${picked.day} ${monthNames[picked.month - 1]} ${picked.year}';
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  Future<void> _selectGender(String currentGender) async {
    final renderBox =
        _genderFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(
          Offset(0, renderBox.size.height + 4),
          ancestor: overlay,
        ),
        renderBox.localToGlobal(
          Offset(renderBox.size.width, renderBox.size.height + 4),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final options = [
      {'label': 'Female', 'icon': Icons.female_rounded},
      {'label': 'Male', 'icon': Icons.male_rounded},
      {'label': 'Other', 'icon': Icons.transgender_rounded},
    ];

    final selected = await showMenu<String>(
      context: context,
      position: position,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      constraints: BoxConstraints(
        minWidth: renderBox.size.width,
        maxWidth: renderBox.size.width,
      ),
      items: options.map((opt) {
        final label = opt['label'] as String;
        final icon = opt['icon'] as IconData;
        final isSelected = currentGender.toLowerCase() == label.toLowerCase();

        return PopupMenuItem<String>(
          value: label,
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF4F3FF)
                      : const Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFF667085),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF344054),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 19,
                ),
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null && mounted) {
      setState(() {
        _genderController.text = selected;
      });
    }
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    final controller = ref.read(personalInfoControllerProvider.notifier);

    File? avatarFile;
    if (_pickedImagePath != null && _pickedImagePath!.isNotEmpty) {
      final f = File(_pickedImagePath!);
      if (f.existsSync()) {
        avatarFile = f;
      }
    }

    try {
      final success = await controller.saveProfile(
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        dateOfBirth: _dobController.text,
        gender: _genderController.text,
        address: _addressController.text,
        avatarFile: avatarFile,
      );

      if (success && mounted) {
        setState(() {
          _pickedImagePath = null;
        });
        if (context.canPop()) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context,
          message: ApiErrorHandler.getMessage(e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(personalInfoControllerProvider, (previous, next) {
      final oldUser = previous?.userInfo;
      final newUser = next.userInfo;
      if (oldUser != newUser) {
        if (_fullNameController.text.isEmpty ||
            _fullNameController.text == oldUser?.fullName) {
          _fullNameController.text = newUser.fullName;
        }
        if (_phoneNumberController.text.isEmpty ||
            _phoneNumberController.text == oldUser?.phoneNumber) {
          _phoneNumberController.text = newUser.phoneNumber;
        }
        if (_emailController.text.isEmpty ||
            _emailController.text == oldUser?.email) {
          _emailController.text = newUser.email;
        }
        if (_dobController.text.isEmpty ||
            _dobController.text == oldUser?.dateOfBirth) {
          _dobController.text = newUser.dateOfBirth;
        }
        if (_genderController.text.isEmpty ||
            _genderController.text == oldUser?.gender) {
          _genderController.text = newUser.gender;
        }
        if (_addressController.text.isEmpty ||
            _addressController.text == oldUser?.address) {
          _addressController.text = newUser.address;
        }
      }
    });

    final state = ref.watch(personalInfoControllerProvider);
    final user = state.userInfo;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (state.isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _onSave,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: state.isLoading && user.fullName.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(personalInfoControllerProvider.notifier)
                      .loadProfile(forceRefresh: true);
                },
                color: const Color(0xFF8B5CF6),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    16.h,
                    20.w,
                    60.h + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Profile Header (Displays saved information) ---
                        Row(
                          children: [
                            Stack(
                              children: [
                                () {
                                  final profileImage = _getProfileImage(
                                    user.profileImageUrl,
                                  );
                                  return Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade200,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      image: profileImage != null
                                          ? DecorationImage(
                                              image: profileImage,
                                              fit: BoxFit.cover,
                                              onError: (_, __) {},
                                            )
                                          : null,
                                    ),
                                    child: profileImage == null
                                        ? Icon(
                                            Icons.person,
                                            color: Colors.grey.shade400,
                                            size: 34,
                                          )
                                        : null,
                                  );
                                }(),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF8B5CF6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName
                                        : 'User',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (user.phoneNumber.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      user.phoneNumber,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // --- Form Fields ---
                        CustomTextField(
                          label: 'Full Name',
                          controller: _fullNameController,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'Phone Number',
                          controller: _phoneNumberController,
                          icon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 20),

                        // Email field is disabled so it cannot be edited
                        CustomTextField(
                          label: 'Email Address',
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          enabled: false,
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'Date of Birth',
                          controller: _dobController,
                          icon: Icons.calendar_today_outlined,
                          isDropdown: true,
                          onTap: () => _selectDate(_dobController.text),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          key: _genderFieldKey,
                          child: CustomTextField(
                            label: 'Gender',
                            controller: _genderController,
                            icon: _getGenderIcon(_genderController.text),
                            isDropdown: true,
                            onTap: () => _selectGender(_genderController.text),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'Address',
                          controller: _addressController,
                          icon: Icons.location_on_outlined,
                          isMultiline: true,
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
