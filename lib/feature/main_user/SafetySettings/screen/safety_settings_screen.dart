import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/router/app_route_names.dart';
import '../provider/safety_settings_provider.dart';
import '../widget/settings_tile.dart';

class SafetySettingsScreen extends ConsumerWidget {
  const SafetySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetySettingsControllerProvider);
    final controller = ref.read(safetySettingsControllerProvider.notifier);

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
          'Safety Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Emergency Section ---
            _buildSectionTitle('Emergency'),
            _buildSectionContainer(
              children: [
                SettingsTile(
                  icon: Icons.sos,
                  title: 'SOS Alerts',
                  subtitle: 'Send SOS alert to your trusted circle',
                  trailing: Switch(
                    value: state.sosAlerts,
                    onChanged: (val) => controller.toggleSosAlerts(val),
                    activeColor: const Color(0xFF8B5CF6),
                  ),
                ),
                const Divider(height: 1, indent: 80, endIndent: 16),
                SettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Live Location Sharing',
                  subtitle: 'Share your live location during emergency',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    // Navigate to Live Location screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Safe Places Section ---
            _buildSectionTitle('Safe Places'),
            _buildSectionContainer(
              children: [
                SettingsTile(
                  icon: Icons.home_outlined,
                  title: 'Safe Places Alerts',
                  subtitle: 'Get notified when you arrive at or leave safe places',
                  trailing: Switch(
                    value: state.safePlacesAlerts,
                    onChanged: (val) => controller.toggleSafePlacesAlerts(val),
                    activeColor: const Color(0xFF8B5CF6),
                  ),
                ),
                const Divider(height: 1, indent: 80, endIndent: 16),
                SettingsTile(
                  icon: Icons.notifications_none,
                  title: 'Safe Place Suggestions',
                  subtitle: 'Get suggestions for nearby safe places',
                  trailing: Switch(
                    value: state.safePlaceSuggestions,
                    onChanged: (val) => controller.toggleSafePlaceSuggestions(val),
                    activeColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Other Section ---
            _buildSectionTitle('Other'),
            _buildSectionContainer(
              children: [
                SettingsTile(
                  icon: Icons.nightlight_round, // Moon icon
                  title: 'Do Not Disturb',
                  subtitle: 'Silence non-emergency notification',
                  trailing: Switch(
                    value: state.doNotDisturb,
                    onChanged: (val) => controller.toggleDoNotDisturb(val),
                    activeColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for Section Titles (e.g., "Emergency", "Safe Places")
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper widget for the white container background
  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: children,
      ),
    );
  }
}