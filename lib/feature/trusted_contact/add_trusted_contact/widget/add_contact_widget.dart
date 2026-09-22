import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/model/trusted_contact_model.dart';

/// Initial card on AddTrustedContactScreen when no contacts added yet
class AddContactWidget extends StatelessWidget {
  const AddContactWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    this.onTap,
    required this.icon,
  });

  final Widget image;
  final String title;
  final String subTitle;
  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50.r),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              foregroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: image,
            ),
            SizedBox(width: 10.w),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CustomTextStyle.regular14(AppColors.black)),
                Text(
                  subTitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.buttonPrimaryLight,
                  ),
                ),
              ],
            ),
            const Spacer(),

            Icon(icon, color: AppColors.buttonGradientStart),
          ],
        ),
      ),
    );
  }
}

/// Custom toggle switch matching the UI screenshot design
class CustomSwitchButton extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 46.w,
        height: 26.h,
        padding: EdgeInsets.all(3.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: const Color(0xFFE5E7EB),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? AppColors.buttonGradientStart
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }
}

/// Notification preference card with purple bell, title, and custom toggle switch
class NotificationPreferenceWidget extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const NotificationPreferenceWidget({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isEnabled),
      borderRadius: BorderRadius.circular(50.r),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: AppColors.gray.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: AppColors.buttonGradientStart,
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "Emergency alerts",
                style: CustomTextStyle.regular14(AppColors.black).copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            CustomSwitchButton(
              value: isEnabled,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// Relationship dropdown selector field
class RelationshipFieldWidget extends StatelessWidget {
  final String selectedRelationship;
  final ValueChanged<String> onRelationshipChanged;

  const RelationshipFieldWidget({
    super.key,
    required this.selectedRelationship,
    required this.onRelationshipChanged,
  });

  static const List<String> relationships = [
    'Sister',
    'Brother',
    'Mother',
    'Father',
    'Friend',
    'Partner',
    'Spouse',
    'Son',
    'Daughter',
    'Other',
  ];

  void _showRelationshipPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Relationship",
                      style: CustomTextStyle.semiBold14(AppColors.black)
                          .copyWith(fontSize: 16.sp),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: relationships.length,
                  itemBuilder: (context, index) {
                    final item = relationships[index];
                    final isSelected = item.toLowerCase() ==
                        selectedRelationship.toLowerCase();
                    return ListTile(
                      title: Text(
                        item,
                        style: CustomTextStyle.regular14(
                          isSelected
                              ? AppColors.buttonGradientStart
                              : AppColors.black,
                        ).copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.buttonGradientStart,
                            )
                          : null,
                      onTap: () {
                        onRelationshipChanged(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showRelationshipPicker(context),
      borderRadius: BorderRadius.circular(50.r),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: AppColors.gray.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.people_outline_rounded,
              color: AppColors.buttonGradientStart,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                selectedRelationship.isEmpty ? "Sister" : selectedRelationship,
                style: CustomTextStyle.regular14(
                  selectedRelationship.isEmpty
                      ? AppColors.gray.withValues(alpha: 0.5)
                      : AppColors.black,
                ).copyWith(
                  fontWeight: selectedRelationship.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable avatar widget for trusted contacts that handles File, Network, or Placeholder
class ContactAvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final double radius;

  const ContactAvatarWidget({
    super.key,
    required this.avatarUrl,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius.r,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: SizedBox(
          width: radius * 2.r,
          height: radius * 2.r,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http')) {
        return Image.network(
          avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
        );
      } else {
        final file = File(avatarUrl!);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
          );
        }
      }
    }
    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return Icon(
      Icons.person,
      size: (radius * 1.1).sp,
      color: AppColors.buttonGradientStart.withValues(alpha: 0.7),
    );
  }
}

/// Pill card displaying a saved trusted contact (Photo, Name, Phone, Edit icon)
class TrustedContactCard extends StatelessWidget {
  final TrustedContactModel contact;
  final VoidCallback? onEdit;

  const TrustedContactCard({
    super.key,
    required this.contact,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.r),
        border: Border.all(
          color: AppColors.fieldColor.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ContactAvatarWidget(
            avatarUrl: contact.avatarUrl,
            radius: 20,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contact.fullName,
                  style: CustomTextStyle.regular14(AppColors.black).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  contact.phoneNumber,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.onboardingDesc,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/svg/edit.svg',
              width: 18.w,
              height: 18.w,
              colorFilter: const ColorFilter.mode(
                AppColors.buttonGradientStart,
                BlendMode.srcIn,
              ),
            ),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

/// Dashed pill button for "+ Add Another Contact"
class AddAnotherContactWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const AddAnotherContactWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50.r),
      child: CustomPaint(
        painter: DashedPillPainter(
          color: Colors.grey.shade400,
          strokeWidth: 1.2,
          dash: 5,
          gap: 4,
          radius: Radius.circular(50.r),
        ),
        child: Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.onboardingDesc,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Add Another Contact",
                style: CustomTextStyle.regular14(AppColors.onboardingDesc).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painter for drawing dashed rounded border
class DashedPillPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dash;
  final double gap;
  final Radius radius;

  DashedPillPainter({
    required this.color,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        radius,
      ));

    final Path dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length =
            (distance + dash < metric.length) ? dash : metric.length - distance;
        dashedPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedPillPainter oldDelegate) => false;
}
