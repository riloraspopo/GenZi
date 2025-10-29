class SurveyQuestion {
  final String id;
  final String question;
  final List<String> options;
  String? selectedOption;

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.selectedOption,
  });

  factory SurveyQuestion.fromMap(Map<String, dynamic> map) {
    // Print the raw map data for debugging
    print('Converting map to SurveyQuestion: $map');

    // Safely extract options with type checking
    List<String> extractOptions(dynamic optionsData) {
      if (optionsData == null) return [];
      if (optionsData is! List) {
        print('Warning: options is not a List: ${optionsData.runtimeType}');
        return [];
      }
      return optionsData.map((option) => option?.toString() ?? '').toList();
    }

    // Extract and validate each field
    final id = map['\$id']?.toString() ?? '';
    final question = map['question']?.toString() ?? '';
    final options = extractOptions(map['options']);
    final selectedOption = map['selectedOption']?.toString();

    print('Processed fields:');
    print('id: $id');
    print('question: $question');
    print('options: $options');
    print('selectedOption: $selectedOption');

    return SurveyQuestion(
      id: id,
      question: question,
      options: options,
      selectedOption: selectedOption,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'selectedOption': selectedOption,
    };
  }
}
