import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/controller/calls_controller.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/provider/calls_provider.dart';
import 'package:iwitnez/feature/main_user/Calls_section/Calls/widget/calls_widget.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  final CallsProvider _provider = CallsProvider();
  final CallsController _controller = CallsController();

  @override
  void initState() {
    super.initState();
    _provider.fetchCalls();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // Title: Calls
              Text(
                AppString.calls,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),

              SizedBox(height: 16.h),

              // Search Call field
              CallSearchField(onChanged: _provider.search),

              SizedBox(height: 14.h),

              // All | Missed | Recent filter tabs
              ListenableBuilder(
                listenable: _provider,
                builder: (context, _) {
                  return CallFilterTabs(
                    currentTab: _provider.currentTab,
                    onTabSelected: _provider.setTab,
                  );
                },
              ),

              SizedBox(height: 14.h),

              // Call logs list
              Expanded(
                child: ListenableBuilder(
                  listenable: _provider,
                  builder: (context, _) {
                    if (_provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final calls = _provider.calls;
                    if (calls.isEmpty) {
                      return Center(
                        child: Text(
                          'No calls found',
                          style: CustomTextStyle.regular14(AppColors.textMuted),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemCount: calls.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey.shade100,
                      ),
                      itemBuilder: (context, index) {
                        final call = calls[index];
                        return CallLogTile(
                          entry: call,
                          onTap: () =>
                              _controller.openCallDetail(context, call),
                          onVoiceCall: () =>
                              _controller.startVoiceCall(context, call),
                          onVideoCall: () =>
                              _controller.startVideoCall(context, call),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}