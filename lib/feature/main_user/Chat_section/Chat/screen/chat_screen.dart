import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/controller/chat_controller.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/provider/chat_provider.dart';
import 'package:iwitnez/feature/main_user/Chat_section/Chat/widget/chat_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatProvider _provider = ChatProvider();
  final ChatController _controller = ChatController();

  @override
  void initState() {
    super.initState();
    _provider.fetchChats();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Text(
                AppString.chat,
                style: CustomTextStyle.bold30(AppColors.textDark)
                    .copyWith(fontSize: 24.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ChatSearchField(onChanged: _provider.search),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Recent',
                style: CustomTextStyle.regular16(AppColors.textDark)
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp),
              ),
            ),
            SizedBox(height: 4.h),
            Expanded(
              child: ListenableBuilder(
                listenable: _provider,
                builder: (context, _) {
                  if (_provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_provider.chats.isEmpty) {
                    return Center(
                      child: Text(
                        'No chats found',
                        style: CustomTextStyle.regular14(AppColors.textMuted),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w)
                        .copyWith(bottom: 12.h),
                    itemCount: _provider.chats.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 0.6,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final chat = _provider.chats[index];
                      return ChatTile(
                        entry: chat,
                        onTap: () =>
                            _controller.openChat(context, chat, _provider),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}