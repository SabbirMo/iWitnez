import 'package:flutter/material.dart';

class AboutMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AboutMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon Box
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2B1D45)
                    : const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDark ? const Color(0xFFA855F7) : const Color(0xFF8B5CF6),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            // Trailing Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? const Color(0xFF98A2B3) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
