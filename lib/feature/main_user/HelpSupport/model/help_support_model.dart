class FaqModel {
  final int id;
  final String question;
  final String answer;
  final String category;
  final int order;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    this.category = '',
    this.order = 0,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json, [int fallbackId = 0]) {
    final rawId = json['id'];
    int parsedId = fallbackId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString()) ?? fallbackId;
    }

    return FaqModel(
      id: parsedId != 0 ? parsedId : fallbackId,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String? ?? '',
      order: json['order'] is int
          ? json['order']
          : int.tryParse(json['order']?.toString() ?? '0') ?? 0,
    );
  }

  FaqModel copyWith({
    int? id,
    String? question,
    String? answer,
    String? category,
    int? order,
  }) {
    return FaqModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
    );
  }
}

class ContactFormModel {
  final String email;
  final String problemDescription;

  ContactFormModel({
    this.email = '',
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
