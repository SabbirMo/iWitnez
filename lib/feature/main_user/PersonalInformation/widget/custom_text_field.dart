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
  final bool enabled;
  final bool readOnly;

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
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: enabled
                ? (isDark ? const Color(0xFFD0D5DD) : Colors.grey[700])
                : (isDark ? const Color(0xFF667085) : Colors.grey[500]),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: (isDropdown && enabled) ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: IgnorePointer(
            ignoring: isDropdown || !enabled,
            child: TextFormField(
              controller: controller,
              initialValue: controller == null ? value : null,
              onChanged: onChanged,
              enabled: enabled,
              readOnly: readOnly || isDropdown || !enabled,
              textAlignVertical: isMultiline ? TextAlignVertical.top : null,
              keyboardType:
                  keyboardType ??
                  (isMultiline
                      ? TextInputType.multiline
                      : (label.toLowerCase().contains('phone')
                            ? TextInputType.phone
                            : (label.toLowerCase().contains('email')
                                  ? TextInputType.emailAddress
                                  : TextInputType.text))),
              maxLines: isMultiline ? 3 : 1,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: enabled
                      ? (isDark
                          ? const Color(0xFFA855F7)
                          : const Color(0xFF8B5CF6))
                      : (isDark
                          ? const Color(0xFFA855F7).withValues(alpha: 0.4)
                          : const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
                  size: 20,
                ),
                filled: true,
                fillColor: enabled
                    ? (isDark ? const Color(0xFF1F2232) : Colors.white)
                    : (isDark
                        ? const Color(0xFF161822)
                        : const Color(0xFFF3F4F6)),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF262938)
                        : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF2C3044)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF2C3044)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFFA855F7)
                        : const Color(0xFF8B5CF6),
                    width: 1.5,
                  ),
                ),
              ),
              style: TextStyle(
                fontSize: 14,
                color: enabled
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? const Color(0xFF98A2B3) : Colors.grey[600]),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
