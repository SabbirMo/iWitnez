import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? value;
  final TextEditingController? controller;
  final IconData icon;
  final bool isDropdown;
  final bool isMultiline;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    this.value,
    this.controller,
    required this.icon,
    this.isDropdown = false,
    this.isMultiline = false,
    this.onChanged,
    this.onTap,
    this.keyboardType,
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
              controller: controller,
              initialValue: controller == null ? value : null,
              onChanged: onChanged,
              keyboardType: keyboardType ??
                  (isMultiline
                      ? TextInputType.multiline
                      : (label.toLowerCase().contains('phone')
                          ? TextInputType.phone
                          : (label.toLowerCase().contains('email')
                              ? TextInputType.emailAddress
                              : TextInputType.text))),
              maxLines: isMultiline ? 3 : 1,
              readOnly: isDropdown,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
                suffixIcon: isDropdown
                    ? const Icon(Icons.keyboard_arrow_down, color: Colors.grey)
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
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