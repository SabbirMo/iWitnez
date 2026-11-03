import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/widgets/shimmer_loading.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../controller/help_support_controller.dart';
import '../provider/help_support_provider.dart';
import '../widget/faq_card.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(helpSupportControllerProvider);
    final controller = ref.read(helpSupportControllerProvider.notifier);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E15) : const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D0E15) : const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouteNames.mainUserHome);
            }
          },
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181A26) : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: isDark ? Border.all(color: const Color(0xFF262938)) : null,
              ),
              child: Row(
                children: [
                  _buildTab(
                    title: 'FAQ Questions',
                    index: 0,
                    currentIndex: state.selectedTabIndex,
                    onTap: () => controller.changeTab(0),
                    isDark: isDark,
                  ),
                  _buildTab(
                    title: 'Contact Us',
                    index: 1,
                    currentIndex: state.selectedTabIndex,
                    onTap: () => controller.changeTab(1),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: state.selectedTabIndex == 0
                ? _buildFaqList(state, controller)
                : _buildContactUs(context, state, controller, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
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
              color: isSelected
                  ? Colors.white
                  : (isDark ? const Color(0xFF98A2B3) : Colors.grey[700]),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqList(
    HelpSupportState state,
    HelpSupportController controller,
  ) {
    if (state.isLoadingFaqs && state.faqs.isEmpty) {
      return const HelpSupportShimmer();
    }

    if (state.faqs.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.loadFaqs,
        color: const Color(0xFF8B5CF6),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: const [
            Center(
              child: Text(
                'No FAQs available at the moment.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadFaqs,
      color: const Color(0xFF8B5CF6),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.faqs.length,
        itemBuilder: (context, index) {
          final faq = state.faqs[index];
          return FaqCard(
            question: faq.question,
            answer: faq.answer,
            isExpanded: state.expandedFaqIndex == index,
            onTap: () => controller.toggleFaq(index),
          );
        },
      ),
    );
  }

  Widget _buildContactUs(
    BuildContext context,
    HelpSupportState state,
    HelpSupportController controller, [
    bool isDark = false,
  ]) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Address',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.contactForm.email,
            keyboardType: TextInputType.emailAddress,
            enabled: !state.isSubmitting,
            onChanged: (val) => controller.updateEmail(val),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.email_outlined,
                color: isDark ? const Color(0xFF98A2B3) : Colors.grey,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF181A26) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF262938) : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF262938) : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Explain the problem',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey(state.formResetKey),
            initialValue: state.contactForm.problemDescription,
            maxLines: 6,
            enabled: !state.isSubmitting,
            onChanged: (val) => controller.updateProblemDescription(val),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Describe your issue in detail...',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF181A26) : Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF262938) : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF262938) : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildGradientButton(
            onTap: state.isSubmitting
                ? null
                : () => controller.submitContactForm(context),
            text: 'Send',
            icon: Icons.send_rounded,
            isLoading: state.isSubmitting,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onTap,
    required String text,
    required IconData icon,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B21A8), Color(0xFF2563EB)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B21A8).withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
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
      ),
    );
  }
}
