import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide RadioGroup;
import 'package:myapp/home/models/survey_question.dart';
import 'package:myapp/services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;
import 'package:myapp/home/view/survey_history_page.dart';
import 'package:myapp/home/widgets/radio_group.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  SurveyPageState createState() => SurveyPageState();
}

class SurveyPageState extends State<SurveyPage> {
  List<SurveyQuestion> _questions = [];
  bool _isLoading = true;
  models.User? _currentUser;
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, GlobalKey> _questionKeys = {};
  final ScrollController _scrollController = ScrollController();
  String? _highlightedQuestionId;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  // Calculate total current score
  int _getTotalScore() {
    return _questions.fold(
      0,
      (sum, question) => sum + question.getCurrentScore(),
    );
  }

  // Get maximum possible score
  int _getMaxScore() {
    int maxScore = 0;
    for (var question in _questions) {
      if (question.hasScore && question.optionScores != null) {
        // Find max score for this question
        int questionMax = 0;
        for (var score in question.optionScores!.values) {
          if (question.type == QuestionType.multipleChoice) {
            // For multiple choice, sum all positive scores
            if (score > 0) questionMax += score;
          } else {
            // For single choice, get the highest score
            if (score > questionMax) questionMax = score;
          }
        }
        maxScore += questionMax;
      }
    }
    return maxScore;
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      // Get current user
      _currentUser = await AppwriteService.getCurrentUser();
      if (_currentUser == null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      // ===== GET QUESTIONS FROM APPWRITE SERVER =====
      // Fetch all survey questions from Appwrite database
      // This includes question text, type, options, and score mappings
      final questionsData = await AppwriteService.getSurveyQuestions();
      if (kDebugMode) {
        print(
          '📥 Loaded ${questionsData.length} questions from Appwrite server',
        );
        print('Raw questions data: $questionsData');
      }
      if (mounted) {
        setState(() {
          try {
            _questions = [];
            // Dispose old controllers
            for (var controller in _textControllers.values) {
              controller.dispose();
            }
            _textControllers.clear();
            _questionKeys.clear();

            for (var data in questionsData) {
              try {
                if (kDebugMode) {
                  print('Processing question data: $data');
                }
                final question = SurveyQuestion.fromMap(data);
                _questions.add(question);

                // Create text controller for text questions
                if (question.type == QuestionType.text) {
                  _textControllers[question.id] = TextEditingController();
                }

                // Create GlobalKey for scrolling
                _questionKeys[question.id] = GlobalKey();
              } catch (e, stackTrace) {
                if (kDebugMode) {
                  print('Error processing individual question: $e');
                  print('Stack trace: $stackTrace');
                }
              }
            }
            if (kDebugMode) {
              print(
                '✅ Successfully loaded ${_questions.length} questions from server',
              );
              print('Questions breakdown:');
              for (var q in _questions) {
                print('  - ${q.question} (${q.type}, hasScore: ${q.hasScore})');
              }
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              print('Error mapping questions: $e');
              print('Stack trace: $stackTrace');
            }
            _questions = [];
            rethrow;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        if (kDebugMode) {
          print("Error: $e");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading questions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitSurvey() async {
    // Check if all questions are answered
    SurveyQuestion? firstUnanswered;
    for (var q in _questions) {
      if (!q.isAnswered()) {
        firstUnanswered = q;
        break;
      }
    }

    if (firstUnanswered != null) {
      // Highlight the unanswered question
      setState(() {
        _highlightedQuestionId = firstUnanswered!.id;
      });

      // Scroll to the unanswered question
      final key = _questionKeys[firstUnanswered.id];
      if (key?.currentContext != null) {
        await Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Mohon jawab semua pertanyaan yang ditandai'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      // Remove highlight after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _highlightedQuestionId = null;
          });
        }
      });

      return;
    }

    setState(() => _isLoading = true);
    try {
      final submissionId = DateTime.now().millisecondsSinceEpoch.toString();

      // ===== SAVE RESPONSES TO APPWRITE SERVER =====
      // Submit each response with:
      // - Single/Multiple choice answers
      // - Text input answers
      // - Calculated scores (if applicable)
      // - Submission ID to group all responses together
      for (var question in _questions) {
        String response = '';
        List<String> responses = [];
        int? score = question.hasScore ? question.getCurrentScore() : null;

        switch (question.type) {
          case QuestionType.singleChoice:
            response = question.selectedOption ?? '';
            break;
          case QuestionType.multipleChoice:
            responses = question.selectedOptions;
            response = responses.join(', ');
            break;
          case QuestionType.text:
            response = question.textAnswer ?? '';
            break;
        }

        // Submit to Appwrite server
        await AppwriteService.submitSurveyResponse(
          question.id,
          response,
          _currentUser!.$id,
          question.question,
          submissionId,
          responses: responses.isNotEmpty ? responses : null,
          score: score,
        );

        if (kDebugMode) {
          print(
            '📤 Saved response to Appwrite: ${question.question.substring(0, 30)}... (score: $score)',
          );
        }
      }

      if (!mounted) return;

      // Show success message with final score and status
      final totalScore = _getTotalScore();
      final maxScore = _getMaxScore();

      String message = 'Survei berhasil disimpan';
      Color snackbarColor = Colors.green;

      if (maxScore > 0) {
        if (totalScore == 0) {
          message += '\n✅ Status: AMAN (Skor: $totalScore)';
          snackbarColor = Colors.green;
        } else if (totalScore <= 3) {
          message += '\n⚠️ Status: WASPADA (Skor: $totalScore)';
          snackbarColor = Colors.orange;
        } else {
          message += '\n🚨 Status: BAHAYA (Skor: $totalScore)';
          snackbarColor = Colors.red;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: snackbarColor,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);

      // Clear responses
      setState(() {
        for (var question in _questions) {
          question.selectedOption = null;
          question.selectedOptions.clear();
          question.textAnswer = null;
          if (_textControllers.containsKey(question.id)) {
            _textControllers[question.id]!.clear();
          }
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting survey: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildQuestionCard(SurveyQuestion question, int index) {
    // Debug: Log question type
    if (kDebugMode) {
      print(
        'Building question ${index + 1}: type=${question.type}, hasOptions=${question.options.isNotEmpty}',
      );
    }

    final isHighlighted = _highlightedQuestionId == question.id;
    final isUnanswered = !question.isAnswered();

    return Container(
      key: _questionKeys[question.id],
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: isHighlighted ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isHighlighted
                ? Colors.red
                : isUnanswered
                ? Colors.red.withOpacity(0.3)
                : Colors.transparent,
            width: isHighlighted ? 3 : 1,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isHighlighted ? Colors.red.shade50 : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question header with score badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${index + 1}. ${question.question}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (question.hasScore) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: question.getCurrentScore() > 0
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: question.getCurrentScore() > 0
                                ? Colors.green
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: Text(
                          '${question.getCurrentScore()} poin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: question.getCurrentScore() > 0
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Question type indicator
                Row(
                  children: [
                    Text(
                      _getQuestionTypeLabel(question.type),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (isUnanswered && isHighlighted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 12,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Belum dijawab',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Question input based on type
                _buildQuestionInput(question),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getQuestionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
        return 'Pilih satu jawaban';
      case QuestionType.multipleChoice:
        return 'Pilih satu atau lebih jawaban';
      case QuestionType.text:
        return 'Isian teks';
    }
  }

  Widget _buildQuestionInput(SurveyQuestion question) {
    if (kDebugMode) {
      print(
        'Building input for type: ${question.type}, options count: ${question.options.length}',
      );
    }

    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoice(question);
      case QuestionType.multipleChoice:
        return _buildMultipleChoice(question);
      case QuestionType.text:
        return _buildTextInput(question);
    }
  }

  Widget _buildSingleChoice(SurveyQuestion question) {
    // Handle empty options
    if (question.options.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Tidak ada pilihan tersedia',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return RadioGroup<String>(
      value: question.selectedOption,
      onChanged: (value) {
        setState(() {
          question.selectedOption = value;
        });
      },
      children: question.options.map((option) {
        final isSelected = question.selectedOption == option;
        final score = question.optionScores?[option];

        return RadioItem<String>(
          value: option,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (score != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (score == 0
                              ? Colors.green.shade100
                              : score <= 3
                              ? Colors.orange.shade100
                              : Colors.red.shade100)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (score == 0
                                ? Colors.green.shade700
                                : score <= 3
                                ? Colors.orange.shade700
                                : Colors.red.shade700)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoice(SurveyQuestion question) {
    // Handle empty options
    if (question.options.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Tidak ada pilihan tersedia',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      children: question.options.map((option) {
        final isSelected = question.selectedOptions.contains(option);
        final score = question.optionScores?[option];

        return CheckboxListTile(
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                question.selectedOptions.add(option);
              } else {
                question.selectedOptions.remove(option);
              }
            });
          },
          title: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (score != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (score == 0
                              ? Colors.green.shade100
                              : score <= 3
                              ? Colors.orange.shade100
                              : Colors.red.shade100)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (score == 0
                                ? Colors.green.shade700
                                : score <= 3
                                ? Colors.orange.shade700
                                : Colors.red.shade700)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(SurveyQuestion question) {
    final controller = _textControllers[question.id];
    if (controller == null) {
      return const Text('Error: Controller not found');
    }

    return TextField(
      controller: controller,
      onChanged: (value) {
        setState(() {
          question.textAnswer = value;
        });
      },
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Ketik jawaban Anda di sini...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildScoreCard() {
    final totalScore = _getTotalScore();
    final maxScore = _getMaxScore();

    if (maxScore == 0) {
      return const SizedBox.shrink();
    }

    // Determine status based on total score
    // 0 = Aman (Hijau), 1-3 = Waspada (Kuning), >3 = Bahaya (Merah)
    String status;
    Color bgColor;
    Color bgColorLight;

    if (totalScore == 0) {
      status = 'Aman';
      bgColor = Colors.green.shade600;
      bgColorLight = Colors.green.shade400;
    } else if (totalScore >= 1 && totalScore <= 3) {
      status = 'Waspada';
      bgColor = Colors.orange.shade600;
      bgColorLight = Colors.orange.shade400;
    } else {
      status = 'Bahaya';
      bgColor = Colors.red.shade600;
      bgColorLight = Colors.red.shade400;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Risiko',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      totalScore == 0
                          ? Icons.check_circle
                          : totalScore <= 3
                          ? Icons.warning
                          : Icons.dangerous,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Skor: $totalScore dari $maxScore',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  '$totalScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalScore == 0
                      ? 'Sehat'
                      : totalScore <= 3
                      ? 'Periksa'
                      : 'Segera!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survei Guru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SurveyHistoryPage(),
                ),
              );
            },
            tooltip: 'Riwayat Survei',
          ),
          // Debug button to create test questions
          if (const bool.fromEnvironment('dart.vm.product') == false)
            IconButton(
              icon: const Icon(Icons.add_chart),
              onPressed: () async {
                try {
                  setState(() => _isLoading = true);
                  await AppwriteService.createTestSurveyQuestions();
                  await _loadQuestions();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Berhasil membuat pertanyaan test'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    if (kDebugMode) {
                      print('Error detail: $e');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pertanyaan berhasil dibuat, memuat ulang data...',
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await Future.delayed(const Duration(seconds: 2));
                    await _loadQuestions();
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              tooltip: 'Buat Pertanyaan Test',
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _questions.isEmpty
            ? const Center(child: Text('Tidak ada pertanyaan survei'))
            : Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Score card (shown only if there are questions with scores)
                    if (_getMaxScore() > 0) ...[
                      _buildScoreCard(),
                      const SizedBox(height: 16),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Mohon jawab semua pertanyaan di bawah ini:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...List.generate(_questions.length, (index) {
                              return _buildQuestionCard(
                                _questions[index],
                                index,
                              );
                            }),
                            const SizedBox(height: 80), // Space for button
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitSurvey,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Kirim Survei',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
