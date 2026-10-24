import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/call/controller/call_flow_controller.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/model/chat_message_model.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/provider/chat_details_provider.dart';
import 'package:iwitnez/feature/main_user/Chat_section/ChatDetails/repository/chat_details_repository.dart';
import 'package:iwitnez/router/app_route_names.dart';

class ChatDetailsController {
  ChatDetailsController();

  void openProfileDetails(
    BuildContext context, {
    required String name,
    required String avatarUrl,
    bool isOnline = true,
    String relationship = 'Sister',
    String trustedCircle = 'Family',
  }) {
    context.push(
      AppRouteNames.chatProfileDetailsScreen,
      extra: {
        'name': name,
        'contactName': name,
        'avatarUrl': avatarUrl,
        'isOnline': isOnline,
        'relationship': relationship,
        'trustedCircle': trustedCircle,
      },
    );
  }

  void startVoiceCall(
    BuildContext context,
    String contactName, [
    String? avatarUrl,
  ]) {
    CallFlowController.startAudioCall(
      context,
      name: contactName,
      avatarUrl: avatarUrl ?? 'https://i.pravatar.cc/150?img=5',
    );
  }

  void startVideoCall(
    BuildContext context,
    String contactName, [
    String? avatarUrl,
  ]) {
    CallFlowController.startVideoCall(
      context,
      name: contactName,
      avatarUrl: avatarUrl ?? 'https://i.pravatar.cc/150?img=5',
    );
  }

  void openLiveLocation(BuildContext context, [ChatMessage? message]) {
    context.push(AppRouteNames.liveLocationScreen);
  }

  /// 4. Starting a New Direct Chat from Contact Profile:
  /// Endpoint: `POST /api/v1/chat/conversations/direct/<target_user_id>/`
  Future<void> startOrOpenDirectChat(
    BuildContext context, {
    required String targetUserId,
    required String contactName,
    required String avatarUrl,
    bool isOnline = false,
  }) async {
    final repo = ChatDetailsRepository();
    final conversation = await repo.startDirectChat(targetUserId);

    final chatId = conversation?.id.isNotEmpty == true
        ? conversation!.id
        : targetUserId;
    final name = conversation?.name.isNotEmpty == true
        ? conversation!.name
        : contactName;
    final avatar = conversation?.avatarUrl.isNotEmpty == true
        ? conversation!.avatarUrl
        : avatarUrl;
    final online = conversation?.isOnline ?? isOnline;

    if (context.mounted) {
      context.push(
        AppRouteNames.chatDetailsScreen,
        extra: {
          'chatId': chatId,
          'contactName': name,
          'avatarUrl': avatar,
          'isOnline': online,
        },
      );
    }
  }

  /// Displays attachment picker with options: Live Location, Gallery, Camera
  Future<void> pickAttachment(
    BuildContext context,
    ChatDetailsProvider provider,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                ListTile(
                  leading: Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDE9FE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: const Color(0xFF6C4DF6),
                      size: 22.sp,
                    ),
                  ),
                  title: Text(
                    'Share Live Location Pin',
                    style: CustomTextStyle.regular16(AppColors.textDark)
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                  ),
                  subtitle: Text(
                    'Share your current GPS location in chat',
                    style: CustomTextStyle.regular14(AppColors.textMuted)
                        .copyWith(fontSize: 12.sp),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    provider.shareLiveLocation();
                  },
                ),
                Divider(height: 16.h, thickness: 0.6, color: Colors.grey.shade200),
                ListTile(
                  leading: Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: const Color(0xFF2563EB),
                      size: 22.sp,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: CustomTextStyle.regular16(AppColors.textDark)
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _pickFromGallery(provider);
                  },
                ),
                Divider(height: 16.h, thickness: 0.6, color: Colors.grey.shade200),
                ListTile(
                  leading: Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: const Color(0xFF10B981),
                      size: 22.sp,
                    ),
                  ),
                  title: Text(
                    'Take a Photo',
                    style: CustomTextStyle.regular16(AppColors.textDark)
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp),
                  ),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _pickFromCamera(provider);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery(ChatDetailsProvider provider) async {
    try {
      final ImagePicker picker = ImagePicker();
      List<XFile> files = [];
      try {
        files = await picker.pickMultiImage(imageQuality: 85);
      } catch (_) {
        final single = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (single != null) files = [single];
      }

      if (files.isNotEmpty) {
        for (final file in files) {
          provider.sendImage(file.path);
        }
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
    }
  }

  Future<void> _pickFromCamera(ChatDetailsProvider provider) async {
    try {
      final ImagePicker picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        provider.sendImage(photo.path);
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
  }
}