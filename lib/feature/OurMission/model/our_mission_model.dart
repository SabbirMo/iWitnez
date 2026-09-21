class OurMissionModel {
  final String title;
  final String description;

  OurMissionModel({
    required this.title,
    required this.description,
  });

  OurMissionModel copyWith({
    String? title,
    String? description,
  }) {
    return OurMissionModel(
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}