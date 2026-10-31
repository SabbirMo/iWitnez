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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: enabled ? Colors.grey[700] : Colors.grey[500],
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
                prefixIcon: isMultiline
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Icon(
                              icon,
                              color: enabled
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(
                                      0xFF8B5CF6,
                                    ).withValues(alpha: 0.4),
                              size: 20,
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        icon,
                        color: enabled
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                        size: 20,
                      ),

                filled: true,
                fillColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
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
              style: TextStyle(
                fontSize: 14,
                color: enabled ? Colors.black87 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
