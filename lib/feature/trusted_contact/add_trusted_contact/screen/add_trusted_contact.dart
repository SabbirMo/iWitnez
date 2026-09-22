import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iwitnez/core/constants/app_string/app_string.dart';
import 'package:iwitnez/core/constants/colors/app_colors.dart';
import 'package:iwitnez/core/constants/text_style/custom_text_style.dart';
import 'package:iwitnez/core/widgets/custom_button.dart';
import 'package:iwitnez/feature/onboarding/controller/start_animations.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/provider/add_trusted_contact_provider.dart';
import 'package:iwitnez/feature/trusted_contact/add_trusted_contact/widget/add_contact_widget.dart';
import 'package:iwitnez/router/app_route_names.dart';

class AddTrustedContactScreen extends ConsumerStatefulWidget {
  const AddTrustedContactScreen({super.key});

  @override
  ConsumerState<AddTrustedContactScreen> createState() =>
      _AddTrustedContactScreenState();
}

class _AddTrustedContactScreenState
    extends ConsumerState<AddTrustedContactScreen>
    with TickerProviderStateMixin {
  late final StartAnimations _animations = StartAnimations(this);

  @override
  void reassemble() {
    super.reassemble();
    _animations.reassemble();
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(trustedContactsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _animations.buttonTransition(
                child: Image.asset(
                  "assets/images/trusted.png",
                  height: 190.h,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 20.h),

              _animations.textTransition(
                child: Text(
                  AppString.addTrustedContactTitle,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.ibold32(AppColors.black),
                ),
              ),

              SizedBox(height: 8.h),

              _animations.taglineTransition(
                child: Text(
                  AppString.addTrustedContactDesc,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.regular14(AppColors.gray),
                ),
              ),

              SizedBox(height: 24.h),

              // If no contacts added yet: show initial Add Contact card and Skip
              if (contacts.isEmpty) ...[
                _animations.buttonTransition(
                  child: AddContactWidget(
                    title: "Add Contact",
                    subTitle: "required",
                    onTap: () {
                      ref.read(addTrustedContactProvider.notifier).resetForm();
                      context.push(AppRouteNames.addTrustedFieldWidget);
                    },
                    icon: Icons.arrow_forward_ios_rounded,
                    image: const Icon(
                      Icons.person_add,
                      color: AppColors.buttonGradientStart,
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                _animations.taglineTransition(
                  child: TextButton(
                    onPressed: () {
                      context.go(AppRouteNames.mainUserHome);
                    },
                    child: Text(
                      "Skip For Now",
                      style: CustomTextStyle.regular16(
                        AppColors.buttonGradientStart,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // When contacts exist: list of added contacts matching the screenshot
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contacts.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return TrustedContactCard(
                      contact: contact,
                      onEdit: () {
                        ref
                            .read(addTrustedContactProvider.notifier)
                            .setContact(contact);
                        context.push(
                          AppRouteNames.addTrustedFieldWidget,
                          extra: contact,
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: 12.h),

                // "+ Add Another Contact" dashed pill button
                AddAnotherContactWidget(
                  onTap: () {
                    ref.read(addTrustedContactProvider.notifier).resetForm();
                    context.push(AppRouteNames.addTrustedFieldWidget);
                  },
                ),

                SizedBox(height: 24.h),

                // "Continue ->" button
                CustomButton(
                  text: "Continue",
                  icon: Icons.person_add_alt_1_outlined,
                  isLeadingIcon: true,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onTap: () {
                    final latestContact =
                        contacts.isNotEmpty ? contacts.last.fullName : null;
                    context.go(
                      AppRouteNames.trustedContactSuccessScreen,
                      extra: latestContact,
                    );
                  },
                ),

                SizedBox(height: 20.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
