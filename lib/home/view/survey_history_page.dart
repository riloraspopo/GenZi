import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;
import 'package:intl/intl.dart';

class SurveyHistoryPage extends StatefulWidget {
  const SurveyHistoryPage({super.key});

  @override
  SurveyHistoryPageState createState() => SurveyHistoryPageState();
}

class SurveyHistoryPageState extends State<SurveyHistoryPage> {
  List<Map<String, dynamic>> _submissions = [];
  bool _isLoading = true;
  models.User? _currentUser;
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _loadSurveyHistory();
  }

  int _getTotalScore(List<Map<String, dynamic>> responses) {
    int total = 0;
    for (var response in responses) {
      if (response['score'] != null) {
        total += response['score'] as int;
      }
    }
    return total;
  }

  Map<String, dynamic> _getStatusInfo(int score) {
    if (score == 0) {
      return {
        'label': 'Aman',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'bgColor': Colors.green.shade50,
      };
    } else if (score <= 3) {
      return {
        'label': 'Waspada',
        'icon': Icons.warning,
        'color': Colors.orange,
        'bgColor': Colors.orange.shade50,
      };
    } else {
      return {
        'label': 'Bahaya',
        'icon': Icons.dangerous,
        'color': Colors.red,
        'bgColor': Colors.red.shade50,
      };
    }
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
      final submissions = await AppwriteService.getUserSurveyHistory(
        _currentUser!.$id,
      );
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
      appBar: AppBar(title: const Text('Riwayat Survei')),
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
                    submission['responses'],
                  );
                  final timestamp = DateTime.parse(submission['timestamp']);
                  final totalScore = _getTotalScore(responses);
                  final statusInfo = _getStatusInfo(totalScore);
                  // Check if ANY response has a score field (even if it's 0)
                  final hasScore = responses.any((r) => r['score'] != null);

                  // Debug: print score data
                  if (kDebugMode) {
                    print(
                      'Survey ${index + 1}: hasScore=$hasScore, totalScore=$totalScore',
                    );
                    for (var r in responses) {
                      print('  - ${r['question']}: score=${r['score']}');
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_dateFormatter.format(timestamp)),
                                if (hasScore) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusInfo['color'],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              statusInfo['icon'],
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${statusInfo['label']} (Skor: $totalScore)',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: responses
                                    .map(
                                      (response) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${responses.indexOf(response) + 1}.',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    response['question'],
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                if (response['score'] !=
                                                    null) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          response['score'] == 0
                                                          ? Colors
                                                                .green
                                                                .shade100
                                                          : response['score'] <=
                                                                3
                                                          ? Colors
                                                                .orange
                                                                .shade100
                                                          : Colors.red.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            response['score'] ==
                                                                0
                                                            ? Colors.green
                                                            : response['score'] <=
                                                                  3
                                                            ? Colors.orange
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${response['score']} poin',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            response['score'] ==
                                                                0
                                                            ? Colors
                                                                  .green
                                                                  .shade700
                                                            : response['score'] <=
                                                                  3
                                                            ? Colors
                                                                  .orange
                                                                  .shade700
                                                            : Colors
                                                                  .red
                                                                  .shade700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 18,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withAlpha(
                                                      (0.1 * 255).round(),
                                                    ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.check_circle_outline,
                                                    size: 18,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      response['response'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
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
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: hasScore
                                    ? statusInfo['bgColor']
                                    : Theme.of(context).primaryColor.withAlpha(
                                        (0.1 * 255).round(),
                                      ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                hasScore
                                    ? statusInfo['icon']
                                    : Icons.assignment_outlined,
                                color: hasScore
                                    ? statusInfo['color']
                                    : Theme.of(context).primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dateFormatter.format(timestamp),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      if (hasScore) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusInfo['color'],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                statusInfo['icon'],
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                statusInfo['label'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            'Skor: $totalScore',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Text(
                                          '${responses.length} jawaban',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey[400]),
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
