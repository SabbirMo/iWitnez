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

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ChatProvider _provider = ChatProvider();
  final ChatController _controller = ChatController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _provider.fetchChats();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _provider.fetchChats(showLoading: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E15) : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Text(
                AppString.chat,
                style: CustomTextStyle.bold30(
                  isDark ? AppColors.white : AppColors.textDark,
                ).copyWith(fontSize: 24.sp),
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
                style: CustomTextStyle.regular16(
                  isDark ? AppColors.white : AppColors.textDark,
                ).copyWith(fontWeight: FontWeight.w700, fontSize: 13.sp),
              ),
            ),
            SizedBox(height: 4.h),
            Expanded(
              child: ListenableBuilder(
                listenable: _provider,
                builder: (context, _) {
                  if (_provider.isLoading && _provider.chats.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_provider.chats.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => _provider.fetchChats(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 120.h),
                          Center(
                            child: Text(
                              _provider.searchQuery.isNotEmpty
                                  ? 'No messages found for "${_provider.searchQuery}"'
                                  : 'No conversations found',
                              style: CustomTextStyle.regular14(
                                isDark
                                    ? AppColors.white.withValues(alpha: 0.6)
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => _provider.fetchChats(
                      search: _provider.searchQuery.isEmpty
                          ? null
                          : _provider.searchQuery,
                      showLoading: false,
                    ),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(
                        bottom: 68.h + MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: _provider.chats.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        thickness: 0.6,
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final chat = _provider.chats[index];
                        return ChatTile(
                          entry: chat,
                          onTap: () =>
                              _controller.openChat(context, chat, _provider),
                        );
                      },
                    ),
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
