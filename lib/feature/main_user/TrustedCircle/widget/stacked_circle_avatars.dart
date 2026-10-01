import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/feature/main_user/TrustedCircle/model/trusted_circle_model.dart';

class StackedCircleAvatars extends StatelessWidget {
  final TrustedCircleItem circle;
  final double avatarSize;
  final double overlap;

  const StackedCircleAvatars({
    super.key,
    required this.circle,
    this.avatarSize = 42.0,
    this.overlap = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final count = circle.avatars.length.clamp(1, 3);
    final totalWidth = avatarSize + (count - 1) * overlap + 10;

    return SizedBox(
      width: totalWidth.w,
      height: (avatarSize + 4).h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          for (int i = 0; i < count; i++)
            Positioned(
              left: (i * overlap).w,
              child: Container(
                width: avatarSize.r,
                height: avatarSize.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    circle.avatars[i],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1EDFF),
                      child: Icon(
                        Icons.person_rounded,
                        size: 22.sp,
                        color: const Color(0xFF6C4DF6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: ((count - 1) * overlap + 20).w,
            bottom: 0,
            child: Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                color: circle.badgeBg,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Icon(
                circle.badgeIcon,
                color: circle.badgeIconColor,
                size: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
