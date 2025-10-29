import 'package:flutter/material.dart';
import 'package:myapp/services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;
import 'package:intl/intl.dart';

class SurveyHistoryPage extends StatefulWidget {
  const SurveyHistoryPage({Key? key}) : super(key: key);

  @override
  _SurveyHistoryPageState createState() => _SurveyHistoryPageState();
}

class _SurveyHistoryPageState extends State<SurveyHistoryPage> {
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;
  models.User? _currentUser;
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _loadSurveyHistory();
  }

  Future<void> _loadSurveyHistory() async {
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

      // Load survey history
      final submissions =
          await AppwriteService.getUserSurveyHistory(_currentUser!.$id);
      if (mounted) {
        setState(() {
          _submissions = submissions;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading survey history: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Survei'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _submissions.isEmpty
              ? const Center(child: Text('Belum ada riwayat survei'))
              : RefreshIndicator(
                  onRefresh: _loadSurveyHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _submissions.length,
                    itemBuilder: (context, index) {
                      final submission = _submissions[index];
                      final responses = List<Map<String, dynamic>>.from(
                          submission['responses']);
                      final timestamp = DateTime.parse(submission['timestamp']);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Survei - ${_dateFormatter.format(timestamp)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  ...responses
                                      .map((response) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  response['question'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Jawaban: ${response['response']}',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
