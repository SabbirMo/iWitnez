import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:iwitnez/core/network/error/api_error_handler.dart';
import 'package:iwitnez/core/utils/app_validator.dart';
import 'package:iwitnez/core/widgets/custom_snackbar.dart';
import 'package:iwitnez/feature/main_user/Profile_section/Profile/repository/profile_repository.dart';
import '../model/help_support_model.dart';
import '../repository/help_support_repository.dart';

class HelpSupportState {
  final int selectedTabIndex;
  final List<FaqModel> faqs;
  final ContactFormModel contactForm;
  final bool? _isLoadingFaqs;
  final bool? _isSubmitting;
  final int? _formResetKey;
  final int? expandedFaqIndex;

  bool get isLoadingFaqs => _isLoadingFaqs ?? false;
  bool get isSubmitting => _isSubmitting ?? false;
  int get formResetKey => _formResetKey ?? 0;

  HelpSupportState({
    this.selectedTabIndex = 0,
    required this.faqs,
    required this.contactForm,
    bool? isLoadingFaqs = false,
    bool? isSubmitting = false,
    int? formResetKey = 0,
    this.expandedFaqIndex,
  })  : _isLoadingFaqs = isLoadingFaqs ?? false,
        _isSubmitting = isSubmitting ?? false,
        _formResetKey = formResetKey ?? 0;

  HelpSupportState copyWith({
    int? selectedTabIndex,
    List<FaqModel>? faqs,
    ContactFormModel? contactForm,
    bool? isLoadingFaqs,
    bool? isSubmitting,
    int? formResetKey,
    int? expandedFaqIndex,
    bool clearExpanded = false,
  }) {
    return HelpSupportState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      faqs: faqs ?? this.faqs,
      contactForm: contactForm ?? this.contactForm,
      isLoadingFaqs: isLoadingFaqs ?? this.isLoadingFaqs,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      formResetKey: formResetKey ?? this.formResetKey,
      expandedFaqIndex:
          clearExpanded ? null : (expandedFaqIndex ?? this.expandedFaqIndex),
    );
  }
}

class HelpSupportController extends StateNotifier<HelpSupportState> {
  final HelpSupportRepository _repository;

  HelpSupportController([HelpSupportRepository? repository])
      : _repository = repository ?? HelpSupportRepository(),
        super(
          HelpSupportState(
            contactForm: ContactFormModel(
              email: _getInitialEmail(),
              problemDescription: '',
            ),
            faqs: const [],
          ),
        ) {
    loadFaqs();
  }

  static String _getInitialEmail() {
    try {
      return ProfileRepository().cachedProfile?.email ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> loadFaqs() async {
    state = state.copyWith(isLoadingFaqs: true);
    try {
      final faqs = await _repository.getFaqs();
      state = state.copyWith(
        faqs: faqs,
        isLoadingFaqs: false,
      );
    } catch (e) {
      debugPrint('[HelpSupportController] loadFaqs error: $e');
      state = state.copyWith(isLoadingFaqs: false);
    }
  }

  void toggleFaq(int index) {
    if (state.expandedFaqIndex == index) {
      state = state.copyWith(clearExpanded: true);
    } else {
      state = state.copyWith(expandedFaqIndex: index);
    }
  }

  void changeTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void updateEmail(String email) {
    state = state.copyWith(
      contactForm: state.contactForm.copyWith(email: email),
    );
  }

  void updateProblemDescription(String description) {
    state = state.copyWith(
      contactForm: state.contactForm.copyWith(problemDescription: description),
    );
  }

  Future<void> submitContactForm(BuildContext context) async {
    final email = state.contactForm.email.trim();
    final message = state.contactForm.problemDescription.trim();

    if (email.isEmpty) {
      CustomSnackBar.showError(
        context,
        message: 'Please enter your email address',
      );
      return;
    }

    final emailError = AppValidator.validateEmail(email);
    if (emailError != null) {
      CustomSnackBar.showError(
        context,
        message: emailError,
      );
      return;
    }

    if (message.isEmpty) {
      CustomSnackBar.showError(
        context,
        message: 'Please explain the problem',
      );
      return;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final successMsg = await _repository.submitContact(
        email: email,
        message: message,
      );
      state = state.copyWith(
        isSubmitting: false,
        formResetKey: state.formResetKey + 1,
        contactForm: state.contactForm.copyWith(problemDescription: ''),
      );
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context,
          message: successMsg ??
              'Your message has been sent to our safety support team. We will contact you shortly.',
        );
      }
    } catch (e) {
      final errorMsg = ApiErrorHandler.getMessage(e);
      state = state.copyWith(isSubmitting: false);
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          message: errorMsg,
        );
      }
    }
  }
}
