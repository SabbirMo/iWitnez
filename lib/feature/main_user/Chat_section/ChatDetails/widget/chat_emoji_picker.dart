import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable and lightweight Emoji Picker widget for Chat
class ChatEmojiPicker extends StatelessWidget {
  const ChatEmojiPicker({super.key, required this.controller, this.height});

  final TextEditingController controller;
  final double? height;

  static const Color _kAccentPurple = Color(0xFF6C4DF6);

  @override
  Widget build(BuildContext context) {
    final pickerHeight = height ?? 260.h;

    return SizedBox(
      height: pickerHeight,
      child: EmojiPicker(
        textEditingController: controller,
        config: Config(
          height: pickerHeight,
          // Set to false to avoid native platform channel calls that cause crashes or blank screen
          checkPlatformCompatibility: false,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax:
                28 *
                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                    ? 1.2
                    : 1.0),
            backgroundColor: Colors.white,
          ),
          categoryViewConfig: const CategoryViewConfig(
            recentTabBehavior: RecentTabBehavior.NONE,
            backgroundColor: Color(0xFFF9FAFB),
            indicatorColor: _kAccentPurple,
            iconColorSelected: _kAccentPurple,
            backspaceColor: Color(0xFF6B7280),
          ),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
          searchViewConfig: const SearchViewConfig(
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
