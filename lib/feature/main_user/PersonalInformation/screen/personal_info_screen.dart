import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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

  ImageProvider _getProfileImage(String savedUrl) {
    if (_pickedImagePath != null && _pickedImagePath!.isNotEmpty) {
      final file = File(_pickedImagePath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    if (savedUrl.startsWith('http://') || savedUrl.startsWith('https://')) {
      return NetworkImage(savedUrl);
    }
    if (savedUrl.isNotEmpty) {
      final file = File(savedUrl);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return const NetworkImage('https://i.pravatar.cc/150?img=5');
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
        final monthIndex = monthNames.indexWhere((m) => monthStr.startsWith(m));
        final month = monthIndex != -1 ? monthIndex + 1 : 5;
        final year = int.tryParse(parts[2]) ?? 1998;
        initialDate = DateTime(year, month, day);
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

  void _onSave() {
    FocusScope.of(context).unfocus();
    final controller = ref.read(personalInfoControllerProvider.notifier);

    controller.updateUserInfo(
      fullName: _fullNameController.text,
      phoneNumber: _phoneNumberController.text,
      email: _emailController.text,
      dateOfBirth: _dobController.text,
      gender: _genderController.text,
      address: _addressController.text,
      profileImageUrl: _pickedImagePath,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Personal information saved successfully!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF8B5CF6),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
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
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(
                            image: _getProfileImage(user.profileImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.phoneNumber,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
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

              CustomTextField(
                label: 'Email Address',
                controller: _emailController,
                icon: Icons.email_outlined,
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
            ],
          ),
        ),
      ),
    );
  }
}
