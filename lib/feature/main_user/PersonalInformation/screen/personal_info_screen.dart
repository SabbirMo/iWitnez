import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/personal_info_provider.dart';
import '../widget/custom_text_field.dart';

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(personalInfoControllerProvider);
    final controller = ref.read(personalInfoControllerProvider.notifier);
    final user = state.userInfo;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
                const SnackBar(content: Text('Profile Saved!')),
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF8B5CF6), // Purple
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
                color: Colors.grey.withOpacity(0.05),
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
                            color: Color(0xFF8B5CF6), // Purple
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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
                // In a real app, onTap would open a DatePicker
                onChanged: (val) {}, 
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Gender',
                value: user.gender,
                icon: Icons.female, // Using female icon as in design
                isDropdown: true,
                onChanged: (val) {},
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