import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/personal_info_provider.dart';
import '../widget/custom_text_field.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final GlobalKey _genderFieldKey = GlobalKey();

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
      ref
          .read(personalInfoControllerProvider.notifier)
          .updateDateOfBirth(formatted);
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
      ref.read(personalInfoControllerProvider.notifier).updateGender(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(personalInfoControllerProvider);
    final controller = ref.read(personalInfoControllerProvider.notifier);
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
            onPressed: () {
              controller.saveChanges();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile Saved!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
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
              // --- Profile Header ---
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
                            image: NetworkImage(user.profileImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
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
                value: user.fullName,
                icon: Icons.person_outline,
                onChanged: (val) => controller.updateFullName(val),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Phone Number',
                value: user.phoneNumber,
                icon: Icons.phone_outlined,
                onChanged: (val) => controller.updatePhoneNumber(val),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Email Address',
                value: user.email,
                icon: Icons.email_outlined,
                onChanged: (val) => controller.updateEmail(val),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Date of Birth',
                value: user.dateOfBirth,
                icon: Icons.calendar_today_outlined,
                isDropdown: true,
                onTap: () => _selectDate(user.dateOfBirth),
              ),
              const SizedBox(height: 20),

              Container(
                key: _genderFieldKey,
                child: CustomTextField(
                  label: 'Gender',
                  value: user.gender,
                  icon: _getGenderIcon(user.gender),
                  isDropdown: true,
                  onTap: () => _selectGender(user.gender),
                ),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Address',
                value: user.address,
                icon: Icons.location_on_outlined,
                isMultiline: true,
                onChanged: (val) => controller.updateAddress(val),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
