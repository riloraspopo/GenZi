class EducationalPoster {
  final String id;
  final String title;
  final String imageUrl;
  final String description;

  EducationalPoster({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
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