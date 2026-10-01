import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iwitnez/feature/main_user/SafetyTracking/model/safe_place_model.dart';

class AddSafePlaceBottomSheet extends StatefulWidget {
  final ValueChanged<SafePlaceModel> onSave;

  const AddSafePlaceBottomSheet({
    super.key,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<SafePlaceModel> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddSafePlaceBottomSheet(onSave: onSave),
    );
  }

  @override
  State<AddSafePlaceBottomSheet> createState() =>
      _AddSafePlaceBottomSheetState();
}

class _AddSafePlaceBottomSheetState extends State<AddSafePlaceBottomSheet> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  SafePlaceType _selectedType = SafePlaceType.other;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a place name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newPlace = SafePlaceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      address: address.isEmpty ? 'Custom Location' : address,
      isInside: false,
      type: _selectedType,
    );

    widget.onSave(newPlace);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Safe Place',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF6B7280),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Category Chips
            Text(
              'Select Category',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: SafePlaceType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.label),
                  avatar: Icon(
                    type.iconData,
                    size: 16.sp,
                    color: isSelected ? Colors.white : type.iconColor,
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF5B17B0),
                  backgroundColor: const Color(0xFFF3F4F6),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                        if (_nameController.text.isEmpty &&
                            type != SafePlaceType.other) {
                          _nameController.text = type.label;
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),

            // Place Name
            Text(
              'Place Name',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Gym, Library, Grandparents',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF5B17B0),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Address
            Text(
              'Address / Location',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'e.g. 742 Evergreen Terrace, NY',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: Color(0xFF5B17B0),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B17B0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Save Safe Place',
                  style: GoogleFonts.inter(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
