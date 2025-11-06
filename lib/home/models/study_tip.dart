class StudyTip {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  StudyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory StudyTip.fromJson(Map<String, dynamic> json) {
    return StudyTip(
      id: json['\$id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}