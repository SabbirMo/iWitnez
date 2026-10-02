import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDropdown;
  final bool isMultiline;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isDropdown = false,
    this.isMultiline = false,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isDropdown ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: IgnorePointer(
            ignoring: isDropdown,
            child: TextFormField(
              key: ValueKey(value),
              initialValue: value,
              onChanged: onChanged,
              maxLines: isMultiline ? 3 : 1,
              readOnly: isDropdown,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
                suffixIcon: isDropdown
                    ? const Icon(Icons.keyboard_arrow_down, color: Colors.grey)
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF8B5CF6),
                    width: 1.5,
                  ),
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}