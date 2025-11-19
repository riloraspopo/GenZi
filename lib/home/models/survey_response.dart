class SurveyResponse {
  final String id;
  final String userId;
  final String questionId;
  final String response; // For single choice or text
  final List<String> responses; // For multiple choice
  final DateTime timestamp;
  final String question; // The actual question text
  final String submissionId; // Group responses by submission
  final int? score; // Score for this response

  SurveyResponse({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.response,
    List<String>? responses,
    required this.timestamp,
    required this.question,
    required this.submissionId,
    this.score,
  }) : responses = responses ?? [];

  factory SurveyResponse.fromMap(Map<String, dynamic> map) {
    // Extract responses list
    List<String> extractResponses(dynamic responsesData) {
      if (responsesData == null) return [];
      if (responsesData is! List) return [];
      return responsesData.map((r) => r?.toString() ?? '').toList();
    }

    return SurveyResponse(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      questionId: map['questionId'] ?? '',
      response: map['response'] ?? '',
      responses: extractResponses(map['responses']),
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      question: map['question'] ?? '',
      submissionId: map['submissionId'] ?? '',
      score: map['score'] != null
          ? int.tryParse(map['score'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'questionId': questionId,
      'response': response,
      'responses': responses,
      'timestamp': timestamp.toIso8601String(),
      'question': question,
      'submissionId': submissionId,
      'score': score,
    };
  }
}
