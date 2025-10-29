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
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(_dateFormatter.format(timestamp)),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: responses
                                        .map((response) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${responses.indexOf(response) + 1}.',
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          response['question'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 18),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          size: 18,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            response[
                                                                'response'],
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Tutup'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.assignment_outlined,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _dateFormatter.format(timestamp),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${responses.length} jawaban',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
