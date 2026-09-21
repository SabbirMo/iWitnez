import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class KeypadBottomSheet extends StatefulWidget {
  const KeypadBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const KeypadBottomSheet(),
    );
  }

  @override
  State<KeypadBottomSheet> createState() => _KeypadBottomSheetState();
}

class _KeypadBottomSheetState extends State<KeypadBottomSheet> {
  String _digits = '';

  static const List<Map<String, String>> _keys = [
    {'digit': '1', 'sub': ''},
    {'digit': '2', 'sub': 'ABC'},
    {'digit': '3', 'sub': 'DEF'},
    {'digit': '4', 'sub': 'GHI'},
    {'digit': '5', 'sub': 'JKL'},
    {'digit': '6', 'sub': 'MNO'},
    {'digit': '7', 'sub': 'PQRS'},
    {'digit': '8', 'sub': 'TUV'},
    {'digit': '9', 'sub': 'WXYZ'},
    {'digit': '*', 'sub': ''},
    {'digit': '0', 'sub': '+'},
    {'digit': '#', 'sub': ''},
  ];

  void _onKeyPress(String digit) {
    setState(() {
      _digits += digit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131835),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 36.h,
            child: Text(
              _digits.isEmpty ? ' ' : _digits,
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _keys.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final keyData = _keys[index];
              return InkWell(
                onTap: () => _onKeyPress(keyData['digit']!),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        keyData['digit']!,
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (keyData['sub']!.isNotEmpty)
                        Text(
                          keyData['sub']!,
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
