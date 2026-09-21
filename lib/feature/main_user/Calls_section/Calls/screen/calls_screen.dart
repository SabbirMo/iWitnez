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
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppString.calls,
                    style: CustomTextStyle.bold30(AppColors.textDark)
                        .copyWith(fontSize: 24.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    AppString.mainUser,
                    style: CustomTextStyle.regular14(AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CallSearchField(onChanged: _provider.search),
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
            SizedBox(height: 8.h),
            Expanded(
              child: ListenableBuilder(
                listenable: _provider,
                builder: (context, _) {
                  if (_provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_provider.calls.isEmpty) {
                    return Center(
                      child: Text(
                        'No calls found',
                        style: CustomTextStyle.regular14(AppColors.textMuted),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w)
                        .copyWith(bottom: 12.h),
                    itemCount: _provider.calls.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 0.6,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final call = _provider.calls[index];
                      return CallLogTile(
                        entry: call,
                        onTap: () => _controller.openCallDetail(context, call),
                        onCallBack: () => _controller.callBack(context, call),
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