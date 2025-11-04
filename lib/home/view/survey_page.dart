import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/home/models/survey_question.dart';
import 'package:myapp/services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;
import 'package:myapp/home/view/survey_history_page.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  SurveyPageState createState() => SurveyPageState();
}

class SurveyPageState extends State<SurveyPage> {
  List<SurveyQuestion> _questions = [];
  bool _isLoading = true;
  models.User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
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
      // Load survey questions
      final questionsData = await AppwriteService.getSurveyQuestions();
      if (kDebugMode) {
        print('Raw questions data: $questionsData');
      } // Debug log
      if (mounted) {
        setState(() {
          try {
            _questions = [];
            for (var data in questionsData) {
              try {
                if (kDebugMode) {
                  print('Processing question data: $data');
                } // Debug log
                final question = SurveyQuestion.fromMap(data);
                _questions.add(question);
              } catch (e, stackTrace) {
                if (kDebugMode) {
                  print('Error processing individual question: $e');
                  print('Stack trace: $stackTrace');
                }
                // Continue processing other questions
              }
            }
            if (kDebugMode) {
              print('Loaded ${_questions.length} questions successfully');
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
          print("disni");
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
    if (_questions.any((q) => q.selectedOption == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon jawab semua pertanyaan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Create a submission ID to group all responses together
      final submissionId = DateTime.now().millisecondsSinceEpoch.toString();

      // Submit each response with the same submission ID
      for (var question in _questions) {
        await AppwriteService.submitSurveyResponse(
          question.id,
          question.selectedOption!,
          _currentUser!.$id,
          question.question,
          submissionId,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Survei berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear responses
      setState(() {
        for (var question in _questions) {
          question.selectedOption = null;
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
                  await _loadQuestions(); // Reload questions after creating test data
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
                    } // Add debug print
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pertanyaan berhasil dibuat, memuat ulang data...',
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    // Add a small delay before reloading
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
                    Expanded(
                      child: SingleChildScrollView(
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
                              final question = _questions[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index + 1}. ${question.question}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ...question.options.map((option) {
                                        return RadioListTile<String>(
                                          title: Text(option),
                                          value: option,
                                          groupValue: question.selectedOption,
                                          onChanged: (value) {
                                            setState(() {
                                              question.selectedOption = value;
                                            });
                                          },
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            }),
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
                          minimumSize: const Size(
                            double.infinity,
                            48,
                          ), // Fixed height
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
