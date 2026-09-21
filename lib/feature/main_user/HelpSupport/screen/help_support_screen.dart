import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../provider/help_support_provider.dart';
import '../widget/faq_card.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(helpSupportControllerProvider);
    final controller = ref.read(helpSupportControllerProvider.notifier);

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
            } else {
              context.go(AppRouteNames.mainUserHome);
            }
          },
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          
          // --- Custom Tab Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildTab(
                    context, 
                    title: 'FAQ Questions', 
                    index: 0, 
                    currentIndex: state.selectedTabIndex, 
                    onTap: () => controller.changeTab(0),
                  ),
                  _buildTab(
                    context, 
                    title: 'Contact Us', 
                    index: 1, 
                    currentIndex: state.selectedTabIndex, 
                    onTap: () => controller.changeTab(1),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // --- Tab Content ---
          Expanded(
            child: state.selectedTabIndex == 0
                ? _buildFaqList(state)
                : _buildContactUs(context, state, controller),
          ),
        ],
      ),
    );
  }

  // Helper widget for individual Tab Button
  Widget _buildTab(BuildContext context, {required String title, required int index, required int currentIndex, required VoidCallback onTap}) {
    final isSelected = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // FAQ List View
  Widget _buildFaqList(dynamic state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: state.faqs.length,
      itemBuilder: (context, index) {
        final faq = state.faqs[index];
        return FaqCard(
          question: faq.question,
          onTap: () {
            print('Tapped: ${faq.question}');
          },
        );
      },
    );
  }

  // --- NEW: Contact Us Form View ---
  Widget _buildContactUs(BuildContext context, dynamic state, dynamic controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field
          const Text(
            'Email Address',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.contactForm.email,
            onChanged: (val) => controller.updateEmail(val),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
          ),
          
          const SizedBox(height: 24),

          // Problem Field
          const Text(
            'Explain the problem',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: 6, // Makes it a large box
            onChanged: (val) => controller.updateProblemDescription(val),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Send Button
          _buildGradientButton(
            onTap: () {
              controller.submitContactForm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message Sent!')),
              );
            },
            text: 'Send',
            icon: Icons.send_rounded,
          ),
        ],
      ),
    );
  }

  // --- NEW: Gradient Button Helper ---
  Widget _buildGradientButton({required VoidCallback onTap, required String text, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          // Gradient from deep purple to vibrant blue
          gradient: const LinearGradient(
            colors: [Color(0xFF6B21A8), Color(0xFF2563EB)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30), // Pill shape
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B21A8).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}