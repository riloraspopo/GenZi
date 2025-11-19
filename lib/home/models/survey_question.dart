import 'package:flutter/foundation.dart';
import 'dart:convert';

enum QuestionType {
  singleChoice, // Pilihan ganda (satu jawaban)
  multipleChoice, // Pilihan ganda (banyak jawaban)
  text, // Isian text
}

class SurveyQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final Map<String, int>?
  optionScores; // Score untuk setiap option (null jika tidak ada scoring)
  final bool hasScore; // Apakah pertanyaan ini memiliki score

  // Untuk menyimpan jawaban
  String? selectedOption; // Untuk single choice
  List<String> selectedOptions; // Untuk multiple choice
  String? textAnswer; // Untuk text input

  SurveyQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    this.optionScores,
    this.hasScore = false,
    this.selectedOption,
    List<String>? selectedOptions,
    this.textAnswer,
  }) : selectedOptions = selectedOptions ?? [];

  // Get current score for this question
  int getCurrentScore() {
    if (!hasScore || optionScores == null) return 0;

    int score = 0;
    switch (type) {
      case QuestionType.singleChoice:
        if (selectedOption != null &&
            optionScores!.containsKey(selectedOption)) {
          score = optionScores![selectedOption]!;
        }
        break;
      case QuestionType.multipleChoice:
        for (var option in selectedOptions) {
          if (optionScores!.containsKey(option)) {
            score += optionScores![option]!;
          }
        }
        break;
      case QuestionType.text:
        // Text questions typically don't have scores
        break;
    }
    return score;
  }

  // Check if question is answered
  bool isAnswered() {
    switch (type) {
      case QuestionType.singleChoice:
        return selectedOption != null;
      case QuestionType.multipleChoice:
        return selectedOptions.isNotEmpty;
      case QuestionType.text:
        return textAnswer != null && textAnswer!.trim().isNotEmpty;
    }
  }

  factory SurveyQuestion.fromMap(Map<String, dynamic> map) {
    if (kDebugMode) {
      print('Converting map to SurveyQuestion: $map');
    }

    // Safely extract options with type checking
    List<String> extractOptions(dynamic optionsData) {
      if (optionsData == null) return [];
      if (optionsData is! List) {
        if (kDebugMode) {
          print('Warning: options is not a List: ${optionsData.runtimeType}');
        }
        return [];
      }
      return optionsData.map((option) => option?.toString() ?? '').toList();
    }

    // Extract option scores
    // Appwrite may return this as JSON string or Map object
    Map<String, int>? extractOptionScores(dynamic scoresData) {
      if (scoresData == null) return null;

      // If it's a JSON string, parse it first
      if (scoresData is String) {
        try {
          scoresData = jsonDecode(scoresData);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing optionScores JSON: $e');
          }
          return null;
        }
      }

      // Now handle as Map
      if (scoresData is! Map) return null;

      Map<String, int> scores = {};
      scoresData.forEach((key, value) {
        scores[key.toString()] = int.tryParse(value.toString()) ?? 0;
      });
      return scores;
    }

    // Extract question type
    QuestionType extractType(dynamic typeData) {
      if (typeData == null) {
        if (kDebugMode) {
          print('Warning: type is null, defaulting to singleChoice');
        }
        return QuestionType.singleChoice;
      }

      final typeStr = typeData.toString().toLowerCase().trim();

      if (kDebugMode) {
        print('Parsing type: "$typeStr"');
      }

      if (typeStr.contains('multiple')) {
        return QuestionType.multipleChoice;
      } else if (typeStr.contains('text')) {
        return QuestionType.text;
      } else if (typeStr.contains('single')) {
        return QuestionType.singleChoice;
      }

      // Default fallback
      switch (typeStr) {
        case 'multiplechoice':
        case 'multiple_choice':
        case 'multiple choice':
          return QuestionType.multipleChoice;
        case 'text':
        case 'textinput':
        case 'text_input':
          return QuestionType.text;
        case 'singlechoice':
        case 'single_choice':
        case 'single choice':
        default:
          return QuestionType.singleChoice;
      }
    }

    final id = map['\$id']?.toString() ?? '';
    final question = map['question']?.toString() ?? '';
    final type = extractType(map['type']);
    final options = extractOptions(map['options']);
    final optionScores = extractOptionScores(map['optionScores']);
    final hasScore = map['hasScore'] == true || optionScores != null;

    if (kDebugMode) {
      print('Processed fields:');
      print('id: $id');
      print('question: $question');
      print('type: $type (raw: ${map['type']})');
      print('options: $options (count: ${options.length})');
      print('optionScores: $optionScores');
      print('hasScore: $hasScore');
    }

    return SurveyQuestion(
      id: id,
      question: question,
      type: type,
      options: options,
      optionScores: optionScores,
      hasScore: hasScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'type': type.toString().split('.').last,
      'options': options,
      'optionScores': optionScores,
      'hasScore': hasScore,
      'selectedOption': selectedOption,
      'selectedOptions': selectedOptions,
      'textAnswer': textAnswer,
    };
  }
}
