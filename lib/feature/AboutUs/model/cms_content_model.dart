class CmsSectionModel {
  final String heading;
  final String body;

  const CmsSectionModel({required this.heading, required this.body});

  factory CmsSectionModel.fromJson(Map<String, dynamic> json) {
    return CmsSectionModel(
      heading: json['heading']?.toString() ?? json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['content']?.toString() ?? '',
    );
  }
}

class CmsContentModel {
  final String title;
  final String subtitle;
  final String lastUpdated;
  final String content;
  final List<CmsSectionModel> sections;

  const CmsContentModel({
    required this.title,
    this.subtitle = '',
    this.lastUpdated = '',
    this.content = '',
    this.sections = const [],
  });

  factory CmsContentModel.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    final list = <CmsSectionModel>[];
    if (rawSections is List) {
      for (final item in rawSections) {
        if (item is Map<String, dynamic>) {
          list.add(CmsSectionModel.fromJson(item));
        }
      }
    }

    return CmsContentModel(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      lastUpdated: json['last_updated']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      sections: list,
    );
  }
}
