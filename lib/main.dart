import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:myapp/constant.dart';
import 'package:myapp/services/appwrite_service.dart';
import 'home/view/home_page.dart';
import 'package:myapp/home/view/teacher_login_page.dart';
import 'package:myapp/home/view/survey_page.dart';
import 'package:myapp/home/view/school_dashboard_page.dart';
import 'package:myapp/home/view/survey_history_page.dart';
import 'package:myapp/home/view/complaint_page.dart';
import 'package:myapp/home/view/complaint_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppwriteService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Client client = Client()
        .setEndpoint(AppwriteConstants.APPWRITE_PUBLIC_ENDPOINT)
        .setProject(AppwriteConstants.APPWRITE_PROJECT_ID);
    client.ping();

    return MaterialApp(
      title: 'Educational App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            height: 1.5,
          ),
        ),
      ),
      home: const HomePage(),
      routes: {
        '/login': (context) => const TeacherLoginPage(),
        '/survey': (context) => const SurveyPage(),
        '/dashboard': (context) => const SchoolDashboardPage(),
        '/survey-history': (context) => const SurveyHistoryPage(),
        '/complaint': (context) => const ComplaintPage(),
        '/complaint-history': (context) => const ComplaintHistoryPage(),
      },
    );
  }
}
