class SurveyResponse {
  final String id;
  final String userId;
  final String questionId;
  final String response;
  final DateTime timestamp;
  final String question; // The actual question text
  final String submissionId; // Group responses by submission

  SurveyResponse({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.response,
    required this.timestamp,
    required this.question,
    required this.submissionId,
  });

  factory SurveyResponse.fromMap(Map<String, dynamic> map) {
    return SurveyResponse(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      questionId: map['questionId'] ?? '',
      response: map['response'] ?? '',
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      question: map['question'] ?? '',
      submissionId: map['submissionId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'questionId': questionId,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
      'question': question,
      'submissionId': submissionId,
    };
  }
}
