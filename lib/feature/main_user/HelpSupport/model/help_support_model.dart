class FaqModel {
  final String id;
  final String question;

  FaqModel({
    required this.id,
    required this.question,
  });
}

// NEW: Model for Contact Us form data
class ContactFormModel {
  final String email;
  final String problemDescription;

  ContactFormModel({
    this.email = 'xyz@gmail.com', // Pre-filled as per design
    this.problemDescription = '',
  });

  ContactFormModel copyWith({
    String? email,
    String? problemDescription,
  }) {
    return ContactFormModel(
      email: email ?? this.email,
      problemDescription: problemDescription ?? this.problemDescription,
    );
  }
}