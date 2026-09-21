import 'package:flutter_riverpod/legacy.dart';
import '../model/help_support_model.dart';

class HelpSupportState {
  final int selectedTabIndex;
  final List<FaqModel> faqs;
  final ContactFormModel contactForm; // NEW

  HelpSupportState({
    this.selectedTabIndex = 0,
    required this.faqs,
    required this.contactForm, // NEW
  });

  HelpSupportState copyWith({
    int? selectedTabIndex,
    List<FaqModel>? faqs,
    ContactFormModel? contactForm,
  }) {
    return HelpSupportState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      faqs: faqs ?? this.faqs,
      contactForm: contactForm ?? this.contactForm,
    );
  }
}

class HelpSupportController extends StateNotifier<HelpSupportState> {
  HelpSupportController()
    : super(
        HelpSupportState(
          contactForm: ContactFormModel(), // Initialize empty form
          faqs: [
            FaqModel(id: '1', question: 'How does SOS work?'),
            FaqModel(id: '2', question: 'How do I share my live location?'),
            FaqModel(
              id: '3',
              question: 'How can I add members to my trusted circle?',
            ),
            FaqModel(id: '4', question: 'Will my location always be shared?'),
            FaqModel(id: '5', question: 'Is my data secure?'),
            FaqModel(
              id: '6',
              question: 'How do I update my profile information?',
            ),
            FaqModel(id: '7', question: 'How do I log out of my account?'),
          ],
        ),
      );

  void changeTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  // NEW: Form Update Methods
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

  void submitContactForm() {
    // Logic to send data to backend goes here
    print('Sending Email: ${state.contactForm.email}');
    print('Problem: ${state.contactForm.problemDescription}');
  }
}
