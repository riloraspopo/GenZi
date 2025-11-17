class EducationalPoster {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final List<String> tags;

  EducationalPoster({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    this.tags = const [],
  });
}

class PdfResource {
  final String id;
  final String title;
  final String pdfUrl;
  final String thumbnailUrl;
  final String description;

  PdfResource({
    required this.id,
    required this.title,
    required this.pdfUrl,
    required this.thumbnailUrl,
    required this.description,
  });
}

class InformationItem {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;

  InformationItem({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
  });
}
