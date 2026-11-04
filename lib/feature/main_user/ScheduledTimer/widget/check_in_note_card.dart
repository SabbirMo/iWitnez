import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInNoteCard extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionSelected;
  final VoidCallback onChanged;

  const CheckInNoteCard({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.onSuggestionSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A26) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF262938) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Add a Note',
                style: GoogleFonts.inter(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '(Optional)',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFF98A2B3)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            "Add a note about where you're going or what you're doing.",
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 12.h),

          // Input field container
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2232) : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF262938)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2B1D45)
                            : const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: isDark
                            ? const Color(0xFFA855F7)
                            : const Color(0xFF8B5CF6),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        maxLength: 100,
                        maxLines: 2,
                        minLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          hintText: "e.g. Walking home, meeting someone",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF9CA3AF),
                          ),
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          isDense: true,
                          counterText: '',
                          contentPadding: EdgeInsets.only(top: 4.h),
                        ),
                        onChanged: (text) => onChanged(),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      return Text(
                        '${value.text.length}/100',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF9CA3AF),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Quick note suggestion chips
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: suggestions.map((suggestion) {
                    final isSelected = value.text.trim() == suggestion.trim();
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () => onSuggestionSelected(suggestion),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? const Color(0xFF2B1D45)
                                      : const Color(0xFFF3E8FF))
                                : (isDark
                                      ? const Color(0xFF1F2232)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                        ? const Color(0xFFA855F7)
                                        : const Color(0xFF8B5CF6))
                                  : (isDark
                                        ? const Color(0xFF262938)
                                        : const Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Text(
                            suggestion,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? (isDark
                                        ? const Color(0xFFA855F7)
                                        : const Color(0xFF7C3AED))
                                  : (isDark
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF4B5563)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
