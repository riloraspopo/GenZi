import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/study_tip.dart';
import '../../services/appwrite_service.dart';

class StudyTipsWidget extends StatefulWidget {
  const StudyTipsWidget({super.key});

  @override
  State<StudyTipsWidget> createState() => _StudyTipsWidgetState();
}

class _StudyTipsWidgetState extends State<StudyTipsWidget> {
  late Future<List<StudyTip>> _studyTipsFuture;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _studyTipsFuture = AppwriteService.getStudyTips();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          FutureBuilder<List<StudyTip>>(
            future: _studyTipsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              final tips = snapshot.data ?? [];
              if (tips.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tidak ada tips belajar saat ini'),
                  ),
                );
              }

              return Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        },
                      ),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: tips.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final tip = tips[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      tip.description,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (tips.length > 1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          tips.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
